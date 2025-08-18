use std::path::Path;

use anyhow::{Context, Ok, Result};
use indicatif::{ProgressBar, ProgressStyle};
use tokio::{
    fs::File,
    io::{AsyncReadExt, AsyncSeekExt, AsyncWriteExt},
};

use crate::core::{FileMetaData, ProtocolPacket, TransferState};

use crate::transport::{Transport};

pub async fn send_file<T: Transport>(
    transport: &mut T,
    file_path: String,
    chunk_size: usize,
) -> Result<()> {
    let mut metadata = FileMetaData::new(file_path).await.unwrap();
    println!("Metadata:{:?}", metadata);
    let metadata_byte = ProtocolPacket::MetaData {
        file_name: metadata.filename,
        filesize: metadata.file_size,
        chunk_size: chunk_size as u64,
        filehash: metadata.filehash,
    }
    .compile();
    send_framed(transport, &metadata_byte).await?;
    let control_packet_raw = receive_framed(transport).await?;
    let control_packet: ProtocolPacket = serde_json::from_slice(&control_packet_raw)
        .context("Error when parsing the control signal packet")?;
    println!("I am here");

    match control_packet {
        ProtocolPacket::ResumeSend { needed_data_offset } => {
            metadata
                .file
                .seek(std::io::SeekFrom::Start(needed_data_offset))
                .await
                .context("Metadata Seeking")?;
        }
        _ => {}
    }

    let mut buffer = vec![0u8; chunk_size];
    while let std::result::Result::Ok(size) = metadata.file.read(&mut buffer).await {
        if size == 0 {
            break;
        }
        if transport.send(&buffer[..size]).await.is_err() {
            eprintln!("Failed to send the chunk to peer");
            break;
        }
    }
    Ok(())
}

//Send framed message to the transport layer
pub async fn send_framed<T: Transport>(transport: &mut T, data: &[u8]) -> Result<()> {
    let data_len = data.len() as u64;
    transport.send(&data_len.to_be_bytes()).await?;
    transport.send(&data).await?;
    Ok(())
}

pub async fn receive_framed<T: Transport>(transport: &mut T) -> Result<Vec<u8>> {
    let mut len_buf = [0u8; 8];
    transport.receive(&mut len_buf).await?;
    let data_len = u64::from_be_bytes(len_buf);

    let mut buffer = vec![0u8; data_len as usize];
    transport.receive(&mut buffer).await?;
    return Ok(buffer);
}

pub async fn receive_file<T: Transport>(transport: &mut T, download_path: String) -> Result<()> {
    let buffer = receive_framed(transport).await?;
    let metadata: ProtocolPacket = serde_json::from_slice(&buffer).unwrap();

    match metadata {
        ProtocolPacket::MetaData {
            file_name,
            filesize,
            chunk_size,
            filehash,
        } => {
            let datapath = Path::new(&download_path).join(format!("{}.unconfirmed", file_name));
            let filepath = Path::new(&download_path).join(&file_name);
            let statepath =
                Path::new(&download_path).join(format!("{}.unconfirmed.meta", file_name));

            let (mut file, mut received_byte) = if let Some((transfer_state, offset_pos)) =
                TransferState::get_state(&file_name, filesize, &filehash, &download_path).await
            {
                send_framed(
                    transport,
                    &ProtocolPacket::ResumeSend {
                        needed_data_offset: transfer_state.transfered_size,
                    }
                    .compile(),
                )
                .await?;
                let mut file = File::open(datapath.clone()).await?;
                let offset = transfer_state.transfered_size;
                file.seek(std::io::SeekFrom::Start(offset)).await?;
                (file, offset)
            } else {
                send_framed(transport, &ProtocolPacket::FreshSend.compile()).await?;
                let file = File::create(datapath.clone()).await?;
                (file, 0)
            };
            let mut bytes_remaining = filesize;
            let mut chunk_buffer = vec![0u8; chunk_size as usize];

            let pb = ProgressBar::new_spinner();

            pb.set_style(
                ProgressStyle::with_template("{spinner:.green} {msg}")
                    .unwrap()
                    .tick_strings(&["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]),
            );

            pb.set_message("Downloading..");

            let mut state = TransferState::init(&file_name, filesize, &filehash, &download_path)
                .await
                .context("Error while initializing the state file")?;

            while received_byte <= filesize {
                pb.tick();

                let n = transport.receive(&mut chunk_buffer).await?;
                if n == 0 {
                    break; // Connection closed early
                }
                received_byte = received_byte + n as u64;
                file.write_all(&chunk_buffer[..n]).await?;
                state.update_received_data_size(received_byte);
                state.load_to_file(&statepath).await?;
            }
            tokio::fs::rename(datapath, filepath).await?;
            tokio::fs::remove_file(statepath).await?;
            pb.finish_with_message("File received successfully");
        }
        _ => {
            eprintln!("Error no metadata packet is received");
        }
    }

    Ok(())
}

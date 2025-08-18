use std::path::Path;

use anyhow::Result;
use serde::{Deserialize, Serialize};
use tokio::{fs::File, io::AsyncSeekExt};
use crate::transfer::receive_framed;

//lets create the protocol
#[derive(Serialize, Deserialize)]
pub enum ProtocolPacket {
    MetaData {
        file_name: String,
        filesize: u64,
        chunk_size: u64,
        filehash: String,
    },

    //Control Packet for resumability
    FreshSend,
    ResumeSend {
        needed_data_offset: u64,
    },
    TransferComplete,
}

impl ProtocolPacket {
    pub fn compile(&self) -> Vec<u8> {
        let json = serde_json::to_string(self).unwrap();
        return json.as_bytes().to_vec();
    }
}

#[derive(Debug, Deserialize, Serialize)]
pub struct TransferState {
    pub filename: String,
    pub hash: String,
    pub filesize: u64,
    pub transfered_size: u64,
}

impl TransferState {
    pub async fn init(
        filename: &str,
        filesize: u64,
        filehash: &str,
        downloadpath: &str,
    ) -> Result<Self> {
        let statepath = Path::new(downloadpath).join(format!("{}.unconfirmed.meta", filename));
        let statefilew = File::create(&statepath).await?;
        let mut statefile = File::open(&statepath).await?;
        println!("I am here2");

        let data = receive_framed(&mut statefile).await?;
        let state: TransferState = serde_json::from_slice(&data).unwrap_or(TransferState {
            filename: filename.to_string(),
            hash: filehash.to_string(),
            filesize: filesize,
            transfered_size: 0,
        });
        Ok(state)
    }
    pub fn update_received_data_size(&mut self, update_data_size: u64) {
        self.transfered_size = update_data_size;
    }

    //lets use the current dir for searching the unfinished state
    //this is the checking for the state for resumability
    pub async fn get_state(
        filename: &str,
        filesize: u64,
        filehash: &str,
        downloadpath: &str,
    ) -> Option<(Self, u64)> {
        let statepath = Path::new(downloadpath).join(format!("{}.unconfirmed.meta", filename));
        let datapath = Path::new(downloadpath).join(format!("{}.unconfirmed", filename));
        if statepath.try_exists().is_err() && datapath.try_exists().is_err() {
            return None;
        }
        let mut statefile = File::open(statepath).await.ok()?;
        let (state, position) = Self::load_from_file(&mut statefile).await.ok()?;
        if state.filename == filename && state.hash == filehash && state.filesize == filesize {
            return Some((state, position));
        } else {
            return None;
        }
    }

    async fn load_from_file(file: &mut File) -> Result<(Self, u64)> {
        let data = receive_framed(file).await?;
        let state: TransferState = serde_json::from_slice(&data)?;
        let current_position = file.stream_position().await?;
        Ok((state, current_position))
    }

    pub async fn load_to_file(&self, filepath: &Path) -> Result<()> {
        let tmp_path = filepath.with_extension("tmp");
        let mut json = serde_json::to_vec(self)?;

        let data_len = json.len() as u64;
        let mut framed_data: Vec<u8> = vec![];
        framed_data.extend_from_slice(&data_len.to_be_bytes());
        framed_data.append(&mut json);
        tokio::fs::write(&tmp_path, &framed_data).await?;
        tokio::fs::rename(&tmp_path, filepath).await?;
        Ok(())
    }
}

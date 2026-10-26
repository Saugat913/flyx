use std::{
    collections::HashSet,
    net::SocketAddr,
    path::{Path, PathBuf},
    time::Duration,
};

use anyhow::{Ok, anyhow};
use tokio::{
    io::{self, AsyncBufReadExt, AsyncReadExt, AsyncWriteExt, BufReader},
    net::{TcpListener, TcpStream},
    time::Instant,
};

use crate::{
    config::Config,
    core::FileMetaData,
    discover::beacon::{BconPacket, Broadcaster, Finder},
    transfer::{receive_file, send_file},
    transport::Transport,
    utils::zip::zip_folder,
};

//lets create the separate Sender and Receiver
pub struct Sender {
    filepath: String,
    listener: TcpListener,
    chunk_size: usize,
    server_address: String,
}
pub struct Receiver {
    url: String,
    stream: TcpStream,
    download_path: String,
}

impl Sender {
    pub async fn init(file_path: String, config: &Config) -> anyhow::Result<Self> {
        let server_addr = format!("{}:{}", config.server.address, config.server.port);
        println!("Starting the TCP server at {:?}", &server_addr);
        let listener = TcpListener::bind(&server_addr).await?;

        let _ = Broadcaster::init("My device".to_string(), config.server.port).await;
        Ok(Self {
            filepath: file_path,
            listener: listener,
            chunk_size: config.transfer.chunk_size,
            server_address: server_addr,
        })
    }

    pub async fn run(&mut self) {
        let filepath = Path::new(&self.filepath);

        if filepath.is_dir() {
            // Compress the folder
            let foldername = filepath.file_name().unwrap().to_string_lossy();
            println!("FOlder name:{}", foldername);
            let zip_folder_path = filepath
                .parent()
                .unwrap_or(Path::new(""))
                .join(format!("{}.zip", foldername));
            zip_folder(self.filepath.clone(), zip_folder_path.display().to_string())
                .await
                .unwrap();
            self.filepath = zip_folder_path.display().to_string();
        }
        while let std::result::Result::Ok((mut stream, peer)) = self.listener.accept().await {
            println!("Peer {peer} is connected");
            let file = self.filepath.clone();
            let chunk_size = self.chunk_size;
            tokio::spawn(async move {
                let _ = send_file(&mut stream, file, chunk_size).await;
            });
        }
    }
}
impl Receiver {
    pub async fn init(url: String, config: &Config) -> anyhow::Result<Self> {
        let mut finder = Finder::init().await;

        println!("Looking for the sender locally...");
        let mut devices_found = HashSet::<(BconPacket, SocketAddr)>::new();
        let instant_time = Instant::now();
        while instant_time.elapsed() <= Duration::from_secs(2) {
            if let std::result::Result::Ok((packet, peer)) = finder.data_channel.recv().await {
                devices_found.insert((packet, peer));
            }
        }
        finder.stop().await;
        let devices_found: Vec<(BconPacket, SocketAddr)> = devices_found.into_iter().collect();
        println!("===============Device detected==================");
        for (index, device) in devices_found.iter().enumerate() {
            println!("{}.{}", index + 1, device.0.device_name);
        }

        if devices_found.len() == 0 {
            return Err(anyhow!("Device not found!"));
        }

        println!("Choose device [1:{}]", devices_found.len());
        let option = {
            let mut buffreader = BufReader::new(io::stdin());
            let mut line = String::new();
            buffreader.read_line(&mut line).await?;

            let option: usize = line.trim().parse()?;
            if option == 0 || option > devices_found.len() {
                return Err(anyhow!("Invalid Option"));
            };
            option
        };

        let selected = &devices_found[option - 1];
        let url = format!("{}:{}", selected.1.ip().to_string(), selected.0.port);
        let stream = TcpStream::connect(&url).await?;

        Ok(Self {
            url: url,
            stream: stream,
            download_path: config.transfer.download_path.clone(),
        })
    }
    pub async fn run(&mut self) -> anyhow::Result<()> {
        receive_file(&mut self.stream, self.download_path.clone()).await?;
        Ok(())
    }
}

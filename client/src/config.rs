use anyhow::{Ok, Result};
use serde::Deserialize;
use std::{fs::File, io::BufReader};

#[derive(Debug, Deserialize)]
pub struct Config {
    pub server: ServerConfig,
    pub transfer: TransferConfig,
}

#[derive(Debug, Deserialize)]
pub struct ServerConfig {
    pub address: String,
    pub port: u16,
}

#[derive(Debug, Deserialize)]
pub struct TransferConfig {
    pub chunk_size: usize,
    pub download_path: String,
}

impl Config {
    fn default_download_path() -> String {
        if cfg!(target_os = "windows") {
            std::env::var("USERPROFILE")
                .map(|home| format!("{}\\Downloads", home))
                .unwrap_or_else(|_| "C:\\Users\\Downloads".to_string())
        } else if cfg!(target_os = "macos") {
            std::env::var("HOME")
                .map(|home| format!("{}/Downloads", home))
                .unwrap_or_else(|_| "/Users/Downloads".to_string())
        } else {
            std::env::var("HOME")
                .map(|home| format!("{}/Downloads", home))
                .unwrap_or_else(|_| "/home/Downloads".to_string())
        }
    }
}

impl Default for Config {
    fn default() -> Self {
        Self {
            server: ServerConfig {
                address: "0.0.0.0".to_string(),
                port: 8000,
            },
            transfer: TransferConfig {
                //8 kB
                chunk_size: 8192,
                download_path: Self::default_download_path(),
            },
        }
    }
}

//lets create the partial config type so that they can be merged
#[derive(Debug, Deserialize)]
struct PartialConfig {
    server: Option<PartialServerConfig>,
    transfer: Option<PartialTransferConfig>,
}

#[derive(Debug, Deserialize)]
struct PartialServerConfig {
    address: Option<String>,
    port: Option<u16>,
}

#[derive(Debug, Deserialize)]
struct PartialTransferConfig {
    chunk_size: Option<usize>,
    download_path: Option<String>,
}

impl Default for PartialConfig {
    fn default() -> Self {
        Self {
            server: None,
            transfer: None,
        }
    }
}
impl Config {
    //lets use the config file for linux only for now
    //~/.config/flyxconfig.json
    pub async fn from_file(path: &str) -> Result<Self> {
        let file = File::open(path)?;
        let mut buffreader = BufReader::new(file);
        let config: PartialConfig = serde_json::from_reader(&mut buffreader).unwrap_or_default();
        Ok(Self::default().merge(config))
    }

    fn merge(&self, partial_config: PartialConfig) -> Self {
        Self {
            server: ServerConfig {
                address: partial_config
                    .server
                    .as_ref()
                    .and_then(|s| s.address.clone())
                    .unwrap_or(self.server.address.clone()),
                port: partial_config
                    .server
                    .as_ref()
                    .and_then(|s| s.port)
                    .unwrap_or(self.server.port),
            },
            transfer: TransferConfig {
                chunk_size: partial_config
                    .transfer
                    .as_ref()
                    .and_then(|t| t.chunk_size)
                    .unwrap_or(self.transfer.chunk_size),
                download_path: partial_config
                    .transfer
                    .as_ref()
                    .and_then(|t| t.download_path.clone())
                    .unwrap_or(self.transfer.download_path.clone()),
            },
        }
    }
}

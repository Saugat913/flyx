//! Flyx Client Library
//!
//! A modular file transfer library supporting both local and global transfers.

pub mod config;
pub mod core;
pub mod discover;
pub mod signaling;
pub mod transfer;
pub mod transport;
pub mod utils;
pub mod cli;

// Re-export main types for easy access
pub use config::Config;
pub use cli::Cli;
pub use core::{FileMetaData, ProtocolPacket, TransferState};
pub use transfer::{receive_file, send_file};
pub use transport::{Transport, WebrtcTransport};

// Re-export coordinators
pub use transfer::{
    global::{Receiver as GlobalReceiver, Sender as GlobalSender},
    local::{Receiver as LocalReceiver, Sender as LocalSender},
};

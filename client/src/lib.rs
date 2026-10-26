//! Flyx Client Library
//!
//! A modular file transfer library supporting both local and global transfers.

pub mod cli;

// Re-export main modules and types from core
pub use flyx_core::{
    config::{self, Config},
    discover,
    error,
    file::{self, FileMetaData},
    protocol::{self, ProtocolPacket, TransferState},
    signaling,
    transfer::{self, receive_file, send_file},
    transport::{self, Transport, WebrtcTransport},
    utils,
};

// Re-export CLI types
pub use cli::Cli;

// Re-export coordinators
pub use flyx_core::transfer::{
    global::{Receiver as GlobalReceiver, Sender as GlobalSender},
    local::{Receiver as LocalReceiver, Sender as LocalSender},
};

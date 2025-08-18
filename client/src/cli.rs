use clap::{ArgAction, Parser, Subcommand};

//A simple program to transfer file globally and locally
#[derive(Debug, Parser)]
#[command(version,about,long_about=None)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Debug, Subcommand)]
pub enum Commands {
    ///Send file
    Send {
        ///File to send
        filename: String,

        /// Determine the file trasfer is local or global
        #[arg(short,long,action= ArgAction::SetTrue)]
        global: bool,
    },

    ///Receive file
    Receive {
        /// Unique code for connecting to the global
        #[arg(short, long)]
        global: Option<String>,
    },
}

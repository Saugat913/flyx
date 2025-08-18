use anyhow::Ok;
use clap::Parser;

// Import from your own library
use client::{Cli, Config, GlobalReceiver, GlobalSender, LocalReceiver, LocalSender, cli};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let cli = Cli::parse();
    //TODO:For windows and macos
    let config_path = match std::env::consts::OS {
        "windows" => format!(
            "{}\\AppData\\Local\\flyx\\config.json",
            std::env::var("USERPROFILE")?
        ),
        "macos" => format!(
            "{}/Library/Application Support/flyx/config.json",
            std::env::var("HOME")?
        ),
        _ => format!("{}/.config/flyxconfig.json", std::env::var("HOME")?),
    };


    let config = Config::from_file(&config_path).await?;
    println!("{:?}", cli);
    println!("Config:{:?}", config);

    match cli.command {
        cli::Commands::Send { filename, global } => {
            if global {
                let sender = GlobalSender::init(filename, config.transfer.chunk_size)
                    .await
                    .unwrap();
            } else {
                let mut transfer_engine = LocalSender::init(filename, &config).await?;
                transfer_engine.run().await;
            }
        }
        cli::Commands::Receive { global } => {
            if let Some(code) = global {
                let receiver = GlobalReceiver::init(code, config.transfer.download_path)
                    .await
                    .unwrap();
            } else {
                let mut transfer_engine = LocalReceiver::init("".to_string(), &config).await?;
                transfer_engine.run().await.unwrap();
            }
        }
    }

    // Keep the program running until Ctrl+C
    tokio::signal::ctrl_c().await?;
    println!("Shutting down...");

    Ok(())
}

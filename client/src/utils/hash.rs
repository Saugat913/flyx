use anyhow::Result;
use sha2::{Digest, Sha256};
use std::path::Path;
use tokio::{fs::File, io::AsyncReadExt};
pub async fn hash_the_file(filepath: impl AsRef<Path>) -> Result<String> {
    let mut file = File::open(filepath).await?;
    let mut hasher = Sha256::new();
    let mut buffer = [0u8; 1024];
    loop {
        let size = file.read(&mut buffer).await?;
        if size == 0 {
            break;
        }
        hasher.update(&buffer[..size]);
    }
    let hash_hexed: String = hasher
        .finalize()
        .iter()
        .map(|e| format!("{:02x}", e))
        .collect();
    Ok(hash_hexed)
}

use anyhow::Result;
use tokio::{
    fs::File,
    io::{AsyncReadExt, AsyncWriteExt},
};

impl super::Transport for File {
    async fn receive(&mut self, buf: &mut [u8]) -> Result<usize> {
        let size = self.read(buf).await?;
        Ok(size)
    }
    async fn send(&mut self, data: &[u8]) -> Result<()> {
        self.write_all(data).await?;
        Ok(())
    }
}

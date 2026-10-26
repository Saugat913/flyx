use tokio::{
    io::{AsyncReadExt, AsyncWriteExt},
    net::TcpStream,
};

impl super::Transport for TcpStream {
    async fn receive(&mut self, mut buf: &mut [u8]) -> anyhow::Result<usize> {
        let size = self.read(&mut buf).await?;
        Ok(size)
    }
    async fn send(&mut self, data: &[u8]) -> anyhow::Result<()> {
        self.write_all(data).await?;
        Ok(())
    }
}

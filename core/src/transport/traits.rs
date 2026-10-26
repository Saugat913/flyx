use anyhow::Result;

pub trait Transport: Send + Sync {
    async fn send(&mut self, data: &[u8]) -> Result<()>;
    async fn receive(&mut self, buf: &mut [u8]) -> Result<usize>;
}
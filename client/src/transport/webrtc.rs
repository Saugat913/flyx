use std::sync::Arc;

use tokio::sync::mpsc;
use tokio_tungstenite::tungstenite::Bytes;
use webrtc::data_channel::RTCDataChannel;

use anyhow::Result;
pub struct WebrtcTransport {
    pub data_channel: Arc<RTCDataChannel>,
    pub receiver_channel: mpsc::Receiver<Vec<u8>>,
}

impl super::Transport for WebrtcTransport {
    async fn receive(&mut self, buf: &mut [u8]) -> Result<usize> {
        let data = self.receiver_channel.recv().await;
        if let Some(data) = data {
            let n = data.len().min(buf.len());
            buf[..n].copy_from_slice(&data[..n]);
            return Ok(data.len());
        } else {
            return Ok(0);
        }
    }
    async fn send(&mut self, data: &[u8]) -> Result<()> {
        let data_bytes = Bytes::copy_from_slice(data);
        let size = self.data_channel.send(&data_bytes).await?;
        Ok(())
    }
}

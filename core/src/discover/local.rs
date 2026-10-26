use std::{collections::HashSet, net::SocketAddr, time::Duration};

use super::beacon::BconPacket;
use super::beacon::Finder;
use tokio::time::Instant;
pub struct LocalDiscovery {
    finder: Finder,
}

impl LocalDiscovery {
    pub async fn new() -> Self {
        let finder = Finder::init().await;
        Self { finder: finder }
    }
    pub async fn discover_devices(&mut self, timeout_secs: u64) -> Vec<(BconPacket, SocketAddr)> {
        let mut devices_found = HashSet::<(BconPacket, SocketAddr)>::new();
        let instant_time = Instant::now();

        while instant_time.elapsed() <= Duration::from_secs(timeout_secs) {
            if let Ok((packet, peer)) = self.finder.data_channel.recv().await {
                devices_found.insert((packet, peer));
            }
        }

        devices_found.into_iter().collect()
    }

    pub async fn stop(self) {
        self.finder.stop().await;
    }
}

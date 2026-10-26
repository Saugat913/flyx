use std::collections::HashSet;
use std::net::{Ipv4Addr, SocketAddr, SocketAddrV4};
use std::time::Duration;

use anyhow::Ok;
use serde::{Deserialize, Serialize};
use tokio::net::UdpSocket;
use tokio::sync::broadcast::{self, Receiver};
use tokio::sync::mpsc::{Sender, channel};
use tokio::time::sleep;
#[derive(Debug, Clone, Serialize, Deserialize, Eq, Hash, PartialEq)]
pub struct BconPacket {
    pub magic_code: [u8; 3],
    pub protocol_version: u8,
    pub port: u16,
    pub device_name: String,
}

pub struct Broadcaster {
    channel: Sender<bool>,
}

impl Broadcaster {
    pub async fn init(device_name: String, port: u16) -> Self {
        let (tx, mut rx) = channel::<bool>(1);
        tokio::spawn(async move {
            let udp_socket = UdpSocket::bind("0.0.0.0:4444").await.unwrap();
            let group = Ipv4Addr::new(239, 10, 10, 10);
            let addr = SocketAddrV4::new(group, 4445);

            println!("[Broadcaster] join the multicast");
            udp_socket
                .join_multicast_v4(group, Ipv4Addr::UNSPECIFIED)
                .unwrap();

            let msg = serde_json::to_vec(&BconPacket {
                magic_code: *b"BCO",
                port: port,
                protocol_version: 1,
                device_name: device_name,
            })?;

            let msg_len = msg.len() as u8;

            let mut framed_msg = Vec::new();
            framed_msg.push(msg_len);
            framed_msg.extend(msg);

            loop {
                if let std::result::Result::Ok(isfinished) = rx.try_recv() {
                    if isfinished {
                        break;
                    }
                }
                println!("[Broadcaster] Sending the packet");
                udp_socket.send_to(&framed_msg, addr).await?;
                sleep(Duration::from_secs(3)).await;
            }
            Ok(())
        });

        Self { channel: tx }
    }

    async fn stop(&self) {
        self.channel.send(true).await.unwrap();
    }
}

pub struct Finder {
    signal_channel: Sender<bool>,
    pub data_channel: Receiver<(BconPacket, SocketAddr)>,
}

impl Finder {
    pub async fn init() -> Self {
        let (stx, mut srx) = channel::<bool>(4);
        let (dtx, drx) = broadcast::channel::<(BconPacket, SocketAddr)>(4);
        tokio::spawn(async move {
            let udp_socket = UdpSocket::bind("0.0.0.0:4445").await?;
            println!("[Finder] join the multicast");

            let mut devices: HashSet<String> = HashSet::new();
            udp_socket.join_multicast_v4(Ipv4Addr::new(224, 0, 0, 251), Ipv4Addr::UNSPECIFIED)?;
            let mut buffer = [0u8; 1500];
            loop {
                tokio::select! {
                    result= udp_socket.recv_from(&mut buffer)=>{
                        match result{
                            std::result::Result::Ok((receive_size,peer))=>{
                                if receive_size == 0 {
                                    break;
                                }
                                 let bconpacket_size = buffer[0];
                                let bconpacket: BconPacket =
                                    serde_json::from_slice(&buffer[1..1 + bconpacket_size as usize])?;

                                let device = format!(
                                    "{}:{}:{}",
                                    bconpacket.device_name,
                                    peer.to_string(),
                                    bconpacket.port
                                );

                                if devices.get(&device) == None {
                                    println!("[Finder] sending packet via channel");
                                    devices.insert(device);
                                    dtx.send((bconpacket, peer)).unwrap();
                                }
                            },
                            Err(e)=>{
                               eprintln!("[Finder] recv error: {}", e);
                            continue;
                            }
                        }
                    },
                    Some(isclose)= srx.recv()=>{
                        if isclose{
                            break;
                        }
                    }
                }
            }

            Ok(())
        });

        Self {
            data_channel: drx,
            signal_channel: stx,
        }
    }

    pub async fn stop(&self) {
        self.signal_channel.send(true).await.unwrap();
    }
}

use std::sync::Arc;

use anyhow::{Ok, Result};
use futures_util::{SinkExt, StreamExt};
use reqwest::Client;
use tokio::sync::{Mutex, mpsc};
use tokio_tungstenite::{connect_async, tungstenite::Bytes};
use webrtc::{
    self,
    api::APIBuilder,
    data_channel::RTCDataChannel,
    ice_transport::{
        ice_candidate::{RTCIceCandidate, RTCIceCandidateInit},
        ice_server::RTCIceServer,
    },
    peer_connection::{
        configuration::RTCConfiguration, sdp::session_description::RTCSessionDescription,
    },
};

use serde::{Deserialize, Serialize};

use crate::signaling::messages::{CreateRoomResponse, SignalingMessage};
use crate::transport::Transport;
use crate::{
    transfer::{receive_file, send_file},
    transport::WebrtcTransport,
};
pub struct Sender {}

impl Sender {
    pub async fn init(filepath: String, chunk_size: usize) -> Result<Self> {
        let api_builder = APIBuilder::new().build();

        let config = RTCConfiguration {
            ice_servers: vec![RTCIceServer {
                urls: vec!["stun:stun.l.google.com:19302".to_owned()],
                ..Default::default()
            }],
            ..Default::default()
        };
        let peer = api_builder.new_peer_connection(config).await?;
        let data_channel = peer.create_data_channel("transfer", None).await?;

        let (tx, rx) = mpsc::channel(10);

        let webrtc_transport = Arc::new(Mutex::new(WebrtcTransport {
            data_channel: data_channel.clone(),
            receiver_channel: rx,
        }));

        data_channel.on_open(Box::new(move || {
            println!("Data channel is opened");
            let webrtc_transport = webrtc_transport.clone();
            let filepath = filepath.clone();
            let chunksize = chunk_size.clone();
            Box::pin(async move {
                let mut transport = webrtc_transport.lock().await;
                send_file(&mut *transport, filepath, chunksize)
                    .await
                    .unwrap();
            })
        }));

        data_channel.on_message(Box::new(move |message| {
            let msg_vec = message.data.to_vec();
            let tx_cloned = tx.clone();
            Box::pin(async move {
                tx_cloned.send(msg_vec).await.unwrap();
            })
        }));

        let url = "http://localhost:8000/api/room";
        let client = Client::new();
        let CreateRoomResponse { id } = client
            .post(url)
            .send()
            .await
            .unwrap()
            .json::<CreateRoomResponse>()
            .await
            .unwrap();
        println!("Unique code: {}", &id);
        let (ws_stream, _) = connect_async(format!("ws://localhost:8000/api/room/{}", id))
            .await
            .unwrap();

        let (mut write, mut read) = ws_stream.split();

        let (tx, mut rx) = tokio::sync::mpsc::channel::<SignalingMessage>(10);
        tokio::spawn(async move {
            while let Some(data) = rx.recv().await {
                write
                    .send(tokio_tungstenite::tungstenite::Message::Text(
                        serde_json::to_string(&data).unwrap().into(),
                    ))
                    .await
                    .unwrap();
            }
        });
        let peer_sharable = Arc::new(peer);
        let tx_cloned = tx.clone();
        peer_sharable.on_ice_candidate(Box::new(move |candidate: Option<RTCIceCandidate>| {
            let tx = tx_cloned.clone();
            Box::pin(async move {
                if let Some(c) = candidate {
                    tx.send(SignalingMessage::ICECandidate {
                        candidate: serde_json::to_string(&c.to_json().unwrap()).unwrap(),
                    })
                    .await
                    .unwrap();
                }
            })
        }));

        tokio::spawn(async move {
            let peer = peer_sharable.clone();
            while let Some(ws_msg) = read.next().await {
                match ws_msg.unwrap() {
                    tokio_tungstenite::tungstenite::Message::Text(msg) => {
                        let signaling_msg: SignalingMessage =
                            serde_json::from_slice(msg.as_bytes()).unwrap();

                        match signaling_msg {
                            SignalingMessage::Answer { sdp } => {
                                let answer = RTCSessionDescription::answer(sdp).unwrap();
                                peer.set_remote_description(answer).await.unwrap();
                            }
                            SignalingMessage::Offer { .. } => {
                                eprintln!("Offer should not be provided to sender");
                            }
                            SignalingMessage::ICECandidate { candidate } => {
                                let rtc_candidate: RTCIceCandidateInit =
                                    serde_json::from_str(&candidate).unwrap();
                                peer.add_ice_candidate(rtc_candidate).await.unwrap();
                            }
                            SignalingMessage::SlaveJoined => {
                                let offer = peer_sharable.create_offer(None).await.unwrap();
                                println!("Offer is like this: {}", &offer.sdp);
                                peer_sharable
                                    .set_local_description(offer.clone())
                                    .await
                                    .unwrap();

                                tx.send(SignalingMessage::Offer {
                                    sdp: offer.sdp.clone(),
                                })
                                .await
                                .unwrap();
                            }
                        }
                    }
                    _ => {}
                }
            }
        });

        Ok(Self {})
    }
}
pub struct Receiver {}

impl Receiver {
    pub async fn init(code: String, download_path: String) -> Result<Self> {
        let api_builder = APIBuilder::new().build();
        let config = RTCConfiguration {
            ice_servers: vec![RTCIceServer {
                urls: vec!["stun:stun.l.google.com:19302".to_owned()],
                ..Default::default()
            }],
            ..Default::default()
        };
        let peer = api_builder.new_peer_connection(config).await?;

        peer.on_data_channel(Box::new(move |dc| {
            println!("Receiver got data channel: {}", dc.label());
            let dc_cloned = dc.clone();
            let download_path = download_path.clone();
            let (tx, rx) = mpsc::channel(10);

            dc.on_open(Box::new(move || {
                println!("Receiver: data channel opened");
                let download_path = download_path.clone();
                let webrtc_transport = Arc::new(Mutex::new(WebrtcTransport {
                    data_channel: dc_cloned.clone(),
                    receiver_channel: rx,
                }));
                Box::pin(async move {
                    let mut transport = webrtc_transport.lock().await;
                    receive_file(&mut *transport, download_path).await.unwrap();
                })
            }));

            dc.on_message(Box::new(move |msg| {
                let tx_cloned = tx.clone();
                Box::pin(async move {
                    tx_cloned.send(msg.data.to_vec()).await.unwrap();
                })
            }));

            Box::pin(async move {})
        }));

        let url = "http://localhost:8000/api/route";

        let (ws_stream, _) = connect_async(format!("ws://localhost:8000/api/room/{}", code))
            .await
            .unwrap();

        let (mut write, mut read) = ws_stream.split();
        // Channel to send ICE candidates to signaling
        let (tx, mut rx) = tokio::sync::mpsc::channel::<SignalingMessage>(10);
        tokio::spawn(async move {
            while let Some(data) = rx.recv().await {
                write
                    .send(tokio_tungstenite::tungstenite::Message::Text(
                        serde_json::to_string(&data).unwrap().into(),
                    ))
                    .await
                    .unwrap();
            }
        });
        let peer_sharable = Arc::new(peer);

        let tx_cloned = tx.clone();
        // Send ICE candidates to signaling
        peer_sharable.on_ice_candidate(Box::new(move |candidate: Option<RTCIceCandidate>| {
            let tx = tx_cloned.clone();
            Box::pin(async move {
                if let Some(c) = candidate {
                    tx.send(SignalingMessage::ICECandidate {
                        candidate: serde_json::to_string(&c.to_json().unwrap()).unwrap(),
                    })
                    .await
                    .unwrap();
                }
            })
        }));

        tokio::spawn(async move {
            let peer = peer_sharable.clone();
            while let Some(ws_msg) = read.next().await {
                match ws_msg.unwrap() {
                    tokio_tungstenite::tungstenite::Message::Text(msg) => {
                        let signaling_msg: SignalingMessage =
                            serde_json::from_slice(msg.as_bytes()).unwrap();

                        match signaling_msg {
                            SignalingMessage::Answer { .. } => {
                                eprintln!("Answer should not be provided to receiver");
                            }
                            SignalingMessage::Offer { sdp } => {
                                println!("Receiver: got Offer");

                                // 1. Set remote description
                                let offer = RTCSessionDescription::offer(sdp).unwrap();
                                peer.set_remote_description(offer).await.unwrap();

                                // 2. Create answer
                                let answer = peer.create_answer(None).await.unwrap();
                                peer.set_local_description(answer.clone()).await.unwrap();

                                // 3. Send Answer back
                                tx.send(SignalingMessage::Answer { sdp: answer.sdp })
                                    .await
                                    .unwrap();
                            }
                            SignalingMessage::ICECandidate { candidate } => {
                                let rtc_candidate: RTCIceCandidateInit =
                                    serde_json::from_str(&candidate).unwrap();
                                peer.add_ice_candidate(rtc_candidate).await.unwrap();
                            }
                            SignalingMessage::SlaveJoined => {
                                //Just ignore it
                            }
                        }
                    }
                    _ => {}
                }
            }
        });

        Ok(Self {})
    }
}

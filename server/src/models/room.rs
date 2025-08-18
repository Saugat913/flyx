use crate::{dtos::SignalingMessage, utils::generate_unique_id};
use std::{collections::HashMap, sync::Arc};
use tokio::sync::{
    Mutex,
    mpsc::{Receiver, Sender, channel},
};

#[derive(Debug, Clone)]
pub struct Room {
    master: Arc<Mutex<Option<Sender<SignalingMessage>>>>, 
    slaves: Arc<Mutex<HashMap<String, Sender<SignalingMessage>>>>,
}

impl Room {
    pub fn new() -> Self {
        let slaves = HashMap::new();

        Self {
            master: Arc::new(Mutex::new(None)),
            slaves: Arc::new(Mutex::new(slaves)),
        }
    }

    pub async fn send_to_master(&self, msg: SignalingMessage) {
        let master_locked = self.master.lock().await;
        match master_locked.as_ref() {
            Some(master_channel) => {
                if let Err(e) = master_channel.send(msg).await {
                    eprintln!("Error sending to master: {}", e);
                }
            }
            None => {
                eprintln!("There is no master to send to");
            }
        }
    }

    pub async fn add_master(&self) -> Receiver<SignalingMessage> {
        let (tx, rx) = channel(10);
        let mut master_locked = self.master.lock().await;
        *master_locked = Some(tx);
        rx
    }

    pub async fn is_master_available(&self) -> bool {
        let master_locked = self.master.lock().await;
        master_locked.is_some()
    }

    pub async fn add_slave(&self) -> (String, Receiver<SignalingMessage>) {
        let (tx, rx) = channel(10);
        let mut slaves_locked = self.slaves.lock().await;

        let unique_id = loop {
            let id = generate_unique_id(16);
            if !slaves_locked.contains_key(&id) {
                break id;
            }
        };

        slaves_locked.insert(unique_id.clone(), tx);
        (unique_id, rx)
    }

    pub async fn broadcast(&self, broadcaster: &str, msg: SignalingMessage) {
        println!("Broadcasting message from {}: {:?}", broadcaster, msg);

        // Send to master if broadcaster is not master
        if broadcaster != "master" {
            let master_locked = self.master.lock().await;
            if let Some(master_sender) = master_locked.as_ref() {
                if let Err(e) = master_sender.send(msg.clone()).await {
                    eprintln!("Error sending to master: {}", e);
                } else {
                    println!("Message sent to master");
                }
            }
        }

        // Send to all slaves except the broadcaster
        let slaves_locked = self.slaves.lock().await;
        for (slave_id, slave_sender) in slaves_locked.iter() {
            if slave_id != broadcaster {
                if let Err(e) = slave_sender.send(msg.clone()).await {
                    eprintln!("Error sending to slave {}: {}", slave_id, e);
                } else {
                    println!("Message sent to slave {}", slave_id);
                }
            }
        }
    }

    pub async fn remove_slave(&self, slave_id: &str) {
        let mut slaves_locked = self.slaves.lock().await;
        slaves_locked.remove(slave_id);
        println!("Removed slave: {}", slave_id);
    }

    pub async fn remove_master(&self) {
        let mut master_locked = self.master.lock().await;
        *master_locked = None;
        println!("Removed master");
    }
}

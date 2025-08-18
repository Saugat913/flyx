use crate::{models::Room, utils::generate_unique_id};
use std::{collections::HashMap, sync::Arc};
use tokio::sync::Mutex;

#[derive(Debug, Clone)]
pub struct RoomRespostory {
    store: Arc<Mutex<HashMap<String, Room>>>,
}

impl RoomRespostory {
    pub fn new(store: HashMap<String, Room>) -> Self {
        Self {
            store: Arc::new(Mutex::new(store)),
        }
    }

    pub async fn create_room(&self) -> String {
        let mut store_locked = self.store.lock().await;
        let unique_id = loop {
            let id = generate_unique_id(6);
            if store_locked.contains_key(&id) {
                continue;
            }
            break id;
        };
        store_locked.insert(unique_id.clone(), Room::new());
        unique_id
    }

    pub async fn get_room(&self, id: String) -> Option<Room> {
        let store_locked = self.store.lock().await;
        store_locked.get(&id).cloned()
    }

    pub async fn destroy_room(&self, id: String) {
        let mut store_locked = self.store.lock().await;
        store_locked.remove(&id).ok_or("No room").unwrap();
    }
}

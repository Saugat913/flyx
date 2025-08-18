use crate::repository::RoomRespostory;

#[derive(Debug, Clone)]
pub struct AppState {
    pub room_repository: RoomRespostory,
}

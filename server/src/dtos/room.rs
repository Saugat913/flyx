use serde::Serialize;

#[derive(Debug, Serialize)]
pub struct CreateRoomResponse {
    pub id: String,
}

use crate::{
    dtos::{CreateRoomResponse, SignalingMessage},
    models::Room,
    state::AppState,
};
use axum::{
    Json, Router,
    extract::{
        Path, State, WebSocketUpgrade,
        ws::{self, WebSocket},
    },
    response::IntoResponse,
    routing::{get, post},
};
use futures_util::{SinkExt, StreamExt};
use serde_json::json;

pub fn build_routes() -> Router<AppState> {
    Router::new()
        .route("/", post(create_room))
        .route("/{id}", get(join_room))
}

async fn create_room(State(state): State<AppState>) -> Json<CreateRoomResponse> {
    let room_id = state.room_repository.create_room().await;
    return Json(CreateRoomResponse { id: room_id });
}
async fn join_room(
    Path(id): Path<String>,
    State(state): State<AppState>,
    websocket: WebSocketUpgrade,
) -> impl IntoResponse {
    if let Some(room) = state.room_repository.get_room(id).await {
        websocket.on_upgrade(|socket| handle_room(state, room, socket))
    } else {
        Json(json!(
            {
                "error":"Could not find the room"
            }
        ))
        .into_response()
    }
}

async fn handle_room(state: AppState, mut room: Room, socket: WebSocket) {
    let (id, mut client) = if room.is_master_available().await {
        let (id, client) = room.add_slave().await;
        room.send_to_master(SignalingMessage::SlaveJoined).await;
        (id, client)
    } else {
        let client = room.add_master().await;
        ("master".to_string(), client)
    };

    let (mut sender, mut receiver) = socket.split();

    let receive_task = tokio::spawn(async move {
        while let Some(msg) = receiver.next().await {
            match msg.unwrap() {
                axum::extract::ws::Message::Text(msg) => {
                    let signaling_message: SignalingMessage =
                        serde_json::from_slice(msg.as_bytes()).unwrap();
                    println!("Message received from receiver {:?}", signaling_message);
                    room.broadcast(&id, signaling_message).await;
                }
                _ => {}
            }
        }

        if id == "master" {
            state.room_repository.destroy_room(id.clone()).await;
        } else {
            room.remove_slave(&id).await;
        }
    });
    let send_task = tokio::spawn(async move {
        while let Some(msg) = client.recv().await {
            println!("Writing to client msg {:?}", &msg);
            sender
                .send(ws::Message::Text(
                    serde_json::to_string(&msg).unwrap().into(),
                ))
                .await
                .unwrap();
        }
    });
    // Wait for either task to complete (which means the connection is closed)
    tokio::select! {
        _ = receive_task => {
            println!("Receive task completed");
        }
        _ = send_task => {
            println!("Send task completed");
        }
    }

    println!("Client handler ending");
}

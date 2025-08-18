use crate::{repository::RoomRespostory, routes, state::AppState};
use std::collections::HashMap;
use tokio::net::TcpListener;

pub async fn run_app() {
    let store = HashMap::new();
    let room_repository = RoomRespostory::new(store);

    let state = AppState {
        room_repository: room_repository,
    };
    let router = routes::build_routes(state);
    let listener = TcpListener::bind("0.0.0.0:8000").await.unwrap();
    axum::serve(listener, router).await.unwrap();
}

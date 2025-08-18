use axum::{Router, routing::get};

use crate::state::AppState;
mod room;

pub fn build_routes(state: AppState) -> Router {
    let router = Router::new()
        .route("/health", get(health_status))
        .nest("/room", room::build_routes())
        .with_state(state);
    return Router::new().nest("/api", router);
}

async fn health_status() -> &'static str {
    "Ok"
}

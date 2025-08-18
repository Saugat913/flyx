use crate::app::run_app;

mod dtos;
mod models;
mod repository;
mod routes;

mod app;
mod state;
mod utils;

#[tokio::main]
async fn main() {
    run_app().await;
}

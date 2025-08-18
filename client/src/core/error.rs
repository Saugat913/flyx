// #[derive(Debug, thiserror::Error)]
// pub enum Error {
//     #[error("Transfer: {0}")]
//     Trasfer(String),
//     #[error("Discovery: {0}")]
//     Discovery(String),
//     #[error("Config: {0}")]
//     Config(String),
//     #[error("Invalid command: {0}")]
//     InvalidCommand(String),
//     #[error("Other error : {0}")]
//     Anyhow(anyhow::Error),

//     #[error("IO error : {0}")]
//     IOError(std::io::Error),

//     #[error("Zip error :{0}")]
//     ZipError(zip::result::ZipError)
// }

// pub type Result<T> = std::result::Result<T, Error>;

//TODO: Properly create the error next time
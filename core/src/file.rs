use std::path::Path;
use anyhow::Result;
use tokio::fs::{self, File};

use crate::utils::hash::hash_the_file;


#[derive(Debug)]
pub struct FileMetaData {
    pub file: File,
    pub file_size: u64,
    pub filename: String,
    pub filehash: String,
}

impl FileMetaData {
   
    pub async fn new(filepath: String) -> Result<Self> {
        let filepath = Path::new(&filepath);
        let file = File::open(filepath).await?;
        let metadata = fs::metadata(filepath).await?;

        return Ok(FileMetaData {
            file: file,
            file_size: metadata.len(),
            filename: filepath.file_name().unwrap().to_string_lossy().into_owned(),
            filehash: hash_the_file(filepath).await?,
        });
    }
}

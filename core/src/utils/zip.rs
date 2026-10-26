use anyhow::{Result,Ok};
use zip::{ZipWriter, write::SimpleFileOptions};
pub async fn zip_folder(folder_path: String, output_zip_path: String) -> Result<()> {
    tokio::task::spawn_blocking(move || {
        println!("Compression Started");
        let outputfile = std::fs::File::create(output_zip_path)?;
        let mut zip_writer = ZipWriter::new(outputfile);

        let option = SimpleFileOptions::default().compression_method(zip::CompressionMethod::Zstd);

        for entry in walkdir::WalkDir::new(&folder_path) {
            let entry = entry?;
            let path = entry.path();
            let name = path.strip_prefix(&folder_path)?;

            if path.is_file() {
                zip_writer.start_file(name.to_string_lossy(), option)?;
                let mut file = std::fs::File::open(path)?;
                std::io::copy(&mut file, &mut zip_writer)?;
            } else if !name.as_os_str().is_empty() {
                zip_writer.add_directory(name.to_string_lossy(), option)?;
            }
        }
        zip_writer.finish()?;
        println!("Finished compressing");
        Ok(())
    })
    .await??;

    Ok(())
}

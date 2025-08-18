# flyx

A peer-to-peer file transfer tool built in Rust that works both locally and globally.

## Features

- **Local Mode**: Transfer files directly on your LAN
- **Global Mode**: Send files anywhere with a 6-digit code
- **Secure**: End-to-end encrypted transfers
- **Fast**: Direct peer-to-peer connection without cloud storage
- **Cross-Platform**: Works on Linux, macOS, and Windows

## Usage

```bash
# Send a file locally
flyx send filename.txt

# Send a file globally
flyx send filename.txt --global

# Receive a file locally
flyx receive

# Receive a file globally (with code)
flyx receive --global CODE
```

## Architecture

- **Local Mode**: Direct connections for LAN transfers
- **Global Mode**: WebRTC for secure global transfers via signaling server
- Files transfer directly between devices without going through the cloud

## Building

```bash
# Build client
cargo build --release --bin client

# Build server (for global mode)
cargo build --release --bin server
```

## License

MIT

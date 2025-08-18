use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", rename_all = "lowercase")]
pub enum SignalingMessage {
    Offer { sdp: String },
    Answer { sdp: String },
    ICECandidate { candidate: String },
    SlaveJoined
}

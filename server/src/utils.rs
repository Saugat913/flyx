use rand::distr::{Alphanumeric, SampleString};

pub fn generate_unique_id(len:usize) -> String {
    let mut rand = rand::rng();
    let alphanumeric_dist = Alphanumeric::default();
    let id = alphanumeric_dist.sample_string(&mut rand, len);
    return id;
}

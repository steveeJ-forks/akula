use anyhow::Result;

fn main() -> Result<()> {
    maybe_vergen_setup()

}

#[cfg(features ="vergen")]
fn maybe_vergen_setup() -> Result<()> {
use vergen::*;
    let mut config = Config::default();
    *config.git_mut().commit_timestamp_kind_mut() = TimestampKind::DateOnly;
    *config.git_mut().sha_kind_mut() = ShaKind::Short;
    vergen(config)
}


#[cfg(not(features ="vergen"))]
fn maybe_vergen_setup() -> Result<()> {
    Ok(())
}

use std::{
    env,
    fs::{self},
    io::Error,
    path::Path,
};

fn strip_file(f: impl AsRef<Path>) -> Result<(), Error> {
    let content = std::fs::read(&f)?;
    let stripped = &content[6..];
    fs::write(&f, stripped)
}

fn main() {
    let file = env::args()
        .skip(1)
        .next()
        .expect("Gimme a file name to strip");
    strip_file(file).expect("Coś nie pykło");
}

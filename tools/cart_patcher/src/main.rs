use std::{
    fs::File,
    io::{Read, Write},
};

const HEADER_SIZE: usize = 0;
const FILE_NAME: &str = "tensor.bin";
const BANK_SIZE: usize = 8192;
const MARKER_BANK: usize = 0x37;

// The task is to put a string "JebacPiS" (never enough) at the beginning
// of bank $37
fn main() {
    let mut f =
        File::open(format!("../../{}", FILE_NAME)).expect(&format!("'{}' not found", FILE_NAME));
    let mut buffer = vec![];
    f.read_to_end(&mut buffer).expect("unable to read_to_end()");
    println!("Cart file read");

    let (header, content) = buffer.split_at(HEADER_SIZE);
    let content: Vec<_> = content.iter().cloned().collect();

    let mut chunks: Vec<_> = content.chunks(BANK_SIZE).collect();

    let mut fake_chunk = vec![0xff as u8; BANK_SIZE];
    fake_chunk[0] = 'J' as u8;
    fake_chunk[1] = 'e' as u8;
    fake_chunk[2] = 'b' as u8;
    fake_chunk[3] = 'a' as u8;
    fake_chunk[4] = 'c' as u8;
    fake_chunk[5] = 'P' as u8;
    fake_chunk[6] = 'i' as u8;
    fake_chunk[7] = 'S' as u8;

    chunks[MARKER_BANK] = fake_chunk.as_slice();
    let content: Vec<_> = chunks.into_iter().flatten().cloned().collect();

    println!("Writing data to file");
    let mut f = File::create(format!("../../{}", FILE_NAME))
        .expect(&format!("unable to overwrite '{}'", FILE_NAME));
    f.write_all(header).expect("Unable to write to file");
    f.write_all(content.as_slice())
        .expect("Unable to write to file");
}

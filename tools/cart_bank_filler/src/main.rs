use std::{
    fs::File,
    io::{Read, Write},
};

const BANK_SIZE: usize = 8192;

fn main() {
    let mut f = File::open("../../tensor.car").expect("'tensor.car' not found");
    let mut buffer = vec![];
    f.read_to_end(&mut buffer).expect("unable to read_to_end()");
    println!("Cart file read");

    let total_size = buffer.len();
    let expected_size = BANK_SIZE * 128;
    let header_size = total_size - expected_size;
    println!("Header size: {}", header_size);

//    let header: Vec<_> = buffer.iter().take(header_size).cloned().collect();

    // buffer = buffer.iter().skip(header_size).cloned().collect();
    // println!("Buffer after trimming: {}", buffer.len());
    // if buffer.len() == expected_size {
    //     println!("which is expected");
    // } else {
    //     panic!("which is NOT expected");
    // }

    let mut chunks: Vec<_> = buffer.chunks(BANK_SIZE).collect();
    println!("Divided into {} banks", chunks.len());

    let fake_data = vec![7; BANK_SIZE];

    println!("Replacing banks with fake data");
    for i in 64..=127 {
        chunks[i] = fake_data.as_slice();
    }

    buffer = chunks.concat();

    println!("Writing data to file");
    let mut f = File::create("../../tensor_patch.car").expect("unable to open 'tensor_patch.car'");
//    f.write_all(&header).expect("Unable to write to file");
    f.write_all(&buffer).expect("Unable to write to file");
}

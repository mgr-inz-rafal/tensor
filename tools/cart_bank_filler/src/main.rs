use std::{
    fs::File,
    io::{Read, Write},
};

const BANK_SIZE: usize = 8192;
const AFFECTED_BANKS: u8 = 64;

const FAKE_DATA: &[&[u8; BANK_SIZE]; AFFECTED_BANKS as usize] = &[
    &[64; BANK_SIZE],
    &[65; BANK_SIZE],
    &[66; BANK_SIZE],
    &[67; BANK_SIZE],
    &[68; BANK_SIZE],
    &[69; BANK_SIZE],
    &[70; BANK_SIZE],
    &[71; BANK_SIZE],
    &[72; BANK_SIZE],
    &[73; BANK_SIZE],
    &[74; BANK_SIZE],
    &[75; BANK_SIZE],
    &[76; BANK_SIZE],
    &[77; BANK_SIZE],
    &[78; BANK_SIZE],
    &[79; BANK_SIZE],
    &[80; BANK_SIZE],
    &[81; BANK_SIZE],
    &[82; BANK_SIZE],
    &[83; BANK_SIZE],
    &[84; BANK_SIZE],
    &[85; BANK_SIZE],
    &[86; BANK_SIZE],
    &[87; BANK_SIZE],
    &[88; BANK_SIZE],
    &[89; BANK_SIZE],
    &[90; BANK_SIZE],
    &[91; BANK_SIZE],
    &[92; BANK_SIZE],
    &[93; BANK_SIZE],
    &[94; BANK_SIZE],
    &[95; BANK_SIZE],
    &[96; BANK_SIZE],
    &[97; BANK_SIZE],
    &[98; BANK_SIZE],
    &[99; BANK_SIZE],
    &[100; BANK_SIZE],
    &[101; BANK_SIZE],
    &[102; BANK_SIZE],
    &[103; BANK_SIZE],
    &[104; BANK_SIZE],
    &[105; BANK_SIZE],
    &[106; BANK_SIZE],
    &[107; BANK_SIZE],
    &[108; BANK_SIZE],
    &[109; BANK_SIZE],
    &[110; BANK_SIZE],
    &[111; BANK_SIZE],
    &[112; BANK_SIZE],
    &[113; BANK_SIZE],
    &[114; BANK_SIZE],
    &[115; BANK_SIZE],
    &[116; BANK_SIZE],
    &[117; BANK_SIZE],
    &[118; BANK_SIZE],
    &[119; BANK_SIZE],
    &[120; BANK_SIZE],
    &[121; BANK_SIZE],
    &[122; BANK_SIZE],
    &[123; BANK_SIZE],
    &[124; BANK_SIZE],
    &[125; BANK_SIZE],
    &[126; BANK_SIZE],
    &[127; BANK_SIZE],
];

fn main() {
    let mut f = File::open("../../tensor.bin").expect("'tensor.bin' not found");
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

    println!("Replacing banks with fake data");
    for i in 0u8..AFFECTED_BANKS {
        println!(
            "\tPatching bank {} with {:#2x}...",
            i as usize + 64,
            FAKE_DATA[i as usize][0]
        );
        chunks[i as usize + 64] = FAKE_DATA[i as usize];
    }

    buffer = chunks.concat();

    println!("Writing data to file");
    let mut f = File::create("../../tensor.bin").expect("unable to overwrite 'tensor.bin'");
    //    f.write_all(&header).expect("Unable to write to file");
    f.write_all(&buffer).expect("Unable to write to file");
}

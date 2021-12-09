use std::{env, fs::File, io::Write, path::Path};

fn calc_indices(index: usize) -> (usize, usize) {
    (index, 12 - index - 1)
}

fn build_rotation_table(file: &mut File, ring_index: usize) {
    file.write_all(format!("const RING_{}: &[&(usize, usize)] = &[", ring_index).as_bytes())
        .unwrap();
    let (s, e) = calc_indices(ring_index);
    for i in s..=e {
        file.write_all(format!("&({}, {}),", i, ring_index).as_bytes())
            .unwrap();
    }
    for i in s + 1..=e {
        file.write_all(format!("&({}, {}),", e, i).as_bytes())
            .unwrap();
    }
    for i in (s..e).rev() {
        file.write_all(format!("&({}, {}),", i, e).as_bytes())
            .unwrap();
    }
    for i in (s + 1..e).rev() {
        file.write_all(format!("&({}, {}),", ring_index, i).as_bytes())
            .unwrap();
    }
    file.write_all(b"];\n").unwrap();
}

fn main() {
    let out_dir = env::var_os("OUT_DIR").unwrap();
    let dest_path = Path::new(&out_dir).join("tables.rs");
    let mut file = File::create(dest_path).unwrap();
    for ring_index in 0..=5 {
        build_rotation_table(&mut file, ring_index)
    }
    file.write_all(b"const RINGS: &[&[&(usize, usize)]] = &[&RING_0, &RING_1, &RING_2, &RING_3, &RING_4, &RING_5];").unwrap();

    println!("cargo:rerun-if-changed=build.rs");
}

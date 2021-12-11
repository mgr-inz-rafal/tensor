use std::{fmt::Display, fs::File, io::Write, thread, time::Duration};

use crossterm::{cursor, style, terminal, ExecutableCommand};

include!(concat!(env!("OUT_DIR"), "/tables.rs"));

fn draw<'a, I, S>(map: I, starting_line: usize)
where
    I: Iterator<Item = S>,
    S: ToString + Display,
{
    let mut stdout = std::io::stdout();
    stdout
        .execute(terminal::Clear(terminal::ClearType::All))
        .unwrap();

    map.into_iter().enumerate().for_each(|(index, line)| {
        stdout
            .execute(cursor::MoveTo(0, index as u16 + starting_line as u16))
            .unwrap()
            .execute(style::Print(line))
            .unwrap();
    });
}

fn get(map: &Vec<String>, x: usize, y: usize) -> char {
    let row = map.get(y).unwrap();
    let char = row.chars().nth(x).unwrap();
    char
}

fn set(map: &mut Vec<String>, x: usize, y: usize, c: char) {
    let mut row = map.get(y).unwrap().clone();
    row.replace_range(x..x + 1, &c.to_string());
    let _ = std::mem::replace(&mut map[y], row.to_string());
}

fn to_offset(x: &u8, y: &u8) -> u8 {
    y * 20 + x + 4
}

fn write_data<'a, I>(
    file: &mut File,
    header: &str,
    data: I,
    index: usize,
    terminator: bool,
    direction: &str,
) where
    I: Iterator<Item = &'a (u8, u8)>,
{
    file.write_all(format!("{}_FRAME_{}_{}\n", direction.to_uppercase(), index, header).as_bytes())
        .unwrap();
    data.for_each(|(x, y)| {
        file.write_all(format!("    dta b({})\n", to_offset(x, y)).as_bytes())
            .unwrap()
    });
    if terminator {
        file.write_all("    dta($ff)\n".as_bytes()).unwrap()
    };
}

fn main() {
    // let m01 = "############";
    // let m02 = "#        # #";
    // let m03 = "#       #  #";
    // let m04 = "#      #   #";
    // let m05 = "#     #    #";
    // let m06 = "######     #";
    // let m07 = "#    #     #";
    // let m08 = "#    #     #";
    // let m09 = "#    #     #";
    // let m10 = "#          #";
    // let m11 = "#          #";
    // let m12 = "############";

    // let m01 = "####        ";
    // let m02 = "#  #        ";
    // let m03 = "#  #####    ";
    // let m04 = "#      #    ";
    // let m05 = "#     O#    ";
    // let m06 = "#    #######";
    // let m07 = "#          #";
    // let m08 = "#+         #";
    // let m09 = "######     #";
    // let m10 = "#      OO  #";
    // let m11 = "#     OOO  #";
    // let m12 = "############";

    let m01 = "123456789012".to_string();
    let m02 = "4abcdefghij3".to_string();
    let m03 = "3k01234567k4".to_string();
    let m04 = "2j7abcdef8l5".to_string();
    let m05 = "1i6t0123g9m6".to_string();
    let m06 = "0h5s1ab4h0n7".to_string();
    let m07 = "9g4r0dc5i1o8".to_string();
    let m08 = "8f3q9876j2p9".to_string();
    let m09 = "7e2ponmlk3q0".to_string();
    let m10 = "6d10987654r1".to_string();
    let m11 = "5cbazyxvuts2".to_string();
    let m12 = "432109876543".to_string();

    let map = vec![m01, m02, m03, m04, m05, m06, m07, m08, m09, m10, m11, m12];

    draw(map.iter(), 0);
    let mut step_increment = vec![0.0; RINGS.len()];
    for frame in 0..=8 {
        let mut rotated_map = map.clone();
        for ring_index in 0..RINGS.len() {
            let increment = ((12.0 - (ring_index * 2) as f64) / 9.0) - 0.01;
            step_increment[ring_index] += increment;
            let mut ring: Vec<_> = RINGS[ring_index].iter().cloned().collect();
            ring.rotate_right(step_increment[ring_index] as usize);
            rotated_map = apply_ring_transform(ring, ring_index, &rotated_map);
        }

        draw(rotated_map.iter(), 0);
        println!("\n\n{}", frame);
        thread::sleep(Duration::from_millis(500));
    }
}

fn apply_ring_transform(
    ring_data: Vec<&(usize, usize)>,
    ring_index: usize,
    map: &Vec<String>,
) -> Vec<String> {
    let mut ret = map.clone();
    RINGS[ring_index]
        .iter()
        .zip(ring_data)
        .for_each(|((tx, ty), (fx, fy))| {
            let c = get(&map, *fx, *fy);
            set(&mut ret, *tx, *ty, c);
        });
    ret
}

fn calc_indices(index: usize) -> (usize, usize) {
    (index, 12 - index - 1)
}

#[derive(Debug)]
struct StripElement {
    tile: char,
    original_position: (usize, usize),
    new_position: (usize, usize),
}

impl StripElement {
    fn new(tile: char, x: usize, y: usize) -> Self {
        Self {
            tile,
            original_position: (x, y),
            new_position: Default::default(),
        }
    }
}

fn build_strip(map: &Vec<String>, index: usize) -> Vec<StripElement> {
    let mut ret = vec![];

    let (s, e) = calc_indices(index);
    for i in s..=e {
        ret.push(StripElement::new(get(&map, i, index), i, index));
    }
    for i in s + 1..=e {
        ret.push(StripElement::new(get(&map, e, i), e, i));
    }
    for i in (s..e).rev() {
        ret.push(StripElement::new(get(&map, i, e), i, e));
    }
    for i in (s + 1..e).rev() {
        ret.push(StripElement::new(get(&map, index, i), index, i));
    }
    ret
}

#[cfg(test)]
mod tests {
    use itertools::Itertools;
    use test_case::test_case;

    use crate::calc_indices;

    use super::*;

    fn get_test_map() -> Vec<String> {
        let m01 = "123456789012".to_string();
        let m02 = "4abcdefghij3".to_string();
        let m03 = "3k01234567k4".to_string();
        let m04 = "2j7abcdef8l5".to_string();
        let m05 = "1i6t0123g9m6".to_string();
        let m06 = "0h5s1ab4h0n7".to_string();
        let m07 = "9g4r0dc5i1o8".to_string();
        let m08 = "8f3q9876j2p9".to_string();
        let m09 = "7e2ponmlk3q0".to_string();
        let m10 = "6d10987654r1".to_string();
        let m11 = "5cbazyxvuts2".to_string();
        let m12 = "432109876543".to_string();

        let map = vec![m01, m02, m03, m04, m05, m06, m07, m08, m09, m10, m11, m12];
        map
    }

    #[test_case(0 => "12345678901234567890123456789012345678901234".to_string())]
    #[test_case(1 => "abcdefghijklmnopqrstuvxyzabcdefghijk".to_string())]
    #[test_case(2 => "0123456789012345678901234567".to_string())]
    #[test_case(3 => "abcdefghijklmnopqrst".to_string())]
    #[test_case(4 => "012345678901".to_string())]
    #[test_case(5 => "abcd".to_string())]
    fn builds_strip(index: usize) -> String {
        let map = get_test_map();
        let strip = build_strip(&map, index);
        strip
            .iter()
            .map(|strip_element| strip_element.tile)
            .collect()
    }

    #[test_case(0 => (0, 11))]
    #[test_case(1 => (1, 10))]
    #[test_case(2 => (2, 9))]
    #[test_case(3 => (3, 8))]
    #[test_case(4 => (4, 7))]
    #[test_case(5 => (5, 6))]
    fn calcs_indices(index: usize) -> (usize, usize) {
        calc_indices(index)
    }
}

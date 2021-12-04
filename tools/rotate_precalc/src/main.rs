use std::{fmt::Display, fs::File, io::Write, os::unix::prelude::FileExt, thread, time::Duration};

use crossterm::{cursor, style, terminal, ExecutableCommand};

const MID_POINT: f64 = 5.5;

fn draw<'a, I, S>(map: I, starting_line: usize)
where
    I: Iterator<Item = S>,
    S: ToString + Display,
{
    let mut stdout = std::io::stdout();

    map.into_iter().enumerate().for_each(|(index, line)| {
        stdout
            .execute(cursor::MoveTo(0, index as u16 + starting_line as u16))
            .unwrap()
            .execute(style::Print(line))
            .unwrap();
    });
}

fn get(map: &[&str], x: f64, y: f64) -> Option<char> {
    let ix = x.round() as i32;
    let iy = y.round() as i32;
    if ix < 0 || ix > 11 || iy < 0 || iy > 11 {
        return None;
    };

    let ix = ix as usize;
    let iy = iy as usize;

    let row = map.get(iy).unwrap();
    let char = row.chars().nth(ix).unwrap();
    Some(char)
}

fn rotate(map: &[&str], angle: f64, rotation: &mut RotateDef) -> Vec<String> {
    let angle = angle.to_radians();

    let mut new_map = Vec::with_capacity(12);
    for y in 0..=11 {
        let mut row = Vec::with_capacity(12);
        for x in 0..=11 {
            let rx = angle.cos() * (x as f64 - MID_POINT) - angle.sin() * (y as f64 - MID_POINT)
                + MID_POINT;
            let ry = angle.sin() * (x as f64 - MID_POINT)
                + angle.cos() * (y as f64 - MID_POINT)
                + MID_POINT;

            let maybe_tile = get(&map, rx, ry);
            if maybe_tile.is_some() {
                rotation.from.push((rx.round() as i8, ry.round() as i8));
                rotation.to.push((x as i8, y as i8));
            } else {
                rotation.empty.push((x as i8, y as i8));
            }

            let new_tile = maybe_tile.unwrap_or(' ');
            row.push(new_tile);
        }
        new_map.push(row.iter().collect::<String>());
    }
    new_map
}

#[derive(Default)]
struct RotateDef {
    from: Vec<(i8, i8)>,
    to: Vec<(i8, i8)>,
    empty: Vec<(i8, i8)>,
}

fn main() {
    let m01 = "############";
    let m02 = "#        # #";
    let m03 = "#       #  #";
    let m04 = "#      #   #";
    let m05 = "#     #    #";
    let m06 = "######     #";
    let m07 = "#    #     #";
    let m08 = "#    #     #";
    let m09 = "#    #     #";
    let m10 = "#          #";
    let m11 = "#          #";
    let m12 = "############";

    let m01 = "####        ";
    let m02 = "#  #        ";
    let m03 = "#  #####    ";
    let m04 = "#      #    ";
    let m05 = "#     O#    ";
    let m06 = "#    #######";
    let m07 = "#          #";
    let m08 = "#+         #";
    let m09 = "######     #";
    let m10 = "#      OO  #";
    let m11 = "#     OOO  #";
    let m12 = "############";

    let map = vec![m01, m02, m03, m04, m05, m06, m07, m08, m09, m10, m11, m12];

    let mut rotations = vec![];

    let mut current_frame = 0;
    for i in (10..=90).step_by(10) {
        let mut stdout = std::io::stdout();
        stdout
            .execute(cursor::Hide)
            .unwrap()
            .execute(terminal::Clear(terminal::ClearType::All))
            .unwrap()
            .execute(cursor::MoveTo(20, 0))
            .unwrap()
            .execute(style::Print(format!("angle: {}", i)))
            .unwrap();

        let mut rotation = RotateDef::default();
        current_frame += 1;

        let rotated_map = rotate(&map, i as f64, &mut rotation);
        rotations.push(rotation);

        draw(map.iter(), 0);
        draw(rotated_map.into_iter(), 20);

        if i == 90 || i == 180 || i == 360 || i == 270 {
            //thread::sleep(Duration::from_secs(5));
        } else {
            thread::sleep(Duration::from_millis(1000 / 50));
        }
    }

    rotations.iter().enumerate().for_each(|(index, rotation)| {
        let mut file = File::create(format!("rotate_left_frame_{}.txt", index)).unwrap();
        file.write_all("---------------------- from ----------------------\n".as_bytes())
            .unwrap();
        rotation.from.iter().for_each(|(x, y)| {
            file.write_all(format!("    dta b({}), b({})\n", x, y).as_bytes())
                .unwrap()
        });
        file.write_all("----------------------  to  ----------------------\n".as_bytes())
            .unwrap();
        rotation.to.iter().for_each(|(x, y)| {
            file.write_all(format!("    dta b({}), b({})\n", x, y).as_bytes())
                .unwrap()
        });
        file.write_all("---------------------- empty----------------------\n".as_bytes())
            .unwrap();
        rotation.empty.iter().for_each(|(x, y)| {
            file.write_all(format!("    dta b({}), b({})\n", x, y).as_bytes())
                .unwrap()
        });
    });

    let mut file = File::create("rotate_left_lut.txt").unwrap();

    file.write_all(format!("\nframe {}\n", current_frame).as_bytes())
        .unwrap();
}

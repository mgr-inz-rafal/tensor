use std::{fmt::Display, fs::File, io::Write, thread, time::Duration};

use crossterm::{cursor, style, terminal, ExecutableCommand};

use itertools::Itertools;

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

    (!(ix < 0 || ix > 11 || iy < 0 || iy > 11)).then(|| {
        let ix = ix as usize;
        let iy = iy as usize;

        let row = map.get(iy).unwrap();
        let char = row.chars().nth(ix).unwrap();
        char
    })
}

fn rotate(map: &[&str], angle: f64, rotation: &mut RotateDef) -> Vec<String> {
    let angle = angle.to_radians();

    (0..=11)
        .map(|y| {
            (0..=11)
                .map(|x| {
                    let rx = angle.cos() * (x as f64 - MID_POINT)
                        - angle.sin() * (y as f64 - MID_POINT)
                        + MID_POINT;
                    let ry = angle.sin() * (x as f64 - MID_POINT)
                        + angle.cos() * (y as f64 - MID_POINT)
                        + MID_POINT;

                    get(&map, rx, ry).map_or_else(
                        || {
                            rotation.empty.push((x as i8, y as i8));
                            ' '
                        },
                        |new_tile| {
                            rotation.from.push((rx.round() as i8, ry.round() as i8));
                            rotation.to.push((x as i8, y as i8));

                            new_tile
                        },
                    )
                })
                .collect::<String>()
        })
        .collect_vec()
}

#[derive(Default)]
struct RotateDef {
    from: Vec<(i8, i8)>,
    to: Vec<(i8, i8)>,
    empty: Vec<(i8, i8)>,
}

fn write_data<'a, I: Iterator<Item = &'a (i8, i8)>>(file: &mut File, header: &str, data: I) {
    file.write_all(
        format!("---------------------- {} ----------------------\n", header).as_bytes(),
    )
    .unwrap();
    data.for_each(|(x, y)| {
        file.write_all(format!("    dta b({}), b({})\n", x, y).as_bytes())
            .unwrap()
    });
    file.write_all("    dta($ff)\n".as_bytes()).unwrap();
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

    for i in (10..=90).step_by(10) {
        let mut stdout = std::io::stdout();
        stdout
            .execute(terminal::Clear(terminal::ClearType::All))
            .unwrap()
            .execute(cursor::MoveTo(20, 0))
            .unwrap()
            .execute(style::Print(format!("angle: {}", i)))
            .unwrap();

        let mut rotation = RotateDef::default();

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
        write_data(&mut file, "from", rotation.from.iter());
        write_data(&mut file, "to", rotation.to.iter());
        write_data(&mut file, "empty", rotation.empty.iter());
    });
}

use std::fs;

struct Point {
    x: i32,
    y: i32,
}

struct Line {
    from: Point,
    to: Point,
}

static DIAGRAM_SIZE: usize = 1000;
static INPUT_FILE: &str = "input";

fn parse_point(line: &str) -> Point {
    let mut value_iter = line.trim().split(",").take(2);

    let x = match value_iter.next() {
        Some(v) => v.parse().unwrap(),
        None => -1,
    };
    let y = match value_iter.next() {
        Some(v) => v.parse().unwrap(),
        None => -1,
    };

    return Point { x, y };
}

fn parse_line(line: &str) -> Line {
    let mut point_iter = line.split("->").take(2).map(parse_point);

    let from = point_iter.next().unwrap();
    let to = point_iter.next().unwrap();

    return Line { from, to };
}

fn parse_lines(contents: &String) -> Vec<Line> {
    return contents.trim().split("\n").map(parse_line).collect();
}

fn index(x: i32, y: i32) -> usize {
    return (y as usize) * DIAGRAM_SIZE + (x as usize);
}

fn get_direction(delta: &i32) -> i32 {
    return if *delta < 0 {
        -1
    } else if *delta > 0 {
        1
    } else {
        0
    };
}

fn draw_line(diagram: &mut Vec<i32>, line: &Line) {
    let (x_from, x_to): (i32, i32) = (line.from.x, line.to.x);
    let (y_from, y_to): (i32, i32) = (line.from.y, line.to.y);

    let mut x_offset = 0;
    let mut y_offset = 0;
    let x_delta = x_to - x_from;
    let y_delta = y_to - y_from;
    let mut y_dir = get_direction(&y_delta);
    let mut x_dir = get_direction(&x_delta);

    loop {
        if (x_dir < 0 && x_offset < x_delta) || (x_dir > 0 && x_offset > x_delta) {
            x_dir = 0;
        }
        if (y_dir < 0 && y_offset < y_delta) || (y_dir > 0 && y_offset > y_delta) {
            y_dir = 0;
        }

        if x_dir == 0 && y_dir == 0 {
            break;
        }
        let x = x_from + x_offset;
        let y = y_from + y_offset;

        y_offset += y_dir;
        x_offset += x_dir;
        let index = index(x, y);

        diagram[index] += 1;
    }
}

fn main() {
    let contents: String = fs::read_to_string(INPUT_FILE).expect("Failed to read file.");

    let lines = parse_lines(&contents);
    let mut diagram = vec![0; DIAGRAM_SIZE * DIAGRAM_SIZE];

    for line in lines {
        draw_line(&mut diagram, &line);
    }
    let score = diagram.iter().filter(|item| **item >= 2).count();

    println!("Score => {}", score);
}

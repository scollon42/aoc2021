use std::collections::HashSet;
use std::fs;

fn get_lines(file_path: &str) -> Vec<String> {
    let lines: Vec<String> = fs::read_to_string(file_path)
        .expect("Failed to read file.")
        .trim()
        .lines()
        .map(String::from)
        .collect();

    return lines;
}

fn get_dots_from_lines(lines: &Vec<String>) -> HashSet<(u32, u32)> {
    let dots: HashSet<(u32, u32)> = lines
        .iter()
        .take_while(|line| !line.trim().is_empty())
        .map(|line| {
            let mut iter = line.trim().split(",").take(2);

            let x: u32 = match iter.next() {
                Some(v) => v.parse().unwrap(),
                None => 0,
            };

            let y: u32 = match iter.next() {
                Some(v) => v.parse().unwrap(),
                None => 0,
            };

            return (x, y);
        })
        .collect();

    return dots;
}

fn get_instructions_from_lines(lines: &Vec<String>) -> Vec<(String, u32)> {
    let instructions = lines
        .iter()
        .skip_while(|line| !line.trim().is_empty())
        .filter(|line| !line.trim().is_empty())
        .map(|line| {
            let line = line.replace("fold along ", "");
            let mut parts = line.split("=").take(2);

            let axis = parts
                .next()
                .expect(format!("Failed to get axis in line {}", line).as_str())
                .to_string();

            let instruction: u32 = parts
                .next()
                .expect(format!("Failed to get instruction in line {}", line).as_str())
                .parse()
                .unwrap();

            return (axis.to_owned(), instruction.to_owned());
        })
        .collect::<Vec<(String, u32)>>();

    return instructions;
}

fn print_board(dots: &HashSet<(u32, u32)>, max_x: u32, max_y: u32) {
    for y in 0..=max_y {
        for x in 0..=max_x {
            let dot = dots.iter().find(|(dx, dy)| *dx == x && *dy == y);

            match dot {
                Some(_v) => print!("#"),
                None => print!("."),
            };
        }
        println!("");
    }
}

fn find_borders(dots: &HashSet<(u32, u32)>) -> (u32, u32) {
    let mut max_x: u32 = 0;
    let mut max_y: u32 = 0;

    for (x, y) in dots {
        max_x = max_x.max(*x);
        max_y = max_y.max(*y);
    }

    return (max_x, max_y);
}

fn main() {
    let lines: Vec<String> = get_lines("input.txt");
    let mut dots = get_dots_from_lines(&lines);

    let instructions = get_instructions_from_lines(&lines);

    for (a, i) in &instructions {
        println!("Fold along {}={}.", a, i);
    }

    for (axis, move_size) in &instructions {
        dots = dots
            .iter()
            .map(|&(x, y)| {
                if axis == "x" {
                    if x < *move_size {
                        return (x, y);
                    }

                    let distance = x - *move_size;

                    let new_x = x - 2 * distance;

                    return (new_x, y);
                } else {
                    if y < *move_size {
                        return (x, y);
                    }

                    let distance = y - *move_size;

                    let new_y = y - 2 * distance;

                    return (x, new_y);
                }
            })
            .collect();
    }

    let (max_x, max_y) = find_borders(&dots);

    print_board(&dots, max_x, max_y);
}

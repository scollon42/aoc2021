use std::fs;

fn main() {
    let content = fs::read_to_string("input.txt").expect("failed to read file.");
    let mut flashing_count: u32 = 0;

    let mut values: Vec<u32> = content
        .trim()
        .split("\n")
        .map(|line| {
            line.trim()
                .chars()
                .map(|n| n.to_digit(10).unwrap())
                .collect::<Vec<u32>>()
        })
        .flatten()
        .collect();

    for step in 1..=2000 {
        let mut flashing: Vec<(i32, i32)> = Vec::new();

        for y in 0..=9 {
            for x in 0..=9 {
                let mut v = values[y * 10 + x] + 1;
                
                if v > 9 {
                    flashing_count += 1;
                    flashing.push((x as i32, y as i32));
                    v = 0;
                }

                values[y * 10 + x] = v;
            }
        }

        while flashing.len() > 0 {
            let (x, y) = flashing.pop().expect("error");
            
            let adjacent: Vec<(i32, i32)> = vec![(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1), (x - 1, y -1), (x + 1, y - 1), (x - 1, y + 1), (x + 1, y + 1)];

            adjacent.iter().filter(|(x, y)| {
                return *x >= 0 && *y >= 0 && *x < 10 && *y < 10;
            }).for_each(|(x, y)| {
                let index = *y * 10 + *x;
                let mut v = values[index as usize];

                if v == 0 { return; }

                if v + 1 > 9 {
                    flashing_count += 1;
                    flashing.push((*x, *y));
                    v = 0;
                } else {
                    v = v + 1;
                }

                values[index as usize] = v;
            });
        }

        if values.iter().all(|v| *v == 0) {
            println!("sync at step {}", step);
            break;
        }

        for y in 0..=9 {
            for x in 0..=9 {
                print!("{}", values[y * 10 + x]);
            }
            println!("");
        }
        println!("");
    }

    println!("Flashed : {}", flashing_count);
}

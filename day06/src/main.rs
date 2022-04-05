use std::fs;

fn simulate_fishes(values: &Vec<i32>, days: i32) -> u128 {
    let mut counter: Vec<u128> = vec![0, 0, 0, 0, 0, 0, 0, 0, 0];

    values.iter().for_each(|fish| {
        counter[*fish as usize] += 1;
    });

    for _day in 1..=days {
        let zero_count = counter[0];

        counter[0] = 0;

        for i in 1..=8 {
            counter[i - 1] = counter[i];
            counter[i] = 0;
        }

        counter[6] += zero_count;
        counter[8] = zero_count;
    }

    let result: u128 = counter.iter().sum();

    return result;
}

fn main() {
    let contents: String = fs::read_to_string("input.txt").expect("Failed to read file.");

    let fishes: Vec<i32> = contents
        .trim()
        .split(",")
        .map(|number| number.trim().parse().unwrap())
        .collect();

    println!("result => {}", simulate_fishes(&fishes, 256));
}

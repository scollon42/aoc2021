use std::fs;

struct HighMap {
    values: Vec<u32>,
    col_size: usize,
    line_size: usize,
}

impl HighMap {
    fn index_at(self: &Self, x: usize, y: usize) -> usize {
        return y * self.line_size + x;
    }

    fn get(self: &Self, x: usize, y: usize) -> u32 {
        self.values[self.index_at(x, y)]
    }

    fn is_low_point(self: &Self, x: usize, y: usize) -> bool {
        let value = self.get(x, y);

        if x > 0 && value >= self.get(x - 1, y) {
            return false;
        }
        if x + 1 < self.line_size && value >= self.get(x + 1, y) {
            return false;
        }
        if y > 0 && value >= self.get(x, y - 1) {
            return false;
        }
        if y + 1 < self.col_size && value >= self.get(x, y + 1) {
            return false;
        }

        return true;
    }
}

fn build_high_map(content: &String) -> HighMap {
    let line_size = content.chars().take_while(|c| *c != '\n').count();
    let values: Vec<u32> = content
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

    let col_size = values.len() / line_size;

    return HighMap {
        values,
        line_size,
        col_size,
    };
}

fn low_point_indexes(high_map: &HighMap) -> Vec<(usize, usize)> {
    let mut low_point_indexes: Vec<(usize, usize)> = Vec::new();

    for y in 0..high_map.col_size {
        for x in 0..high_map.line_size {
            if high_map.is_low_point(x, y) {
                low_point_indexes.push((x, y));
            }
        }
    }

    return low_point_indexes;
}

fn find_basin_size(high_map: &HighMap, x: i32, y: i32, visited: &mut Vec<(i32, i32)>) -> u32 {
    if visited.contains(&(x, y)) {
        return 0;
    }

    visited.push((x, y));

    if x < 0 || y < 0 || x >= high_map.line_size as i32 || y >= high_map.col_size as i32 {
        return 0;
    }

    if high_map.get(x as usize, y as usize) == 9 {
        return 0;
    }
    return 1
        + find_basin_size(high_map, x - 1, y, visited)
        + find_basin_size(high_map, x + 1, y, visited)
        + find_basin_size(high_map, x, y - 1, visited)
        + find_basin_size(high_map, x, y + 1, visited);
}

fn sum_of_low_point_scores(high_map: &HighMap, low_point_indexes: &Vec<(usize, usize)>) -> u32 {
    let scores: u32 = low_point_indexes
        .iter()
        .map(|(x, y)| {
            let score: u32 = high_map.get(*x, *y) + 1;
            return score;
        })
        .sum();

    return scores;
}

fn calculate_largest_basins_product(high_map: &HighMap, low_point_indexes: &Vec<(usize, usize)>) -> u32 {
    let mut visited: Vec<(i32, i32)> = Vec::new();

    let mut basins: Vec<u32> = low_point_indexes.iter().map(|(x, y)| {
        return find_basin_size(&high_map, *x as i32, *y as i32, &mut visited);
    }).collect();


    basins.sort();

    basins.reverse();

    let result: u32 = basins.iter().take(3).product();

    return result;
} 

fn main() {
    let content: String = fs::read_to_string("input.txt").expect("Failed to open file.");

    let high_map = build_high_map(&content);

    let low_point_indexes = low_point_indexes(&high_map);

    println!(
        "Part one => {}",
        sum_of_low_point_scores(&high_map, &low_point_indexes)
    );

    let largest_basins_product = calculate_largest_basins_product(&high_map, &low_point_indexes);

    println!("Part two => {}", largest_basins_product);
}

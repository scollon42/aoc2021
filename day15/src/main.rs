use std::cmp::Ordering;
use std::{collections::BinaryHeap, fs};

// To use BinaryHeap
#[derive(Copy, Clone, Eq, PartialEq)]
struct State {
    position: usize,
    cost: usize,
}

impl Ord for State {
    fn cmp(&self, other: &Self) -> Ordering {
        other
            .cost
            .cmp(&self.cost)
            .then_with(|| self.position.cmp(&other.position))
    }
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

struct Graph {
    edges: Vec<Vec<(usize, usize)>>,
}

impl Graph {
    fn new() -> Graph {
        Graph { edges: Vec::new() }
    }

    fn add_node(self: &mut Self, index: usize) {
        self.edges.insert(index, Vec::new())
    }

    fn add_edges(self: &mut Self, index: usize, edge: &(usize, usize)) {
        self.edges[index].push(edge.clone());
    }

    fn shortest_paths(
        self: &mut Self,
        start_position: usize,
        end_position: usize,
    ) -> Option<usize> {
        let mut shortest_paths: Vec<usize> = vec![usize::MAX; self.edges.len()];
        let mut heap = BinaryHeap::new();

        shortest_paths[start_position] = 0;
        heap.push(State {
            position: start_position,
            cost: 0,
        });

        while let Some(state) = heap.pop() {
            if state.position == end_position {
                return Some(state.cost);
            }

            if state.cost > shortest_paths[state.position] {
                continue;
            }

            for (edge_position, move_cost) in &self.edges[state.position] {
                let next_state = State {
                    position: *edge_position,
                    cost: state.cost + *move_cost,
                };

                if next_state.cost >= shortest_paths[next_state.position] {
                    continue;
                }

                println!(
                    "From {} to {} at cost {}",
                    state.position, next_state.position, next_state.cost
                );

                shortest_paths[next_state.position] = next_state.cost;

                heap.push(next_state);
            }
        }

        return None;
    }
}

fn get_adjacent_coordinates(
    x: &usize,
    y: &usize,
    max_x: &usize,
    max_y: &usize,
) -> Vec<(usize, usize)> {
    let x = *x as i32;
    let y = *y as i32;

    let adjacent: Vec<(i32, i32)> = vec![(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)];

    let filtered: Vec<(usize, usize)> = adjacent
        .iter()
        .filter(|(ax, ay)| *ax >= 0 && *ay >= 0 && *ax < *max_x as i32 && *ay < *max_y as i32)
        .map(|(ax, ay)| (*ax as usize, *ay as usize))
        .collect();

    return filtered;
}

fn scaled_map(map: &Vec<usize>, max_x: &usize, max_y: &usize, scale: &usize) -> Vec<usize> {
    let mut new_map = vec![0; map.len() * scale * scale];
    let scaled_max_x = max_x * scale;
    let scaled_max_y = max_y * scale;

    for y in 0..scaled_max_y {
        let local_y = y % max_y;

        for x in 0..scaled_max_x {
            let local_x = x % max_x;

            let modifier = 1 * (x / max_x) + 1 * (y / max_y);

            let value = (map[local_y * max_y + local_x] + modifier) % 9;

            let value: usize = if value == 0 { 9 } else { value };

            new_map.insert(y * scaled_max_y + x, value);
        }
    }

    return new_map;
}

fn main() {
    let lines: Vec<String> = fs::read_to_string("input.txt")
        .expect("Failed to read file")
        .lines()
        .map(String::from)
        .collect();

    let max_y = lines.len();
    let max_x = lines.first().expect("failed to get first line").len();

    let map: Vec<usize> = lines
        .iter()
        .flat_map(|line| line.trim().chars().map(|c| c.to_digit(10).unwrap()))
        .map(|v| v as usize)
        .collect();
    let scale = 5;
    let map = scaled_map(&map, &max_x, &max_y, &scale);

    let scaled_max_x = max_x * scale;
    let scaled_max_y = max_y * scale;

    let mut graph = Graph::new();

    for y in 0..scaled_max_y {
        for x in 0..scaled_max_x {
            let index = y * scaled_max_y + x;

            graph.add_node(index);

            let adjacent = get_adjacent_coordinates(&x, &y, &scaled_max_x, &scaled_max_y);

            for (ax, ay) in adjacent {
                let adj_index = ay * scaled_max_y + ax;
                let cost: usize = map[adj_index];

                graph.add_edges(index, &(adj_index, cost));
            }
        }
    }

    let cost = graph
        .shortest_paths(0, graph.edges.len() - 1)
        .expect("No path found!");

    println!("Shortest path cost is {}", cost)
}

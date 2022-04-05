use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use std::fs;
use std::rc::Rc;

struct Node {
    name: &'static str,
    big: bool,
    edges: Vec<Rc<RefCell<Node>>>,
}

impl Node {
    fn new(name: &'static str) -> Rc<RefCell<Node>> {
        let big = name.to_string().to_uppercase() == name.to_string();

        Rc::new(RefCell::new(Node {
            name,
            big,
            edges: Vec::new(),
        }))
    }

    fn counts_path_to(
        self: &Self,
        target: &'static str,
        current_path: &mut Vec<&'static str>,
        seen: &mut HashMap<&'static str, u32>,
    ) -> u32 {
        let mut path_count: u32 = 0;

        current_path.push(self.name);

        seen.entry(self.name).or_insert(0);

        if !self.big {
            seen.insert(self.name, seen[self.name] + 1);
        }

        if self.name == target {
            if !self.big {
                seen.insert(self.name, seen[self.name] - 1);
            }

            current_path.pop();
            return path_count + 1;
        }

        for e in &self.edges {
            let e = e.borrow();

            if !e.big
                && seen.contains_key(e.name)
                && seen[e.name] >= 1
                && seen.values().any(|&v| v >= 2)
            {
                continue;
            }

            if (e.name == "start" || e.name == "end")
                && seen.contains_key(e.name)
                && seen[e.name] >= 1
            {
                continue;
            }

            path_count += e.counts_path_to(target, current_path, seen);
        }

        if !self.big {
            seen.insert(self.name, seen[self.name] - 1);
        }

        current_path.pop();

        return path_count;
    }
}

fn get_nodes_list(file_lines: &Vec<String>) -> HashSet<String> {
    let nodes: HashSet<String> = file_lines
        .iter()
        .flat_map(|line| line.trim().split("-").map(|node| node.trim()))
        .filter(|n| *n != "end" && *n != "start")
        .map(String::from)
        .collect::<HashSet<String>>();

    return nodes;
}

fn build_nodes(node_list: &HashSet<String>) -> HashMap<&str, Rc<RefCell<Node>>> {
    let mut nodes: HashMap<&str, Rc<RefCell<Node>>> = HashMap::new();

    nodes.insert("start", Node::new("start"));
    nodes.insert("end", Node::new("end"));

    for n in node_list {
        // FIXME maybe unsafe ?
        let s = n.to_owned().into_boxed_str();
        let node_name = Box::leak(s);
        nodes.insert(node_name, Node::new(node_name));
    }
    return nodes;
}

fn get_links_list(file_lines: &Vec<String>) -> Vec<(&str, &str)> {
    let links: Vec<(&str, &str)> = file_lines
        .iter()
        .map(|line| {
            let n: Vec<&str> = line.trim().split("-").map(|n| n.trim()).take(2).collect();
            return (n[0], n[1]);
        })
        .collect();

    return links;
}

fn main() {
    let file_lines: Vec<String> = fs::read_to_string("input.txt")
        .expect("Failed to read file")
        .trim()
        .lines()
        .map(String::from)
        .collect();

    let node_list = get_nodes_list(&file_lines);
    let nodes = build_nodes(&node_list);
    let links = get_links_list(&file_lines);

    for (n1, n2) in &links {
        let mut n1_mut = nodes[n1].borrow_mut();
        let mut n2_mut = nodes[n2].borrow_mut();

        n1_mut.edges.push(nodes[n2].clone());
        n2_mut.edges.push(nodes[n1].clone());
    }

    let root = &nodes["start"];

    let path_count = root
        .borrow()
        .counts_path_to("end", &mut Vec::new(), &mut HashMap::new());
    println!("{}", path_count);
}

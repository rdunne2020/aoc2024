use std::fs;
use std::collections::HashMap;
fn main() {
    let file_string: String = fs::read_to_string("input.in").unwrap().trim_end().to_string();
    let mut heat_map: HashMap<&i32,i32> = HashMap::new();
    let mut first_list: Vec<i32> = Vec::new();
    let mut second_list: Vec<i32> = Vec::new();
    for line in file_string.split("\n") {
        let mut iter = line.split_ascii_whitespace();
        let first_list_num: i32 = iter.next().unwrap().parse::<i32>().unwrap();
        let second_list_num: i32 = iter.next().unwrap().parse::<i32>().unwrap();
        first_list.push(first_list_num);
        second_list.push(second_list_num);
    }

    first_list.sort();
    second_list.sort();

    for i in &first_list {
        heat_map.insert(i, 0);
    }

    for i in &second_list {
        if heat_map.get(i).is_some() {
            let count = heat_map.get(i).unwrap();
            heat_map.insert(i, count+1);
        }
    }

    let mut similarity_score: i32 = 0;
    for (k,v) in &heat_map {
        if *v > 0 {
            println!("{} -> {}", k, v);
            similarity_score += *k * *v;
        }
    }
    println!("Sim Score: {}", similarity_score);

    let mut accumulator: i32 = 0;
    for i in 0..first_list.len() {
        accumulator += (first_list[i] - second_list[i]).abs();
    }
    println!("Acc: {}", accumulator);
}

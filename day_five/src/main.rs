use std::collections::HashMap;
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let input: String = fs::read_to_string("testinput.in")?;
    let sections: Vec<&str> = input.split("\n\n").map(|s| s.trim()).collect();

    let mut orderings: Vec<(u32, u32)> = Vec::new();
    for order in sections[0].split("\n").collect::<Vec<&str>>() {
        let preceeding_page: u32 = order.split("|").collect::<Vec<&str>>()[0]
            .parse::<u32>()
            .unwrap();
        let succeeding_page: u32 = order.split("|").collect::<Vec<&str>>()[1]
            .parse::<u32>()
            .unwrap();
        orderings.push((preceeding_page, succeeding_page));
    }

    let mut orderings_map: HashMap<u32, Vec<u32>> = HashMap::new();

    for o in orderings {
        if let Some(vec) = orderings_map.get_mut(&o.0) {
            vec.push(o.1);
        } else {
            orderings_map.insert(o.0, vec![o.1]);
        }
    }

    println!("{:?}", orderings_map);

    let mut pages: Vec<Vec<u32>> = Vec::new();
    for pagelist in sections[1].split("\n").collect::<Vec<&str>>() {
        let pl = pagelist
            .split(",")
            .collect::<Vec<&str>>()
            .into_iter()
            .map(|p| p.parse::<u32>().unwrap())
            .collect::<Vec<u32>>();
        pages.push(pl);
    }

    for l in pages {
        let mut in_order: bool = false;
        for p in l {
            // Detect if this list is in the right order
        }
    }

    Ok(())
}

use std::collections::HashMap;
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // let input: String = fs::read_to_string("testinput.in")?;
    let input: String = fs::read_to_string("input.in")?;
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

    // println!("{:?}", orderings_map);

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

    let mut page_values: u32 = 0;

    // Part One
    // '_big: for list in pages {
    //     let mut in_order: bool = true;
    //     'little: for idx in 0..list.len()-1 {
    //         // Detect if this list is in the right order
    //         '_check: for subsequent_idx in idx+1..list.len() {
    //             let rules_for_num = orderings_map.get(&list[subsequent_idx]);
    //             if let Some(succeeding_number_list) = rules_for_num {
    //                 if succeeding_number_list.contains(&list[idx]) {
    //                     in_order = false;
    //                     break 'little;
    //                 }
    //             }
    //         }
    //     }
    //     if in_order {
    //         // println!("{:?} is valid", list);
    //         let middle_idx = list.len() / 2;
    //         page_values += list[middle_idx];
    //     }
    // }
    let mut counter = 0;
    '_big: for mut list in pages.clone() {
        let mut in_order: bool = true;
        let mut idx = 0;
        '_little: while idx < list.len()-1 {
            // Detect if this list is in the right order
            'check: for subsequent_idx in idx+1..list.len() {
                let rules_for_num = orderings_map.get(&list[subsequent_idx]);
                // There is a later number that should come before current number
                if let Some(succeeding_number_list) = rules_for_num {
                    if succeeding_number_list.contains(&list[idx]) {
                        list.swap(idx, subsequent_idx);
                        in_order = false;
                        idx = usize::MAX;
                        break 'check;
                    }
                }
            }
            if idx < usize::MAX {
                idx+=1;
            } else {
                idx = 0;
            }
        }
        if !in_order {
            println!("{:?} was invalid {:?} is valid", pages[counter], list);
            let middle_idx = list.len() / 2;
            page_values += list[middle_idx];
        }
        counter += 1;
    }

    println!("Values: {}", page_values);

    Ok(())
}

use std::fs;
use regex::Regex;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let input_data = fs::read_to_string("input.in")?;

    let re_string = Regex::new(r"(mul\([0-9]{1,3},[0-9]{1,3}\)|do\(\)|don't\(\))")?;
    let re_operand_string = Regex::new(r"[0-9]{1,3},[0-9]{1,3}")?;

    let mut result: i32 = 0;
    let mut mul_enabled: bool = true;
    let operations: Vec<&str> = re_string.find_iter(input_data.as_ref()).map(|m| m.as_str()).collect();
    for o in operations {
        if o == "do()" {
            mul_enabled = true;
        } else if o == "don't()" {
            mul_enabled = false;
        } else {
            if !mul_enabled {
                continue;
            }
            let op_match = re_operand_string.find(o).unwrap().as_str();
            let operands: Vec<&str> = op_match.split(',').collect();
            let num_1: i32 = operands.get(0).unwrap().parse::<i32>()?;
            let num_2: i32 = operands.get(1).unwrap().parse::<i32>()?;
            result += num_1 * num_2;
        }
    }
    println!("{}", result);
    Ok(())
}

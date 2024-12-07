const std = @import("std");

const word = "XMAS";
const x_word = "MAS";
//  This is fucking stupid. Every letter will search all around itself for the next correct letter allowing for zigzagging
//  Don't make it recursive, just do a while loop in every direction
fn find_xmas(current_letter_idx: u8, x_pos: i32, y_pos: i32, puzzle: std.ArrayList([]u8)) bool {
    // If the current letter matches what's to be expected
    if (current_letter_idx >= word.len) return true;
    if (x_pos >= puzzle.items.len or x_pos < 0) return false;
    if (y_pos >= puzzle.items[0].len or y_pos < 0) return false;
    if (puzzle.items[@intCast(x_pos)][@intCast(y_pos)] == word[current_letter_idx]) {
        // If you've seen 4 letters you're good
        // std.debug.print("{c}\n", .{puzzle.items[@intCast(x_pos)][@intCast(y_pos)]});
        std.debug.print("{d},{d}->{c} | ", .{ x_pos, y_pos, puzzle.items[@intCast(x_pos)][@intCast(y_pos)] });
        // if (current_letter_idx == word.len - 1) {
        //     std.debug.print("FOUND XMAS\n", .{});
        //     return true;
        // }
        var xmas_found: bool = false;
        // Search down
        xmas_found = xmas_found or find_xmas(current_letter_idx + 1, x_pos + 1, y_pos, puzzle);
        // Search Up
        xmas_found = xmas_found or find_xmas(current_letter_idx + 1, x_pos - 1, y_pos, puzzle);
        // Search Left
        xmas_found = xmas_found or find_xmas(current_letter_idx + 1, x_pos, y_pos - 1, puzzle);
        // Search Right
        xmas_found = xmas_found or find_xmas(current_letter_idx + 1, x_pos, y_pos + 1, puzzle);
        // Search Diag Down Right
        xmas_found = xmas_found or find_xmas(current_letter_idx + 1, x_pos + 1, y_pos + 1, puzzle);
        // Search Diag Down Left
        xmas_found = xmas_found or find_xmas(current_letter_idx + 1, x_pos + 1, y_pos - 1, puzzle);
        // Search Diag Up Right
        xmas_found = xmas_found or find_xmas(current_letter_idx + 1, x_pos - 1, y_pos + 1, puzzle);
        // Search Diag Up Left
        xmas_found = xmas_found or find_xmas(current_letter_idx + 1, x_pos - 1, y_pos - 1, puzzle);

        return xmas_found;
    } else return false;
}

// x_dir can be +1 or -1, y_dir can also be +1 or -1
fn find_xmas_direct(x_pos: i32, y_pos: i32, x_dir: i32, y_dir: i32, puzzle: std.ArrayList([]u8)) bool {
    const num_rows = puzzle.items.len;
    const num_cols = puzzle.items[0].len;
    var current_x: i32 = x_pos;
    var current_y: i32 = y_pos;
    for (word) |letter| {
        if (current_x < 0 or current_x >= num_rows or current_y < 0 or current_y >= num_cols or puzzle.items[@intCast(current_x)][@intCast(current_y)] != letter) {
            return false;
        }
        current_x += x_dir;
        current_y += y_dir;
    }
    return true;
}

// The x_pos and y_pos should be a position of an 'A'
fn find_x_mas(x_pos: i32, y_pos: i32, puzzle: std.ArrayList([]u8)) bool {
    const num_rows = puzzle.items.len;
    const num_cols = puzzle.items[0].len;
    if ((x_pos >= 1 and x_pos <= num_rows - 2) and (y_pos >= 1 and y_pos <= num_cols - 2)) {
        const top_left_corner: u8 = puzzle.items[@intCast(x_pos - 1)][@intCast(y_pos - 1)];
        const top_right_corner: u8 = puzzle.items[@intCast(x_pos - 1)][@intCast(y_pos + 1)];
        const bottom_left_corner: u8 = puzzle.items[@intCast(x_pos + 1)][@intCast(y_pos - 1)];
        const bottom_right_corner: u8 = puzzle.items[@intCast(x_pos + 1)][@intCast(y_pos + 1)];
        if (top_left_corner == 'X' or bottom_left_corner == 'X' or top_right_corner == 'X' or bottom_right_corner == 'X') return false;

        // This is ugly but I didn't want to mess with it
        if ((top_left_corner == 'M' and bottom_right_corner == 'S') and (top_right_corner == 'S' and bottom_left_corner == 'M')) return true;
        if ((top_left_corner == 'M' and bottom_right_corner == 'S') and (top_right_corner == 'M' and bottom_left_corner == 'S')) return true;
        if ((top_left_corner == 'S' and bottom_right_corner == 'M') and (top_right_corner == 'S' and bottom_left_corner == 'M')) return true;
        if ((top_left_corner == 'S' and bottom_right_corner == 'M') and (top_right_corner == 'M' and bottom_left_corner == 'S')) return true;
        if ((top_right_corner == 'M' and bottom_left_corner == 'S') and (top_left_corner == 'S' and bottom_right_corner == 'M')) return true;
        if ((top_right_corner == 'M' and bottom_left_corner == 'S') and (top_left_corner == 'M' and bottom_right_corner == 'S')) return true;
        if ((top_right_corner == 'S' and bottom_left_corner == 'M') and (top_left_corner == 'S' and bottom_right_corner == 'M')) return true;
        if ((top_right_corner == 'S' and bottom_left_corner == 'M') and (top_left_corner == 'M' and bottom_right_corner == 'S')) return true;

        return false;
    } else return false;
}

pub fn main() !void {
    // The .{} is short for saying all default fields
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        _ = deinit_status;
    }

    const path = "input.in";
    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.log.err("Failed to open file: {s}", .{@errorName(err)});
        return;
    };
    defer file.close();
    var search_rows = std.ArrayList([]u8).init(allocator);
    defer search_rows.deinit();
    while (file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize)) catch |err| {
        std.log.err("Failed to read line: {s}", .{@errorName(err)});
        return;
    }) |line| {
        try search_rows.append(line);
    }

    var occurrences: u32 = 0;
    for (search_rows.items, 0..) |row, x_idx| {
        for (row, 0..) |_, y_idx| {
            if (search_rows.items[@intCast(x_idx)][@intCast(y_idx)] != 'X') continue;
            // if (find_xmas(0, @intCast(x_idx), @intCast(y_idx), search_rows)) occurrences += 1;
            // Search Down
            if (find_xmas_direct(@intCast(x_idx), @intCast(y_idx), 1, 0, search_rows)) occurrences += 1;
            // Search Up
            if (find_xmas_direct(@intCast(x_idx), @intCast(y_idx), -1, 0, search_rows)) occurrences += 1;
            // Search Left
            if (find_xmas_direct(@intCast(x_idx), @intCast(y_idx), 0, -1, search_rows)) occurrences += 1;
            // Search Right
            if (find_xmas_direct(@intCast(x_idx), @intCast(y_idx), 0, 1, search_rows)) occurrences += 1;
            // Search Diag Down Right
            if (find_xmas_direct(@intCast(x_idx), @intCast(y_idx), 1, 1, search_rows)) occurrences += 1;
            // Search Diag Down Left
            if (find_xmas_direct(@intCast(x_idx), @intCast(y_idx), 1, -1, search_rows)) occurrences += 1;
            // Search Diag Up Right
            if (find_xmas_direct(@intCast(x_idx), @intCast(y_idx), -1, 1, search_rows)) occurrences += 1;
            // Search Diag Up Left
            if (find_xmas_direct(@intCast(x_idx), @intCast(y_idx), -1, -1, search_rows)) occurrences += 1;
        }
    }
    std.debug.print("XMAS Occurences {d}\n", .{occurrences});

    var x_mas_occurrences: u32 = 0;
    for (search_rows.items, 0..) |row, x_idx| {
        for (row, 0..) |_, y_idx| {
            if (search_rows.items[@intCast(x_idx)][@intCast(y_idx)] != 'A') continue;
            if (find_x_mas(@intCast(x_idx), @intCast(y_idx), search_rows)) x_mas_occurrences += 1;
        }
    }
    std.debug.print("X-MAS Occurrences: {d}\n", .{x_mas_occurrences});

    for (search_rows.items) |row| {
        // std.debug.print("{s}", .{row});
        allocator.free(row);
    }
}

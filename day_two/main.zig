const std = @import("std");

fn isReportSafe(record: []i32, increasing: bool) bool {
    for (record[0 .. record.len - 1], record[1..]) |n1, n2| {
        var diff: i32 = undefined;
        if (increasing) {
            diff = n1 - n2;
        } else {
            diff = n2 - n1;
        }
        if (diff < 1 or diff > 3) return false;
    }
    return true;
}

// Doubly nested for loop testing every possible record with one level removed
fn lenientIsReportSafe(record: []i32, increasing: bool) bool {
    // Pick your skipped index
    for (0..record.len) |skipped_idx| {
        // Store the number of valid values
        var valid_sequences: u16 = 0;
        // Loop thru the list as you normally would
        for (0..record.len - 1) |idx| {
            // Ignore skipped index
            if (idx == skipped_idx) continue;
            // When comparing the following value ignore the skipped index
            const next_level_idx = if (idx + 1 == skipped_idx) idx + 2 else idx + 1;
            if (next_level_idx >= record.len) continue;
            // Check to make sure your next number is valid
            const diff = if (increasing) record[next_level_idx] - record[idx] else record[idx] - record[next_level_idx];
            // If it's valid you know that value is making up a good record
            if (diff >= 1 and diff <= 3) valid_sequences += 1;
        }
        // If you detected num_levels-2 valid levels it's a valid record. This is because we dropped a level and don't care about one level to begin with
        if (valid_sequences == record.len - 2) return true;
    }
    return false;
}

// I don't know what returning !void does
pub fn main() !void {
    // The .{} is short for saying all default fields
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        // Free memory?
        const deinit_status = gpa.deinit();
        _ = deinit_status;
    }

    const path = "input.in";
    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.log.err("Failed to open file: {s}", .{@errorName(err)});
        return;
    };
    defer file.close();
    var safeReports: u32 = 0;
    var lenientSafeReports: u32 = 0;

    while (file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize)) catch |err| {
        std.log.err("Failed to read line: {s}", .{@errorName(err)});
        return;
    }) |line| {
        defer allocator.free(line);
        var numbersInRecord = std.ArrayList(i32).init(allocator);
        defer numbersInRecord.deinit();
        var it = std.mem.splitScalar(u8, line, ' ');
        while (it.next()) |level| {
            // The parser returns a Union, I don't know anything about that yet
            const levelNum = try std.fmt.parseInt(i32, level, 10);
            try numbersInRecord.append(levelNum);
        }
        const isSafe: bool = isReportSafe(numbersInRecord.items, true) or isReportSafe(numbersInRecord.items, false);
        const lenientIsSafe: bool = lenientIsReportSafe(numbersInRecord.items, true) or lenientIsReportSafe(numbersInRecord.items, false);
        if (isSafe) safeReports += 1;
        if (lenientIsSafe) lenientSafeReports += 1;
    }
    std.debug.print("Safe Reports: {d}\n", .{safeReports});
    std.debug.print("Lenient Safe Reports: {d}\n", .{lenientSafeReports});
}

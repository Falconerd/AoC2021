const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var x: u32 = 0;
    var y: u32 = 0;

    const file = std.fs.cwd().openFile("input", .{}) catch |err| {
        print("Error opening file: {}\n", .{err});
        return;
    };
    defer file.close();

    const len = file.getEndPos() catch |err| {
        print("Error getting end pos: {}\n", .{err});
        return;
    };

    const contents = file.reader().readAllAlloc(allocator, len) catch |err| {
        print("Error reading file: {}\n", .{err});
        return;
    };

    var it = std.mem.split(u8, contents, "\n");
    while (it.next()) |line| {
        var line_it = std.mem.split(u8, line, " ");

        const command = line_it.next().?;

        if (command.len == 0) {
            continue;
        }

        const value_str = line_it.next().?;

        const value = std.fmt.parseUnsigned(u32, value_str, 10) catch |err| {
            print("Error parsing value: {} ({s})\n", .{err, value_str});
            continue;
        };

        if (std.mem.eql(u8, "forward", command)) {
            x += value;
        } else if (std.mem.eql(u8, "down", command)) {
            y += value;
        } else if (std.mem.eql(u8, "up", command)) {
            y -= value;
        }
    }


    print("{} * {} = {}\n", .{x, y, x * y});
}

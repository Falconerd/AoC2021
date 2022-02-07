const std = @import("std");
const print = std.debug.print;
const OpenFlags = std.fs;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var count: u32 = 0;
    var prev: ?u32 = null;

    const file = std.fs.cwd().openFile("01_input", .{}) catch |err| {
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
        const value = std.fmt.parseUnsigned(u32, line, 10) catch |err| {
            print("Error parsing line: {} ({any})\n", .{err, line});
            continue;
        };

        if (prev == null) {
            prev = value;
            continue;
        }

        if (prev.? < value) {
            count += 1;
        }

        prev = value;
    }

    print("{s}\n{}\n", .{contents, count});
}

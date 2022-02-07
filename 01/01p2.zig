const std = @import("std");
const print = std.debug.print;
const OpenFlags = std.fs;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var count: u32 = 0;

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

    var list = std.ArrayList(u32).init(allocator);

    var it = std.mem.split(u8, contents, "\n");
    while (it.next()) |line| {
        const value = std.fmt.parseUnsigned(u32, line, 10) catch |err| {
            print("Error parsing line: {} ({s})\n", .{err, line});
            continue;
        };

        try list.append(value);
    }

    var arr = list.toOwnedSlice();
    for (arr) |item, index| {

        print("[{}] {}\n", .{index, item});

        if (index >= 3) {
            const sum = item + arr[index-1] + arr[index-2];
            const prev = arr[index-1] + arr[index-2] + arr[index-3];
            if (sum > prev) {
                count += 1;
            }
        }
    }

    print("count: {}\n", .{count});
}

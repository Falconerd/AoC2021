const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const HashMap = std.AutoHashMap;

const Point = struct { x: u32, y: u32 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const contents = try std.fs.cwd().readFileAlloc(allocator, "input", std.math.maxInt(usize));
    defer allocator.free(contents);

    var fish = [_]usize{0} ** 9;

    var it = std.mem.split(u8, contents, ",");
    while (it.next()) |n_str| {
        var n = try std.fmt.parseUnsigned(usize, n_str[0..1], 10);
        fish[n] += 1;
    }

    var i: u16 = 0;
    while (i < 256) : (i += 1) {
        const six = fish[6];
        const eight = fish[8];
        fish[6] = fish[7] + fish[0];
        fish[8] = fish[0];

        fish[0] = fish[1];
        fish[1] = fish[2];
        fish[2] = fish[3];
        fish[3] = fish[4];
        fish[4] = fish[5];
        fish[5] = six;
        fish[7] = eight;
    }

    var count: usize = 0;
    for (fish) |f| count += f;

    print("Count: {}\n", .{count});
}

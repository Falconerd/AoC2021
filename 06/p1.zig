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

    var fish = ArrayList(u4).init(allocator);
    defer fish.deinit();

    var it = std.mem.split(u8, contents, ",");
    while (it.next()) |n_str| {
        var n = try std.fmt.parseUnsigned(u4, n_str[0..1], 10);
        _ = try fish.append(n);
    }

    var i: u8 = 0;
    while (i < 80) : (i += 1) {
        for (fish.items) |f, fish_index| {
            if (f == 0) {
                _ = try fish.append(8);
                fish.items[fish_index] = 6;
                continue;
            } else {
                fish.items[fish_index] -= 1;
            }
        }
    }

    print("{d}\n", .{fish.items.len});
}

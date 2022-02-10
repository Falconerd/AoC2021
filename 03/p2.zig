const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const mostCommonBitAt = @import("./util.zig").mostCommonBitAt;

fn getRating(numbers: ArrayList(u16), bit_count: usize, substitute: u4, allocator: Allocator) u16 {
    var list = ArrayList(u16).init(allocator);
    defer list.deinit();

    for (numbers.items) |n| _ = list.append(n) catch unreachable;

    var offset = @truncate(u4, bit_count);
    while (offset > 0) {
        offset -= 1;

        const most_common_bit = mostCommonBitAt(list, offset, substitute);
        const mask = @as(u16, 1) << offset;

        if (list.items.len > 1) {
            var index: usize = list.items.len;
            while (index > 0) {
                index -= 1;

                const number = list.items[index];

                if (((number & mask) >> offset) != most_common_bit) {
                    _ = list.swapRemove(index);
                }
            }

        }
    }

    return list.items[0];
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const contents = try std.fs.cwd().readFileAlloc(allocator, "input", std.math.maxInt(usize));
    defer allocator.free(contents);

    var numbers = ArrayList(u16).init(allocator);
    defer numbers.deinit();

    var bit_count: usize = 0;

    var it = std.mem.split(u8, contents, "\n");
    while (it.next()) |line| {
        const n = std.fmt.parseInt(u16, line, 2) catch continue;
        bit_count = line.len;

        try numbers.append(n);
    }

    var oxygen_rating: u16 = getRating(numbers, bit_count, 1, allocator);
    var carbon_dioxide_rating: u16 = getRating(numbers, bit_count, 0, allocator);

    var result: usize = @as(usize, oxygen_rating) * @as(usize, carbon_dioxide_rating);

    print("result: {}\n", .{result});
}


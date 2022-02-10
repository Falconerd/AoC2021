const std = @import("std");
const print = std.debug.print;
const mostCommonBitAt = @import("./util.zig").mostCommonBitAt;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const contents = try std.fs.cwd().readFileAlloc(allocator, "input", std.math.maxInt(usize));
    defer allocator.free(contents);

    var numbers = std.ArrayList(u16).init(allocator);
    defer numbers.deinit();

    var bit_count: usize = 0;

    var it = std.mem.split(u8, contents, "\n");
    while (it.next()) |line| {
        const n = std.fmt.parseInt(u16, line, 2) catch continue;
        bit_count = line.len;

        try numbers.append(n);
    }

    var gamma: usize = 0;
    var epsilon: usize = 0;

    var offset: u4 = 0;
    while (offset < bit_count) : (offset += 1) {
        const most_common_bit = mostCommonBitAt(numbers, offset, 1);

        const mask = @as(u16, 1) << offset;

        if (most_common_bit == 0) {
            epsilon |= mask;
        } else {
            gamma |= mask;
        }
    }

    print("gamma: {b} ({}), epsilon: {b} ({}), gamma * epsilon: {}\n", .{gamma, gamma, epsilon, epsilon, gamma * epsilon});
}

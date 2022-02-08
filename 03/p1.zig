const std = @import("std");
const print = std.debug.print;

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

    var i: u8 = 0;
    while (i < bit_count) : (i += 1) {
        var bc: isize = 0;
        const mask = @as(u16, 1) << @truncate(u4, i);

        for (numbers.items) |number| {
            const bit = mask & number;

            if (bit == 0) {
                bc -= 1;
            } else {
                bc += 1;
            }
        }

        if (bc >= 0) {
            gamma |= mask;
        } else {
            epsilon |= mask;
        }
    }

    print("gamma: {b} ({}), epsilon: {b} ({}), gamma * epsilon: {}\n", .{gamma, gamma, epsilon, epsilon, gamma * epsilon});
}

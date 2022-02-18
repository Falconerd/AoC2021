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

    var lines = ArrayList([4]u16).init(allocator);
    defer lines.deinit();

    var map = HashMap(Point, u32).init(allocator);
    defer map.deinit();

    var it = std.mem.split(u8, contents, "\n");
    while (it.next()) |line| {
        var coordinates = [_]u16{0} ** 4;

        var i: usize = 0;

        var jt = std.mem.split(u8, line, " -> ");
        while (jt.next()) |coordinate| {
            if (std.mem.count(u8, coordinate, ",") == 0) break;

            var kt = std.mem.split(u8, coordinate, ",");

            coordinates[i] = try std.fmt.parseInt(u16, kt.next().?, 10); i += 1;
            coordinates[i] = try std.fmt.parseInt(u16, kt.next().?, 10); i += 1;
        }

        if (coordinates[0] != coordinates[2] or coordinates[1] != coordinates[3])
            _ = try lines.append(coordinates);

    }

    var count: u32 = 0;

    for (lines.items) |line| {
        const x1 = line[0];
        const y1 = line[1];
        const x2 = line[2];
        const y2 = line[3];

        var x = x1;
        var y = y1;
        var width = try std.math.absInt(@intCast(i16, x2) - @intCast(i16, x1));
        var height = try std.math.absInt(@intCast(i16, y2) - @intCast(i16, y1));
        var size = std.math.max(width, height) + 1;

        var i: i16 = 0;
        while (i < size) : (i += 1) {
            const k: Point = .{ .x = x, .y = y };
            var v = map.get(k);
            if (v) |value| {
                _ = try map.put(k, value + 1);
                if (value == 1)
                    count += 1;
            } else {
                _ = try map.put(k, 1);
            }

            if (x1 < x2) {
                x += 1;
            } else if (x1 > x2 and x > 0) {
                x -= 1;
            }

            if (y1 < y2) {
                y += 1;
            } else if (y1 > y2 and y > 0) {
                y -= 1;
            }
        }
    }

    print("Count: {d}\n", .{count});
}


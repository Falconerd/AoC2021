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

        var p = coordinates[0];
        var q = coordinates[1];
        var r = coordinates[2];
        var s = coordinates[3];

        if (p != r and q != s) continue;

        // Always sort coordinates in ascending order.
        if (p == r) {
            _ = try lines.append([4]u16{p, std.math.min(q, s), r, std.math.max(q, s)});
        } else {
            _ = try lines.append([4]u16{std.math.min(p, r), q, std.math.max(p, r), s});
        }
    }

    var count: u32 = 0;

    // Whichever coord is the same stays the same for an entire segment.
    for (lines.items) |line| {
        var x = line[0];
        var y = line[1];

        if (line[0] == line[2]) {
            while (y <= line[3]) : (y += 1) {
                const k: Point = .{.x = x, .y = y};
                var v = map.get(k);

                if (v) |value| {
                    _ = try map.put(k, value + 1);
                    if (value == 1) {
                        count += 1;
                    }
                } else {
                    _ = try map.put(k, 1);
                }
            }
        }

        if (line[1] == line[3]) {
            while (x <= line[2]) : (x += 1) {
                const k: Point = .{.x = x, .y = y};
                var v = map.get(k);

                if (v) |value| {
                    _ = try map.put(k, value + 1);
                    if (value == 1) {
                        count += 1;
                    }
                } else {
                    _ = try map.put(k, 1);
                }
            }
        }
    }

    print("Count: {d}\n", .{count});
}


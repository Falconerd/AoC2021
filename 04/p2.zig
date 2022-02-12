const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

fn readIntoLists(contents: []u8, numbers: *ArrayList(u8), boards: *ArrayList([25]u8), marks: *ArrayList(u32)) !void {
    var cell_index: usize = 0;
    var line_count: usize = 0;
    var board_count: usize = 0;
    var it = std.mem.split(u8, contents, "\n");
    while (it.next()) |line| {
        line_count += 1;

        if (line_count == 1) {
            var jt = std.mem.split(u8, line, ",");
            while (jt.next()) |number| {
                const n = std.fmt.parseInt(u8, number, 10) catch unreachable;
                _ = try numbers.append(n);
            }
            continue;
        }

        if (line.len == 0) {
            board_count += 1;
            _ = try boards.append([_]u8{0} ** 25);
            cell_index = 0;
            continue;
        }

        var i: usize = 0;
        while (i < 5) : (i += 1) {
            const start: usize = i * 3;
            const end: usize = i * 3 + 2;

            boards.items[board_count-1][cell_index] = try std.fmt.parseInt(u8, std.mem.trimLeft(u8, line[start..end], " "), 10);
            cell_index += 1;
        }
    }

    _ = boards.swapRemove(board_count - 1);

    for (boards.items) |_| _ = try marks.append(0);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const contents = try std.fs.cwd().readFileAlloc(allocator, "input", std.math.maxInt(usize));
    defer allocator.free(contents);

    var numbers = ArrayList(u8).init(allocator);
    defer numbers.deinit();

    var boards = ArrayList([25]u8).init(allocator);
    defer boards.deinit();

    var marks = ArrayList(u32).init(allocator);
    defer marks.deinit();

    var won_boards = ArrayList(bool).init(allocator);
    defer won_boards.deinit();

    _ = try readIntoLists(contents, &numbers, &boards, &marks);

    for (boards.items) |_| _ = try won_boards.append(false);

    var winning_board_index: ?usize = null;
    var winning_number: usize = 0;
    var number_index: usize = 0;

    while (number_index < numbers.items.len) : (number_index += 1) {
        const number = numbers.items[number_index];

        for (boards.items) |board, board_index| {
            for (board) |cell, cell_index| {
                if (cell == number) {
                    if (!won_boards.items[board_index])
                        marks.items[board_index] |= (@as(u32, 1) << @truncate(u5, cell_index));
                    if (checkForWin(marks.items[board_index]) and won_boards.items[board_index] == false) {
                        won_boards.items[board_index] = true;
                        winning_board_index = board_index;
                        winning_number = number;
                    }
                }
            }
        }
    }

    if (winning_board_index) |index| {
        var sum: usize = sumUnmarkedNumbers(marks.items[index], boards.items[index]);
        print("Sum: {d}, Answer: {}\n", .{sum, winning_number * sum});
    } else {
        print("Could not find answer\n", .{});
    }
}

const MASKV: u32 = 0b0000000_00001_00001_00001_00001_00001;
const MASKH: u32 = 0b0000000_00000_00000_00000_00000_11111;

fn checkForWin(marked: u32) bool {
    var i: usize = 0;
    while (i < 5) : (i += 1) {
        const maskv = MASKV << @truncate(u5, i);
        const maskh = MASKH << @truncate(u5, i * 5);

        if ((maskv & marked) == maskv) return true;
        if ((maskh & marked) == maskh) return true;
    }

    return false;
}

fn sumUnmarkedNumbers(marked: u32, numbers: [25]u8) usize {
    var sum: usize = 0;
    for (numbers) |number, index| {
        const is_marked = (marked & @as(u32, 1) << @truncate(u5, index)) > 0;
        if (!is_marked) sum += number;
    }

    return sum;
}


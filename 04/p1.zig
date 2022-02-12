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

    _ = try readIntoLists(contents, &numbers, &boards, &marks);

    var winning_board_index: ?usize = null;
    var winning_number: usize = 0;
    var number_index: usize = 0;

    check_win: while (winning_board_index == null and number_index < numbers.items.len) : (number_index += 1) {
        const number = numbers.items[number_index];

        for (boards.items) |board, board_index| {
            for (board) |cell, cell_index| {
                if (cell == number) {
                    marks.items[board_index] |= (@as(u32, 1) << @truncate(u5, cell_index));
                    if (checkForWin(marks.items[board_index])) {
                        winning_board_index = board_index;
                        winning_number = number;
                        break :check_win;
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

// First draft left here for comparison
//pub fn main() !void {
//    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//    const allocator = gpa.allocator();
//
//    const contents = try std.fs.cwd().readFileAlloc(allocator, "input", std.math.maxInt(usize));
//    defer allocator.free(contents);
//
//    var numbers = ArrayList(u8).init(allocator);
//    defer numbers.deinit();
//
//    var boards = ArrayList([5][5]u8).init(allocator);
//    defer boards.deinit();
//
//    var marks = ArrayList(u32).init(allocator);
//    defer marks.deinit();
//
//    var table_count: usize = 0;
//    var row: usize = 0;
//
//    var it = std.mem.split(u8, contents, "\n");
//    while (it.next()) |line| {
//        if (std.mem.count(u8, line, ",") > 0) {
//            var jt = std.mem.split(u8, line, ",");
//            while (jt.next()) |number| {
//                const n = std.fmt.parseInt(u8, number, 10) catch continue;
//                _ = try numbers.append(n);
//            }
//            continue;
//        }
//
//        if (line.len == 0) {
//            table_count += 1;
//            row = 0;
//            var board = [5][5]u8{
//                [_]u8{0} ** 5,
//                [_]u8{0} ** 5,
//                [_]u8{0} ** 5,
//                [_]u8{0} ** 5,
//                [_]u8{0} ** 5
//            };
//            _ = try boards.append(board);
//            continue;
//        }
//
//        const table_index = table_count - 1;
//
//        boards.items[table_index][row][0] = try std.fmt.parseInt(u8, std.mem.trimLeft(u8, line[0..2], " "), 10);
//        boards.items[table_index][row][1] = try std.fmt.parseInt(u8, std.mem.trimLeft(u8, line[3..5], " "), 10);
//        boards.items[table_index][row][2] = try std.fmt.parseInt(u8, std.mem.trimLeft(u8, line[6..8], " "), 10);
//        boards.items[table_index][row][3] = try std.fmt.parseInt(u8, std.mem.trimLeft(u8, line[9..11], " "), 10);
//        boards.items[table_index][row][4] = try std.fmt.parseInt(u8, std.mem.trimLeft(u8, line[12..14], " "), 10);
//
//        row += 1;
//    }
//
//    // Remove the EOF counted.
//    table_count -= 1;
//
//    // Remove extra board created.
//    _ = boards.swapRemove(table_count);
//
//    for (boards.items) |_| _ = try marks.append(0);
//
//
//    const mask_vertical: u32 = 0b0000000_00001_00001_00001_00001_00001;
//    const mask_horizontal: u32 = 0b0000000_00000_00000_00000_00000_11111;
//
//    print("{d}\n", .{boards.items});
//    print("{d}\n", .{marks.items});
//
//    var winning_index: ?usize = null;
//    var last_called: ?u32 = null;
//
//    outer: for (numbers.items) |number| {
//        print("number: {}\n", .{number});
//        for (boards.items) |board, board_index| {
//            print("board: {d}\n", .{board_index});
//            var i: usize = 0;
//            while (i < board.len) : (i += 1) {
//                var j: usize = 0;
//                while (j < board[i].len) : (j += 1) {
//                    print("[{},{}]: {}   ", .{i, j, board[i][j]});
//                    if (number == board[i][j]) {
//                        print("MATCH!: {}={}\n", .{number, board[i][j]});
//                        print("{}\n", .{marks.items.len});
//                        marks.items[board_index] |= (@as(u32, 1) << @truncate(u5, i * 5 + j));
//
//                        print("{b}\n", .{marks.items});
//
//                        var k: usize = 0;
//                        while (k < 5) : (k += 5) {
//                            const maskv = mask_vertical << @truncate(u5, k);
//                            const maskh = mask_horizontal << @truncate(u5, k * 5);
//
//                            for (marks.items) |mark| {
//                                if ((maskv & mark) == maskv) {
//                                    print("Winner: {}\n", .{board_index});
//                                    last_called = number;
//                                    winning_index = board_index;
//                                    break :outer;
//                                }
//
//                                if ((maskh & mark) == maskh) {
//                                    print("Winner: {}\n", .{board_index});
//                                    last_called = number;
//                                    winning_index = board_index;
//                                    break :outer;
//                                }
//                            }
//                        }
//                    }
//                }
//                print("\n", .{});
//            }
//            //print(".{d}. .{}. .{}.\n", .{board, board_index, number});
//        }
//    }
//
//    print("{b}\n{b}\n", .{mask_vertical, mask_horizontal});
//    print("{b}\n", .{marks.items});
//
//    var sum_of_unmarked: u32 = 0;
//
//    for (boards.items[winning_index.?]) |r, x| {
//        for (r) |cell, y| {
//            const marked = @as(u32, 1) << @truncate(u5, x * 5 + y) & marks.items[winning_index.?] > 0;
//            if (!marked) {
//                sum_of_unmarked += cell;
//            }
//        }
//    }
//
//   var result = sum_of_unmarked * last_called.?;
//   print("\nresult: {d}\n", .{result});
//}
//

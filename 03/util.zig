const std = @import("std");
const ArrayList = std.ArrayList;

/// Finds the most common bit from a list of u16s at an offset.
/// If there is an equal number of 0s and 1s, returns substitute.
pub fn mostCommonBitAt(list: ArrayList(u16), offset: u4, substitute: u16) u16 {
    const half_len = @intToFloat(f32, list.items.len) / 2.0;
    var bit_score: u16 = 0;

    for (list.items) |number| {
        bit_score += (number >> offset) & 1;
    }

    const bit_scoref: f32 = @intToFloat(f32, bit_score);

    if (bit_scoref == half_len) {
        return substitute;
    }

    if (bit_scoref > half_len) {
        return substitute;
    }

    return substitute ^ 1;
}

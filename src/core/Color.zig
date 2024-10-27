const std = @import("std");

const Color = @This();

r: u8,
g: u8,
b: u8,
a: f32 = 1,

// Create a color from hex
pub fn fromHex(hex: []const u8, alpha: ?f32) error{InvalidLength}!Color {
    if (hex.len != 6) {
        return error.InvalidLength;
    }

    return Color{
        .r = try std.fmt.parseInt(u8, hex[0..2], 16),
        .g = try std.fmt.parseInt(u8, hex[2..4], 16),
        .b = try std.fmt.parseInt(u8, hex[4..6], 16),
        .a = alpha
    };
}

pub const black = Color{ .r = 0, .g = 0, .b = 0 };
pub const white = Color{ .r = 255, .g = 255, .b = 255 };

const std = @import("std");

const Color = @This();

r: u8,
g: u8,
b: u8,
a: f32,

// Initialize a color.
pub fn init(r: u8, g: u8, b: u8, a: f32) Color {
    return Color{
        .r = r,
        .g = g,
        .b = b,
        .a = a
    };
}

// Initialize a color from hex
pub fn initFromHex(hex: []const u8, alpha: f32) error{InvalidLength}!Color {
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

// Posterize the color.
pub fn posterize(self: *const Color, level: f32) Color {
    const step = @max(0, @min(1, level)) * 255;

    return Color{
        .r = @as(u8, @intFromFloat(@round(@as(f32, @as(f32, @floatFromInt(self.r)) / step)) * step)),
        .g = @as(u8, @intFromFloat(@round(@as(f32, @as(f32, @floatFromInt(self.g)) / step)) * step)),
        .b = @as(u8, @intFromFloat(@round(@as(f32, @as(f32, @floatFromInt(self.b)) / step)) * step)),
        .a = self.a
    };
}

// Brighten the color.
pub fn brighten(self: *const Color, level: f32) Color {
    const normalize_level = @max(1, @min(2, level + 1));

    return Color{
        .r = @as(u8, @intCast(@max(0, @min(255, @as(u16, @intFromFloat(@as(f32, @floatFromInt(self.r)) * normalize_level)))))),
        .g = @as(u8, @intCast(@max(0, @min(255, @as(u16, @intFromFloat(@as(f32, @floatFromInt(self.g)) * normalize_level)))))),
        .b = @as(u8, @intCast(@max(0, @min(255, @as(u16, @intFromFloat(@as(f32, @floatFromInt(self.b)) * normalize_level)))))),
        .a = self.a
    };
}

// Darken the color.
pub fn darken(self: *const Color, level: f32) Color {
    const normalize_level = @max(0, @min(1, level));

    return Color{
        .r = @as(u8, @intCast(@max(0, @min(255, @as(u16, @intFromFloat(@as(f32, @floatFromInt(self.r)) * normalize_level)))))),
        .g = @as(u8, @intCast(@max(0, @min(255, @as(u16, @intFromFloat(@as(f32, @floatFromInt(self.g)) * normalize_level)))))),
        .b = @as(u8, @intCast(@max(0, @min(255, @as(u16, @intFromFloat(@as(f32, @floatFromInt(self.b)) * normalize_level)))))),
        .a = self.a
    };
}

pub const black = Color.init(0, 0, 0, 1);
pub const white = Color.init(255, 255, 255, 1);
pub const red = Color.init(238, 70, 70, 1);
pub const orange = Color.init(240, 144, 93, 1);
pub const yellow = Color.init(240, 218, 93, 1);
pub const green = Color.init(110, 240, 93, 1);
pub const blue = Color.init(93, 203, 240, 1);
pub const purple = Color.init(233, 93, 240, 1);

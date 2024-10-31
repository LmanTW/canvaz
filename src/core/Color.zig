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

// Initialize a color from hex.
pub fn initFromHex(hex: []const u8, alpha: f32) error{InvalidLength}!Color {
    const offset = @as(u4, if (hex[0] == '#') 1 else 0);

    if (hex.len != 6) {
        return error.InvalidLength;
    }

    return Color{
        .r = try std.fmt.parseInt(u8, hex[offset..offset + 2], 16),
        .g = try std.fmt.parseInt(u8, hex[offset + 2..offset + 4], 16),
        .b = try std.fmt.parseInt(u8, hex[offset + 4..offset + 6], 16),
        .a = alpha 
    };
}

// Posterize the color.
pub fn posterize(self: *const Color, level: f32) Color {
    const step = @max(0, @min(1, level)) * 255;

    return Color{
        .r = @as(u8, @intFromFloat(@round(@as(f32, @floatFromInt(self.r)) / step) * step)),
        .g = @as(u8, @intFromFloat(@round(@as(f32, @floatFromInt(self.g)) / step) * step)),
        .b = @as(u8, @intFromFloat(@round(@as(f32, @floatFromInt(self.b)) / step) * step)),
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

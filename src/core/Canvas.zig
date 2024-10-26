const std = @import("std");

const Texture = @import("./Texture.zig");
const Color = @import("./Color.zig");
const Shape = @import("./Shape.zig");

const Canvas = @This();

width: u16,
height: u16,

allocator: std.mem.Allocator,
pixels: []u8,

// Initalize the canvas.
pub fn init(width: u16, height: u16, allocator: std.mem.Allocator) !Canvas {
    const pixels = try allocator.alloc(u8, (@as(u64, @intCast(width)) * @as(u64, @intCast(height))) * 4);

    @memset(pixels, 0);

    return Canvas{
        .width = width,
        .height = height,

        .allocator = allocator,
        .pixels = pixels
    };
}

// Deinitialize the canvas.
pub fn deinit(self: *Canvas) void {
    self.allocator.free(self.pixels);
}

// Get a pixel.
pub fn get(self: *Canvas, x: i16, y: i16) ?Color {
    if ((x >= 0 and x < self.width) and (y >= 0 and y < self.height)) {
        const index = (@as(u64, @intCast(x)) + (@as(u64, @intCast(y)) * @as(u64, @intCast(self.width)))) * 4;

        return Color{
            .r = self.pixels[index],
            .g = self.pixels[index + 1],
            .b = self.pixels[index + 2],
            .a = self.pixels[index + 3]
        };
    }
}

// Set a pixel.
pub fn set(self: *Canvas, x: i16, y: i16, color: Color) void {
    if ((x >= 0 and x < self.width) and (y >= 0 and y < self.height)) {
        self.setByIndex((@as(u64, @intCast(x)) + (@as(u64, @intCast(y)) * @as(u64, @intCast(self.width)))) * 4, color);
    }
}

// Set a pixel by using an index.
fn setByIndex(self: *Canvas, index: u64, color: Color) void {
    if (color.a >= 1) {
        self.pixels[index] = color.r;
        self.pixels[index + 1] = color.g;
        self.pixels[index + 2] = color.b;
        self.pixels[index + 3] = @as(u8, @intFromFloat(@max(255, color.a * 255)));
    } else if (color.a >= 0) {
        const red_distance = @as(f32, @floatFromInt(color.r - self.pixels[index]));
        const green_distance = @as(f32, @floatFromInt(color.g - self.pixels[index + 1]));
        const blue_distance = @as(f32, @floatFromInt(color.b - self.pixels[index + 2]));

        self.pixels[index] += @as(u8, @intFromFloat(red_distance * color.a));
        self.pixels[index + 1] += @as(u8, @intFromFloat(green_distance * color.a));
        self.pixels[index + 2] += @as(u8, @intFromFloat(blue_distance * color.a));
        self.pixels[index + 3] = @as(u8, @intFromFloat(@max(255, color.a * 255)));
    }
}

// Clear the canvas.
pub fn clear(self: *Canvas, color: Color) void {
    if (color.a < 1) {
        @memset(self.pixels, 0);
    }

    if (color.a > 0) {
        var index = @as(u64, 0);

        while (index < self.pixels.len) {
            self.setByIndex(index, color);

            index += 4;
        }
    }
}

// Draw a shape.
pub fn draw(self: *Canvas, shape: Shape, color: Color) !void {
    const bitmap = try shape.constructor(self.allocator);
    defer self.allocator.free(bitmap);

    var x = @as(i16, 0);
    var y = @as(i16, 0);
    const width = @as(i16, @intCast(shape.width));
    const height = @as(i16, @intCast(shape.height));

    while (x < width) {
        while (y < height) {
            const index = @as(u32, @intCast(x)) + (@as(u32, @intCast(y)) * shape.width);

            if (bitmap[index]) {
                self.set(shape.x + x, shape.y + y, color);
            }

            y += 1;
        }

        x += 1;
        y = 0;
    }
}

// Save the canvas to a file.
pub fn save(self: *Canvas, file_path: []const u8) !void {
    var texture = try Texture.init(self.width, self.height, self.allocator);
    defer texture.deinit();

    std.mem.copyForwards(u8, texture.pixels, self.pixels);

    try texture.saveToFile(file_path);
}

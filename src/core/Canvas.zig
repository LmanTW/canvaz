const zigimg = @import("zigimg");
const std = @import("std");

const Color = @import("./Color.zig");
const Shape = @import("./Shape.zig");
const Image = @import("./Image.zig");

const Canvas = @This();

width: u16,
height: u16,

allocator: std.mem.Allocator,
pixels: []u8,

// Initalize a canvas.
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
        const offset = (@as(u64, @intCast(x)) + (@as(u64, @intCast(y)) * @as(u64, @intCast(self.width)))) * 4;

        return Color{
            .r = self.pixels[offset],
            .g = self.pixels[offset + 1],
            .b = self.pixels[offset + 2],
            .a = @as(f32, @floatFromInt(self.pixels[offset + 3])) / 255
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

// Fill the canvas.
pub fn fill(self: *Canvas, color: Color) void {
    if (color.a < 1) {
        @memset(self.pixels, 0);
    }

    if (color.a > 0) {
        var offset = @as(u64, 0);

        while (offset < self.pixels.len) {
            self.setByIndex(offset, color);

            offset += 4;
        }
    }
}

// Draw a shape.
pub fn drawShape(self: *Canvas, shape: Shape, color: Color) void {
    const bitmap = shape.getBitmap(self.allocator) catch {
        return;
    };
    defer self.allocator.free(bitmap);

    const local_width = @as(i16, @intCast(shape.width));
    const local_height = @as(i16, @intCast(shape.height));
    var local_x = @as(i16, 0);
    var local_y = @as(i16, 0);

    while (local_x < local_width) {
        while (local_y < local_height) {
            const index = @as(u32, @intCast(local_x)) + (@as(u32, @intCast(local_y)) * shape.width);

            if (bitmap[index]) {
                self.set(shape.x + local_x, shape.y + local_y, color);
            }

            local_y += 1;
        }

        local_x += 1;
        local_y = 0;
    }
}

// Draw an image.
pub fn drawImage(self: *Canvas, image: Image, shape: Shape) void {
    const bitmap = shape.getBitmap(self.allocator) catch {
        return;
    };
    defer self.allocator.free(bitmap);

    const image_width_scale = @as(f32, @floatFromInt(image.width)) / @as(f32, @floatFromInt(shape.width));
    const image_height_scale = @as(f32, @floatFromInt(image.height)) / @as(f32, @floatFromInt(shape.height));

    const local_width = @as(i16, @intCast(shape.width));
    const local_height = @as(i16, @intCast(shape.height));
    var local_x = @as(i16, 0);
    var local_y = @as(i16, 0);

    while (local_x < local_width) {
        while (local_y < local_height) {
            const index = @as(u32, @intCast(local_x)) + (@as(u32, @intCast(local_y)) * shape.width);

            if (bitmap[index]) {
                const image_x = @as(u64, @intFromFloat(image_width_scale * @as(f32, @floatFromInt(local_x))));
                const image_y = @as(u64, @intFromFloat(image_height_scale * @as(f32, @floatFromInt(local_y))));

                const offset = (image_x + (image_y * @as(u64, @intCast(image.width)))) * 4;

                self.set(shape.x + local_x, shape.y + local_y, .{
                    .r = image.pixels[offset],
                    .g = image.pixels[offset + 1],
                    .b = image.pixels[offset + 2],
                    .a = @as(f32, @floatFromInt(image.pixels[offset + 3])) / 255
                });
            }

            local_y += 1;
        }

        local_x += 1;
        local_y = 0;
    }
}

// Save the canvas to a file.
pub fn saveToFile(self: *Canvas, file_path: []const u8) !void {
    var image = Image{
        .width = self.width,
        .height = self.height,

        .allocator = self.allocator,
        .pixels = self.pixels
    };

    try image.saveToFile(file_path);
}

// Fit type.
const FitType = enum(u4) {
    scale,
    min,
    max
};

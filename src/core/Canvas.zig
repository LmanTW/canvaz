const std = @import("std");

const Filter = @import("./Filter.zig");
const Color = @import("./Color.zig");
const Shape = @import("./Shape.zig");
const Image = @import("./Image.zig");

const Canvas = @This();

allocator: std.mem.Allocator,

width: u16,
height: u16,

pixels: []u8,
buffer1: []u8,
buffer2: []u8,

// Initialize a canvas.
pub fn init(width: u16, height: u16, allocator: std.mem.Allocator) !Canvas {
    const pixels = try allocator.alloc(u8, (@as(u64, @intCast(width)) * height) * 4);

    @memset(pixels, 0);

    return Canvas{
        .allocator = allocator,

        .width = width,
        .height = height,

        .pixels = pixels,
        .buffer1 = try allocator.alloc(u8, pixels.len),
        .buffer2 = try allocator.alloc(u8, pixels.len)
    };
}

// Deinitialize the canvas.
pub fn deinit(self: *const Canvas) void {
    self.allocator.free(self.pixels);
    self.allocator.free(self.buffer1);
    self.allocator.free(self.buffer2);
}

// Get a pixel.
pub fn get(self: *const Canvas, x: i32, y: i32) ?Color {
    if ((x >= 0 and x < self.width) and (y >= 0 and y < self.height)) {
        const offset = ((@as(u64, @intCast(y)) * self.width) + x) * 4;

        return Color.init(
            self.pixels[offset],
            self.pixels[offset + 1],
            self.pixels[offset + 2],
            @as(f32, @floatFromInt(self.pixels[offset + 3])) / 255
        );
    }
}

// Set a pixel.
pub fn set(self: *const Canvas, x: i32, y: i32, color: Color) void {
    if ((x >= 0 and x < self.width) and (y >= 0 and y < self.height)) {
        const offset = ((@as(u64, @intCast(y)) * self.width) + @as(u64, @intCast(x))) * 4;

        self.setByOffset(offset, color);
    }
}

// Set a pixel by using a offset.
fn setByOffset(self: *const Canvas, offset: u64, color: Color) void {
    if (color.a >= 1) {
        self.pixels[offset] = color.r;
        self.pixels[offset + 1] = color.g;
        self.pixels[offset + 2] = color.b;
        self.pixels[offset + 3] = @as(u8, @intFromFloat(@round(@min(255, color.a * 255))));
    } else if (color.a > 0) {
        const red_distance = @as(f32, @floatFromInt(@as(i8, @intCast(color.r)) - @as(i8, @intCast(self.pixels[offset]))));
        const green_distance = @as(f32, @floatFromInt(@as(i8, @intCast(color.g)) - @as(i8, @intCast(self.pixels[offset + 1]))));
        const blue_distance = @as(f32, @floatFromInt(@as(i8, @intCast(color.b)) - @as(i8, @intCast(self.pixels[offset + 2]))));

        const new_red = @as(f32, @floatFromInt(self.pixels[offset])) + (red_distance * color.a);
        const new_green = @as(f32, @floatFromInt(self.pixels[offset + 1])) + (green_distance * color.a);
        const new_blue = @as(f32, @floatFromInt(self.pixels[offset + 2])) + (blue_distance * color.a);

        self.pixels[offset] = @as(u8, @intFromFloat(@max(0, @min(255, new_red))));
        self.pixels[offset + 1] = @as(u8, @intFromFloat(@max(0, @min(255, new_green))));
        self.pixels[offset + 2] = @as(u8, @intFromFloat(@max(0, @min(255, new_blue))));
        self.pixels[offset + 3] = @as(u8, @intFromFloat(@max(0, @max(255, color.a * 255))));
    }
}

// Clear the canvas.
pub fn clear(self: *const Canvas) void {
    @memset(self.pixels, 0);
}

// Fill the canvas.
pub fn fill(self: *const Canvas, color: Color) void {
    if (color.a > 0) {
        var offset = @as(u64, 0);

        while (offset < self.pixels.len) {
            self.setByOffset(offset, color);

            offset += 4;
        }
    } else {
        @memset(self.pixels, 0);
    }
}

// Draw a shape.
pub fn drawShape(self: *const Canvas, shape: Shape, color: Color) void {
    const start_x = @min(@as(i32, @intCast(shape.x)), self.width);
    const start_y = @min(@as(i32, @intCast(shape.y)), self.height);
    const end_x = @min(start_x + shape.width, self.width);
    const end_y = @min(start_y + shape.height, self.height);

    var global_x = start_x;
    var global_y = start_y;

    while (global_x < end_x) {
        while (global_y < end_y) {
            const local_x = @as(u16, @intCast(global_x - start_x));
            const local_y = @as(u16, @intCast(global_y - start_y));

            if (shape.getPixel(local_x, local_y)) {
                self.set(global_x, global_y, color);
            }

            global_y += 1;
        }

        global_x += 1;
        global_y = start_y;
    }
}

// Draw an image.
pub fn drawImage(self: *const Canvas, image: Image, shape: Shape, layout: ImageLayout) void {
    const start_x = @min(@as(i32, @intCast(shape.x)), self.width);
    const start_y = @min(@as(i32, @intCast(shape.y)), self.height);
    const end_x = @min(start_x + shape.width, self.width);
    const end_y = @min(start_y + shape.height, self.height);

    var image_width = @as(u16, 0);
    var image_height = @as(u16, 0);
    var image_offset_x = @as(f32, 0);
    var image_offset_y = @as(f32, 0);

    switch (layout) {
        .scale => {
            image_width = shape.width;
            image_height = shape.height;
        },
        .cover => {
            const ratio = @max(
                @as(f32, @floatFromInt(shape.width)) / @as(f32, @floatFromInt(image.width)),
                @as(f32, @floatFromInt(shape.height)) / @as(f32, @floatFromInt(image.height))
            );

            image_width = @as(u16, @intFromFloat(@round(@as(f32, @floatFromInt(image.width)) * ratio)));
            image_height = @as(u16, @intFromFloat(@round(@as(f32, @floatFromInt(image.height)) * ratio)));
            image_offset_x = @as(f32, @floatFromInt((image_width / 2) - (shape.width / 2)));
            image_offset_y = @as(f32, @floatFromInt((image_height / 2) - (shape.height / 2)));
        }
    }

    const image_width_scale = @as(f32, @floatFromInt(image.width)) / @as(f32, @floatFromInt(image_width));
    const image_height_scale = @as(f32, @floatFromInt(image.height)) / @as(f32, @floatFromInt(image_height));

    var global_x = start_x;
    var global_y = start_y;

    while (global_x < end_x) {
        while (global_y < end_y) {
            const local_x = @as(u16, @intCast(global_x - start_x));
            const local_y = @as(u16, @intCast(global_y - start_y));

            if (shape.getPixel(local_x, local_y)) {
                const image_x = (@as(f32, @floatFromInt(local_x)) * image_width_scale) + image_offset_x;
                const image_y = (@as(f32, @floatFromInt(local_y)) * image_height_scale) + image_offset_y;
                const offset = ((@as(u64, @intFromFloat(image_y)) * image.width) + @as(u64, @intFromFloat(image_x))) * 4;

                self.set(@as(i32, @intCast(shape.x)) + local_x, @as(i32, @intCast(shape.y)) + local_y, Color.init(
                    image.pixels[offset],
                    image.pixels[offset + 1],
                    image.pixels[offset + 2],
                    @as(f32, @floatFromInt(image.pixels[offset + 3])) / 255
                ));
            }

            global_y += 1;
        }

        global_x += 1;
        global_y = start_y;
    }
}

pub const ImageLayout = enum(u4) {
    cover,
    scale
};

// Draw a filter.
pub fn drawFilter(self: *const Canvas, filter: Filter, shape: Shape) void {
    const start_x = @min(@as(i32, @intCast(shape.x)), self.width);
    const start_y = @min(@as(i32, @intCast(shape.y)), self.height);
    const end_x = @min(start_x + shape.width, self.width);
    const end_y = @min(start_y + shape.height, self.height);

    const width = @as(u16, @intCast(end_x - start_x));
    const height = @as(u16, @intCast(end_y - start_y));

    @memset(self.buffer1, 0);
    @memset(self.buffer2, 0);

    const pixels = self.buffer1[0..(@as(u64, @intCast(width)) * height) * 4];

    var global_x = start_x;
    var global_y = start_y;

    while (global_x < end_x) {
        while (global_y < end_y) {
            const old_offset = ((@as(u64, @intCast(global_y)) * self.width) + @as(u64, @intCast(global_x))) * 4;
            const new_offset = ((@as(u64, @intCast(global_y - start_y)) * width) + @as(u64, @intCast(global_x - start_x))) * 4;
            
            std.mem.copyForwards(u8, pixels[new_offset..new_offset + 4], self.pixels[old_offset..old_offset + 4]);

            global_y += 1;
        }

        global_x += 1;
        global_y = start_y;
    }

    filter.applyFilter(width, height, pixels, self.buffer2[0..pixels.len]);

    global_x = start_x;
    global_y = start_y;

    while (global_x < end_x) {
        while (global_y < end_y) {
            const local_x = @as(u16, @intCast(global_x - start_x));
            const local_y = @as(u16, @intCast(global_y - start_y));

            if (shape.getPixel(local_x, local_y)) {
                const offset = ((@as(u64, @intCast(local_y)) * width) + local_x) * 4;

                self.set(global_x, global_y, Color.init(
                    pixels[offset],
                    pixels[offset + 1],
                    pixels[offset + 2],
                    @as(f32, @floatFromInt(pixels[offset + 3])) / 255
                ));
            }

            global_y += 1;
        }

        global_x += 1;
        global_y = start_y;
    }
}

// Save the canvas to a file.
pub fn saveToFile(self: *const Canvas, file_path: []const u8) !void {
    var image = Image{
        .width = self.width,
        .height = self.height,

        .allocator = self.allocator,
        .pixels = self.pixels
    };

    try image.saveToFile(file_path);
}

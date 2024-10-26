const std = @import("std");

const Shape = @This();

x: i16,
y: i16,
width: u16,
height: u16,

constructor: fn (allocator: std.mem.Allocator) error{OutOfMemory}![]bool,

// Create a rectangle.
pub fn rectangle(x: i16, y: i16, width: u16, height: u16) Shape {
    const Closure = struct {
        fn constructor (allocator: std.mem.Allocator) ![]bool {
            const bitmap = try allocator.alloc(bool, @as(u32, @intCast(width)) * @as(u32, @intCast(height)));

            @memset(bitmap, true);

            return bitmap;
        }
    };

    return Shape{
        .x = x,
        .y = y,
        .width = width,
        .height = height,

        .constructor = Closure.constructor
    };
}

// Create a circle.
pub fn circle(x: i16, y: i16, size: u16) Shape {
    const Closure = struct {
        fn constructor (allocator: std.mem.Allocator) ![]bool {
            const bitmap = try allocator.alloc(bool, @as(u32, @intCast(size)) * @as(u32, @intCast(size)));

            @memset(bitmap, false);
        
            const radius = @as(f32, size) / 2;

            var pixel_x = @as(u16, 0);
            var pixel_y = @as(u16, 0); 

            while (pixel_x < size) {
                while (pixel_y < size) {
                    const dx = radius - @as(f32, @floatFromInt(pixel_x));
                    const dy = radius - @as(f32, @floatFromInt(pixel_y));

                    if (std.math.sqrt((dx * dx) + (dy * dy)) < radius) {
                        const index = @as(u32, @intCast(pixel_x)) + (@as(u32, @intCast(pixel_y)) * size);

                        bitmap[index] = true;
                    }

                    pixel_y += 1;
                }

                pixel_x += 1;
                pixel_y = 0;
            }

            return bitmap;
        }
    };

    return Shape{
        .x = x,
        .y = y,
        .width = size,
        .height = size,

        .constructor = Closure.constructor
    };
}

// Apply a mask to the shape.
//pub fn intersect(self: *Shape, shape: Shape) void {
//    var x = @as(u16, 0);
//    var y = @as(u16, 0);
//
//    while (x < self.width) {
//        while (y < self.height) {
//            const index = @as(u32, @intCast(x)) + (@as(u32, @intCast(y)) * self.width);
//
//            self.bitmap[index] = self.bitmap[index] and shape.bitmap[index];
//
//            y += 1;
//        }
//
//        x += 1;
//        y = 0;
//    }
//}

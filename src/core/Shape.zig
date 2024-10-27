const std = @import("std");

const Shape = @This();

x: i16,
y: i16,
width: u16,
height: u16,

getBitmap: *const fn (allocator: std.mem.Allocator) error{OutOfMemory}![]bool,

// Create a rectangle.
pub fn rectangle(x: i16, y: i16, width: u16, height: u16) Shape {
    const closure = opaque {
        pub var closure_width = @as(u16, 0);
        pub var closure_height = @as(u16, 0); 

        pub fn getBitmap(allocator: std.mem.Allocator) error{OutOfMemory}![]bool {
            const bitmap = try allocator.alloc(bool, @as(u32, @intCast(closure_width)) * @as(u32, @intCast(closure_height)));

            @memset(bitmap, true);

            return bitmap;
        }
    };

    closure.closure_width = width;
    closure.closure_height = height;

    return Shape{
        .x = x,
        .y = y,
        .width = width,
        .height = height,

        .getBitmap = &closure.getBitmap
    };
}

// Create a circle.
pub fn circle(x: i16, y: i16, size: u16) Shape {
    const closure = opaque {
        pub var closure_size = @as(u16, 0);

        pub fn getBitmap(allocator: std.mem.Allocator) error{OutOfMemory}![]bool {
            const bitmap = try allocator.alloc(bool, @as(u32, @intCast(closure_size)) * @as(u32, @intCast(closure_size)));

            @memset(bitmap, false);
        
            const radius = @as(f32, @floatFromInt(closure_size)) / 2;

            var pixel_x = @as(u16, 0);
            var pixel_y = @as(u16, 0); 

            while (pixel_x < closure_size) {
                while (pixel_y < closure_size) {
                    const dx = radius - @as(f32, @floatFromInt(pixel_x));
                    const dy = radius - @as(f32, @floatFromInt(pixel_y));

                    if (std.math.sqrt((dx * dx) + (dy * dy)) < radius) {
                        const index = @as(u32, @intCast(pixel_x)) + (@as(u32, @intCast(pixel_y)) * closure_size);

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

    closure.closure_size = size;

    return Shape{
        .x = x,
        .y = y,
        .width = size,
        .height = size,

        .getBitmap = closure.getBitmap
    };
}

// Create a new shape base on the intersect to another shape.
//pub fn intersect(self: *const Shape, shape: Shape) Shape {
//    const Closure = struct {
//        fn getBitmap (allocator: std.mem.Allocator) ![]bool {
//            const shape1_bitmap = try self.getBitmap(allocator);
//            const shape2_bitmap = try shape.getBitmap(allocator);
//
//            const bitmap = try allocator.alloc(bool, shape1_bitmap.len);
//
//            const shape1_width = @as(i16, @intCast(self.width));
//            const shape1_height = @as(i16, @intCast(self.height));
//            const shape2_width = @as(i16, @intCast(shape.width));
//            const shape2_height = @as(i16, @intCast(shape.height));
//
//            var global_x = self.x;
//            var global_y = self.y;
//
//            while (global_x < self.x + shape1_width) {
//                while (global_y < self.y + shape1_height) {
//                    const self_index = @as(u32, @intCast(global_x - self.x)) + ((@as(u32, @intCast(global_y - self.y))) * @as(u32, @intCast(self.width)));
//
//                    if ((global_x >= shape.x and global_x < shape.x + shape2_width) and (global_y >= shape.y and global_y < shape.y + shape2_height)) {
//                        const shape_index = @as(u32, @intCast(global_x - shape.x)) + ((@as(u32, @intCast(global_y - shape.y))) * @as(u32, @intCast(shape.width)));
//
//                        bitmap[self_index] = shape1_bitmap[self_index] and shape2_bitmap[shape_index];
//                    } else {
//                        bitmap[self_index] = false;
//                    }
//
//                    global_y += 1;
//                }
//
//                global_x += 1;
//                global_y = self.y;
//            }
//
//            return bitmap;
//        }
//    };
//
//    return Shape{
//        .x = self.x,
//        .y = self.y,
//        .width = self.width,
//        .height = self.height,
//
//        .getBitmap = Closure.getBitmap
//    };
//}

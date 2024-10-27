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

// Create a rounded rectangle.
pub fn roundRectangle(x: i16, y: i16, width: u16, height: u16, radius: u16) Shape {
    const closure = opaque {
        pub var closure_width = @as(u16, 0);
        pub var closure_height = @as(u16, 0);
        pub var closure_radius = @as(u16, 0);

        pub fn getBitmap(allocator: std.mem.Allocator) error{OutOfMemory}![]bool {
            const bitmap = try allocator.alloc(bool, @as(u32, @intCast(closure_width)) * @as(u32, @intCast(closure_height)));

            @memset(bitmap, true);

            setCornerBitmap(bitmap, 0, 0, closure_radius, closure_radius);
            setCornerBitmap(bitmap, closure_width - closure_radius, 0, closure_width - closure_radius, closure_radius);
            setCornerBitmap(bitmap, 0, closure_height - closure_radius, closure_radius, closure_height - closure_radius);
            setCornerBitmap(bitmap, closure_width - closure_radius, closure_height - closure_radius, closure_width - closure_radius, closure_height - closure_radius);

            return bitmap;
        }

        fn setCornerBitmap(bitmap: []bool, corner_x: u16, corner_y: u16, circle_x: u16, circle_y: u16) void {
            var local_x = @as(f32, @floatFromInt(corner_x));
            var local_y = @as(f32, @floatFromInt(corner_y));

            while (local_x < corner_x + closure_radius) {
                while (local_y < corner_y + closure_radius) {
                    const dx = @as(f32, @floatFromInt(circle_x)) - @as(f32, @floatFromInt(local_x));
                    const dy = @as(f32, @floatFromInt(circle_y)) - @as(f32, @floatFromInt(local_y));

                    if (std.math.sqrt((dx * dx) + (dy * dy)) > @as(f32, @floatFromInt(closure_radius))) {
                        const index = @as(u32, @intCast(local_x)) + (@as(u32, @intCast(local_y)) * closure_width);

                        bitmap[index] = false;
                    }

                    local_y += 1;
                }

                local_x += 1;
                local_y = corner_y;
            }
        }
    };

    closure.closure_width = width;
    closure.closure_height = height;
    closure.closure_radius = @min(radius, @min(width, height) / 2);

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
            var local_x = @as(f32, 0);
            var local_y = @as(f32, 0);

            while (local_x < closure_size) {
                while (local_y < closure_size) {
                    const dx = radius - local_x;
                    const dy = radius - local_y;

                    if (std.math.sqrt((dx * dx) + (dy * dy)) < radius) {
                        const index = @as(u32, @intFromFloat(local_x)) + (@as(u32, @intFromFloat(local_y)) * closure_size);

                        bitmap[index] = true;
                    }

                    local_y += 1;
                }

                local_x += 1;
                local_y = 0;
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

// Center the shape.
pub fn center(self: *const Shape) Shape {
    return Shape{
        .x = self.x - @divTrunc(@as(i16, @intCast(self.width)), 2),
        .y = self.y - @divTrunc(@as(i16, @intCast(self.height)), 2),
        .width = self.width,
        .height = self.height,

        .getBitmap = self.getBitmap
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

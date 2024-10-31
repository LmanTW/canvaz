const std = @import("std");

const Shape = @This();

x: i16,
y: i16,
width: u16,
height: u16,

getPixel: *const fn (local_x: u16, local_y: u16) bool,

// Create a rectangle.
pub fn rectangle(x: i16, y: i16, width: u16, height: u16) Shape {
    const closure = opaque {
        pub fn getPixel(_: u16, _: u16) bool {
            return true;
        }
    };

    return Shape{
        .x = x,
        .y = y,
        .width = width,
        .height = height,

        .getPixel = &closure.getPixel
    };
}

// Create a rounded rectangle.
pub fn roundRectangle(x: i16, y: i16, width: u16, height: u16, radius: u16) Shape {
    const closure = opaque {
        pub var closure_width = @as(u16, 0);
        pub var closure_height = @as(u16, 0);
        pub var closure_radius = @as(u16, 0);

        pub fn getPixel(local_x: u16, local_y: u16) bool {
            if (local_x < closure_radius and local_y < closure_radius) {
                return getCornerPixel(local_x, local_y, closure_radius, closure_radius);
            }
            if (local_x > closure_width - closure_radius and local_y < closure_radius) {
                return getCornerPixel(local_x, local_y, closure_width - closure_radius, closure_radius);
            }
            if (local_x < closure_radius and local_y > closure_height - closure_radius) {
                return getCornerPixel(local_x, local_y, closure_radius, closure_height - closure_radius);
            }
            if (local_x > closure_width - closure_radius and local_y > closure_height - closure_radius) {
                return getCornerPixel(local_x, local_y, closure_width - closure_radius, closure_height - closure_radius);
            }

            return true;
        }

        fn getCornerPixel(local_x: u16, local_y: u16, circle_x: u16, circle_y: u16) bool {
            const dx = @as(f32, @floatFromInt(circle_x)) - @as(f32, @floatFromInt(local_x));
            const dy = @as(f32, @floatFromInt(circle_y)) - @as(f32, @floatFromInt(local_y));

            return std.math.sqrt((dx * dx) + (dy * dy)) < @as(f32, @floatFromInt(closure_radius));
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

        .getPixel = &closure.getPixel
    };
}

// Create a circle.
pub fn circle(x: i16, y: i16, size: u16) Shape {
    const closure = opaque {
        pub var closure_radius = @as(f32, 0);

        pub fn getPixel(local_x: u16, local_y: u16) bool {
            const dx = closure_radius - @as(f32, @floatFromInt(local_x));
            const dy = closure_radius - @as(f32, @floatFromInt(local_y));

            return std.math.sqrt((dx * dx) + (dy * dy)) < closure_radius;
        }
    };

    closure.closure_radius = @as(f32, @floatFromInt(size)) / 2;

    return Shape{
        .x = x,
        .y = y,
        .width = size,
        .height = size,

        .getPixel = &closure.getPixel
    };
}

// Move the shape left.
pub fn left(self: *const Shape, amount: f32) Shape {
    return Shape{
        .x = self.x - @as(i16, @intFromFloat((@as(f32, @floatFromInt(self.width)) * amount))),
        .y = self.y,
        .width = self.width,
        .height = self.height,

        .getPixel = self.getPixel
    };
}

// Move the shape right.
pub fn right(self: *const Shape, amount: f32) Shape {
    return Shape{
        .x = self.x + @as(i16, @intFromFloat((@as(f32, @floatFromInt(self.width)) * amount))),
        .y = self.y,
        .width = self.width,
        .height = self.height,

        .getPixel = self.getPixel
    };
}

// Move the shape up.
pub fn up(self: *const Shape, amount: f32) Shape {
    return Shape{
        .x = self.x,
        .y = self.y - @as(i16, @intFromFloat((@as(f32, @floatFromInt(self.height)) * amount))),
        .width = self.width,
        .height = self.height,

        .getPixel = self.getPixel
    };
}

// Move the shape down.
pub fn down(self: *const Shape, amount: f32) Shape {
    return Shape{
        .x = self.x,
        .y = self.y + @as(i16, @intFromFloat((@as(f32, @floatFromInt(self.height)) * amount))),
        .width = self.width,
        .height = self.height,

        .getPixel = self.getPixel
    };
}

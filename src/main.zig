const std = @import("std");

pub const Canvas = @import("./core/Canvas.zig");
pub const Filter = @import("./core/Filter.zig");
pub const Color = @import("./core/Color.zig");
pub const Shape = @import("./core/Shape.zig");
pub const Image = @import("./core/Image.zig");

// Initialize a canvas.
pub fn init(width: u16, height: u16, allocator: std.mem.Allocator) !Canvas {
    return try Canvas.init(width, height, allocator);
}

// The main function.
pub fn main() !void {
}

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

const canvaz = @This();

// The main function :3
pub fn main() !void {
    const canvas = try canvaz.init(512, 512, std.heap.page_allocator);
    defer canvas.deinit();

    const image = try Image.initFromFile("image.png", canvas.allocator);
    defer image.deinit();

    canvas.drawImage(image, Shape.circle(0, 0, 512), .cover);
    canvas.drawFilter(Filter.posterize(0.15), Shape.circle(0, 0, 256));

    try canvas.saveToFile("result.png");
}

const std = @import("std");

pub const Texture = @import("./core/Texture.zig");
pub const Canvas = @import("./core/Canvas.zig");
pub const Color = @import("./core/Color.zig");
pub const Shape = @import("./core/Shape.zig");

// The main function :3
pub fn main() !void {
    var canvas = try Canvas.init(256, 256, std.heap.page_allocator);
    defer canvas.deinit();

    canvas.clear(Color.black);

    try canvas.draw(Shape.rectangle(32, 32, 192, 32), Color.white);
    try canvas.draw(Shape.circle(96, 160, 64), Color.white);

    try canvas.save("result.png");
}

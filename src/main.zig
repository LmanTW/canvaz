const std = @import("std");

pub const Canvas = @import("./core/Canvas.zig");
pub const Color = @import("./core/Color.zig");
pub const Shape = @import("./core/Shape.zig");
pub const Image = @import("./core/Image.zig");

// Initialize a canvas.
pub fn init(width: u16, height: u16, allocator: std.mem.Allocator) !Canvas {
    return try Canvas.init(width, height, allocator);
}

const Canvaz = @This();

// The main function :3
pub fn main() !void {
      var canvas = try Canvaz.init(512, 512, std.heap.page_allocator);
      defer canvas.deinit();
      
      var image = try Image.initFromFile("image.png", canvas.allocator);
      defer image.deinit();

      try image.saveToFile("result.png");

      canvas.fill(Color.black);
      canvas.drawShape(Shape.circle(0, 0, 512), Color.black);
      canvas.drawImage(image, Shape.circle(0, 0, 512));
      
      try canvas.saveToFile("canvas.png");
}

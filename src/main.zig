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
      var canvas = try Canvaz.init(256, 256, std.heap.page_allocator);
      defer canvas.deinit(); 

      var image = try Image.initFromFile("image.png", canvas.allocator);
      defer image.deinit();

      canvas.fill(Color.black);
      canvas.drawShape(Shape.roundedRectangle(0, 0, 256, 256, 256), Color.white);
      canvas.drawImage(image, Shape.roundedRectangle(0, 0, 256, 256, 64));
      
      try canvas.saveToFile("canvas.png");
}

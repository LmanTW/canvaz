const zigimg = @import("zigimg");
const std = @import("std");

const Color = @import("./Color.zig");

const Image = @This();

width: u16,
height: u16,

allocator: std.mem.Allocator,
pixels: []u8,

// Initialize the image.
pub fn init(width: u16, height: u16, allocator: std.mem.Allocator) !Image {
    const pixels = try allocator.alloc(u8, (@as(u64, @intCast(width)) * @as(u64, @intCast(height))) * 4);

    @memset(pixels, 0);

    return Image{
        .width = width,
        .height = height,

        .allocator = allocator,
        .pixels = pixels
    };
}

// Initialize the image from a file.
pub fn initFromFile(file_path: []const u8, allocator: std.mem.Allocator) !Image {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const buffer = try allocator.alloc(u8, try file.getEndPos());
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

   return initFromMemory(buffer, allocator);
}

// Initialize the image from the memory.
pub fn initFromMemory(buffer: []const u8, allocator: std.mem.Allocator) !Image {
    var zimage = try zigimg.Image.fromMemory(allocator, buffer);
    defer zimage.deinit();

    try zimage.convert(.rgba32);

    const pixels = try allocator.alloc(u8, (@as(u64, @intCast(zimage.width)) * @as(u64, @intCast(zimage.height))) * 4);
    std.mem.copyForwards(u8, pixels, zimage.pixels.asBytes());

    return Image{
        .width = @as(u16, @intCast(zimage.width)),
        .height = @as(u16, @intCast(zimage.height)),

        .allocator = allocator,
        .pixels = pixels
    };
}

// Deinitialize the image.
pub fn deinit(self: *Image) void {
    self.allocator.free(self.pixels);
}

// Scale the image.
pub fn scale(self: *Image, width: u16, height: u16) !void {
    const pixels = try self.allocator.alloc(u8, (@as(u64, @intCast(width)) * @as(u64, @intCast(height))) * 4);

    const width_scale = @as(f32, @floatFromInt(self.width)) / @as(f32, @floatFromInt(width));
    const height_scale = @as(f32, @floatFromInt(self.height)) / @as(f32, @floatFromInt(height)); 
    var new_x = @as(f32, 0);
    var new_y = @as(f32, 0);

    while (new_x < width) {
        while (new_y < height) {
            const old_x = @as(u64, @intFromFloat(width_scale * new_x));
            const old_y = @as(u64, @intFromFloat(height_scale * new_y));

            const old_offset = (old_x + (old_y * @as(u64, @intCast(self.width)))) * 4;
            const new_offset = (new_x + (new_y * @as(u64, @intCast(width)))) * 4;

            std.mem.copyForwards(u8, pixels[new_offset..new_offset + 4], self.pixels[old_offset..old_offset + 4]);

            new_y += 1;
        }

        new_x += 1;
        new_y = 0;
    }

    self.width = width;
    self.height = height;

    self.allocator.free(self.pixels);
    self.pixels = pixels;
}

// Crop the image.
pub fn crop(self: *Image, x: u16, y: u16, width: u16, height: u16) !void {
    const pixels = try self.allocator.alloc(u8, (@as(u64, @intCast(width)) * @as(u64, @intCast(height))) * 4);

    const start_x = @min(x, self.width);
    const start_y = @min(y, self.height);
    const end_x = @min(x + width, self.width);
    const end_y = @min(y + height, self.height);

    var old_x = @as(u16, start_x);
    var old_y = @as(u16, start_y);

    while (old_x < end_x) {
        while (old_y < end_y){
            const new_x = old_x - start_x;
            const new_y = old_y - start_y;

            const old_offset = (old_x + (old_y * @as(u64, @intCast(self.width)))) * 4;
            const new_offset = (new_x + (new_y * @as(u64, @intCast(width)))) * 4;

            std.mem.copyForwards(u8, pixels[new_offset..new_offset + 4], self.pixels[old_offset..old_offset + 4]);

            old_y += 1;
        }

        old_x += 1;
        old_y = start_y;
    }


    self.width = end_x - start_x;
    self.height = end_y - start_y;

    self.allocator.free(self.pixels);
    self.pixels = pixels;
}

// Save the image to a file.
pub fn saveToFile(self: *Image, file_path: []const u8) !void {
    var zimage = try zigimg.Image.fromRawPixels(self.allocator, self.width, self.height, self.pixels, .rgba32);
    defer zimage.deinit();

    const index = std.mem.indexOfAny(u8, file_path, ".");

    if (index == null) {
        return error.FormatNotFound;
    } else {
        const extension = file_path[index.? .. file_path.len];

        if (std.mem.eql(u8, extension, ".bmp")) try zimage.writeToFilePath(file_path, .{ .bmp = .{} })
        else if (std.mem.eql(u8, extension, ".png")) try zimage.writeToFilePath(file_path, .{ .png = .{} })
        else {
            return error.UnsupportedPixelFormat;
        }
    }
}

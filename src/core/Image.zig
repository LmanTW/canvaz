const zigimg = @import("zigimg");
const std = @import("std");

const Image = @This();

width: u16,
height: u16,

allocator: std.mem.Allocator,
pixels: []u8,

// Initialize an image.
pub fn init(width: u16, height: u16, allocator: std.mem.Allocator) !Image {
    const pixels = try allocator.alloc(u8, (@as(u64, @intCast(width)) * height) * 4);

    @memset(pixels, 0);

    return Image{
        .width = width,
        .height = height,

        .allocator = allocator,
        .pixels = pixels
    };
}

// Initialize an image from a file.
pub fn initFromFile(file_path: []const u8, allocator: std.mem.Allocator) !Image {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const buffer = try allocator.alloc(u8, try file.getEndPos());
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    return initFromMemory(buffer, allocator);
}

// Initialize an image from the memory.
pub fn initFromMemory(buffer: []const u8, allocator: std.mem.Allocator) !Image {
    var zimage = try zigimg.Image.fromMemory(allocator, buffer);
    defer zimage.deinit();

    if (zimage.width > std.math.maxInt(u16) or zimage.height > std.math.maxInt(u16)) {
        return error.ImageTooLarge;
    }

    try zimage.convert(.rgba32);

    const pixels = try allocator.alloc(u8, (@as(u64, @intCast(zimage.width)) * zimage.height) * 4);
    std.mem.copyForwards(u8, pixels, zimage.pixels.asBytes()); 

    return Image{
        .width = @as(u16, @intCast(zimage.width)),
        .height = @as(u16, @intCast(zimage.height)),

        .allocator = allocator,
        .pixels = pixels
    };
}

// Deinitialize the image.
pub fn deinit(self: *const Image) void {
    self.allocator.free(self.pixels);
}

// Scale the image.
pub fn scale(self: *Image, width: u16, height: u16) !void {
    const pixels = try self.allocator.alloc(u8, (@as(u64, width) * height) * 4);

    const width_scale = @as(f32, @floatFromInt(self.width)) / @as(f32, @floatFromInt(width));
    const height_scale = @as(f32, @floatFromInt(self.height)) / @as(f32, @floatFromInt(height));
    var new_x = @as(u64, 0);
    var new_y = @as(u64, 0);

    while (new_x < width) {
        while (new_y < height) {
            const old_x = @as(u64, @intFromFloat(@as(f32, @floatFromInt(new_x)) * width_scale));
            const old_y = @as(u64, @intFromFloat(@as(f32, @floatFromInt(new_y)) * height_scale));

            const old_offset = (old_x + (old_y * self.width)) * 4;
            const new_offset = (new_x + (new_y * width)) * 4;

            if (self.pixels.len > 0) {
                std.mem.copyForwards(u8, pixels[new_offset..new_offset + 4], self.pixels[old_offset..old_offset + 4]);
            }

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

// Save the image to a file.
pub fn saveToFile(self: *const Image, file_path: []const u8) !void {
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

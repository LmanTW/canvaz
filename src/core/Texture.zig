const zigimg = @import("zigimg");
const std = @import("std");

const Texture = @This();

width: u16,
height: u16,

allocator: std.mem.Allocator,
pixels: []u8,

// Initialize the texture.
pub fn init(width: u16, height: u16, allocator: std.mem.Allocator) !Texture {
    const pixels = try allocator.alloc(u8, (@as(u64, @intCast(width)) * @as(u64, @intCast(height))) * 4);

    @memset(pixels, 0);

    return Texture{
        .width = width,
        .height = height,

        .allocator = allocator,
        .pixels = pixels
    };
}

// Deinitialize the texture.
pub fn deinit(self: *Texture) void {
    self.allocator.free(self.pixels);
}

// Load the texture from a file.
pub fn loadFromFile(file_path: []const u8, allocator: std.mem.Allocator) !Texture {
    const file = try std.fs.cwd().openFile(file_path);
    defer file.close();

    const buffer = try allocator.alloc(u8, try file.getEndPos());
    defer allocator.free(buffer);

    return loadFromMemory(buffer, allocator);
}

// Load the texture from the memory.
pub fn loadFromMemory(buffer: []const u8, allocator: std.mem.Allocator) !Texture {
    const image = try zigimg.Image.fromMemory(allocator, buffer);
    defer image.deinit();

    const texture = try Texture.init(image.width, image.height, allocator);

    var image_index = @as(u64, 0);
    var texture_index = @as(u64, 0);

    switch (image.pixelFormat()) {
        .rgb24 => {
            while (image_index < image.pixels.len) {
                image.pixels[texture_index] = image.pixels[image_index];
                image.pixels[texture_index + 1] = image.pixels[image_index + 1];
                image.pixels[texture_index + 2] = image.pixels[image_index + 2];
                image.pixels[texture_index + 3] = 255;

                image_index += 3;
                texture_index += 4;
            }
        },
        .bgr24 => {
            while (image_index < image.pixels.len) {
                image.pixels[texture_index] = image.pixels[image_index + 2];
                image.pixels[texture_index + 1] = image.pixels[image_index + 1];
                image.pixels[texture_index + 2] = image.pixels[image_index];
                image.pixels[texture_index + 3] = 255;

                image_index += 3;
                texture_index += 4;
            }
        },
        .rgba32 => {
            std.mem.copyForwards(u8, image.pixels, image.pixels);
        },
        else => error.UnsupportedPixelFormat
    }

    return texture;
}

// Save the texture to a file.
pub fn saveToFile(self: *Texture, file_path: []const u8) !void {
    var image = try zigimg.Image.fromRawPixels(self.allocator, self.width, self.height, self.pixels, .rgba32);
    defer image.deinit();

    const index = std.mem.indexOfAny(u8, file_path, ".");

    if (index == null) {
        return error.FormatNotFound;
    } else {
        const extension = file_path[index.? .. file_path.len];

        if (std.mem.eql(u8, extension, ".png")) try image.writeToFilePath(file_path, .{ .png = .{} })
        else {
            return error.UnsupportedPixelFormat;
        }
    }
}

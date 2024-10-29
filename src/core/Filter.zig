const std = @import("std");

const Color = @import("./Color.zig");

const Filter = @This();

applyFilter: *const fn (width: u16, height: u16, pixels: []u8, offset_map: []u64, allocator: std.mem.Allocator) error{OutOfMemory}!void,

// Create a posterize filter.
pub fn posterize(level: f32) Filter {
    const closure = opaque {
        pub var closure_level = @as(f32, 0);

        pub fn applyFilter(_: u16, _: u16, pixels: []u8, offset_map: []u64, _: std.mem.Allocator) error{OutOfMemory}!void {
            for (offset_map) |offset| {
                const color = Color.init(pixels[offset], pixels[offset + 1], pixels[offset + 2], 0).posterize(closure_level);

                // std.debug.print("{} {} {}\n", .{pixels[offset], pixels[offset + 1], pixels[offset + 2]});

                pixels[offset] = color.r;
                pixels[offset + 1] = color.g;
                pixels[offset + 2] = color.b;
            }
        }
    };

    closure.closure_level = level;

    return Filter{
        .applyFilter = closure.applyFilter
    };
}

// Create a brightness filter.
pub fn brightness(level: f32) Filter {
    const closure = opaque {
        pub var closure_level = @as(f32, 0);

        pub fn applyFilter(_: u16, _: u16, pixels: []u8, offset_map: []u64, _: std.mem.Allocator) error{OutOfMemory}!void {
            for (offset_map) |offset| {
                const color = Color.init(pixels[offset], pixels[offset + 1], pixels[offset + 2], 0).setBrightness(closure_level);

                pixels[offset] = color.r;
                pixels[offset + 1] = color.g;
                pixels[offset + 2] = color.b;
            }
        }
    };

    closure.closure_level = level;

    return Filter{
        .applyFilter = closure.applyFilter
    };
}

const std = @import("std");

const Color = @import("./Color.zig");

const Filter = @This();

applyFilter: *const fn (width: u16, height: u16, pixels: []u8, buffer: []u8) void,

// Create a posterize filter.
pub fn posterize(level: f32) Filter {
    const closure = opaque {
        pub var closure_level = @as(f32, 0);

        pub fn applyFilter(_: u16, _: u16, pixels: []u8, _: []u8) void {
            var offset = @as(u64, 0);

            while (offset < pixels.len) {
                const color = Color.init(pixels[offset], pixels[offset + 1], pixels[offset + 2], 0).posterize(closure_level);

                pixels[offset] = color.r;
                pixels[offset + 1] = color.g;
                pixels[offset + 2] = color.b;

                offset += 4;
            }
        }
    };

    closure.closure_level = level;

    return Filter{
        .applyFilter = closure.applyFilter
    };
}

// Create a brighten filter.
pub fn brighten(level: f32) Filter {
    const closure = opaque {
        pub var closure_level = @as(f32, 0);

        pub fn applyFilter(_: u16, _: u16, pixels: []u8, _: []u8) void {
            var offset = @as(u64, 0);

            while (offset < pixels.len) {
                const color = Color.init(pixels[offset], pixels[offset + 1], pixels[offset + 2], 0).brighten(closure_level);

                pixels[offset] = color.r;
                pixels[offset + 1] = color.g;
                pixels[offset + 2] = color.b;

                offset += 4;
            }
        }
    };

    closure.closure_level = level;

    return Filter{
        .applyFilter = closure.applyFilter
    };
}

// Create a darken filter.
pub fn darken(level: f32) Filter {
    const closure = opaque {
        pub var closure_level = @as(f32, 0);

        pub fn applyFilter(_: u16, _: u16, pixels: []u8, _: []u8) void {
            var offset = @as(u64, 0);

            while (offset < pixels.len) {
                const color = Color.init(pixels[offset], pixels[offset + 1], pixels[offset + 2], 0).darken(closure_level);

                pixels[offset] = color.r;
                pixels[offset + 1] = color.g;
                pixels[offset + 2] = color.b;

                offset += 4;
            }
        }
    };

    closure.closure_level = level;

    return Filter{
        .applyFilter = closure.applyFilter
    };
}

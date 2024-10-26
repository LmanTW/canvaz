# Canvaz

A simple, easy-to-use image processing library written entirely in Zig.

> [!WARNING]
> Still in early development.

## Example

```zig
const canvaz = @import("canvaz");
const std = @import("std");

pub fn main() !void {
    const Canvas = canvaz.Canvas;
    const Color = canvaz.Color;
    const Shape = canvaz.Shape;

    var canvas = try Canvas.init(256, 256, std.heap.page_allocator);
    defer canvas.deinit();

    canvas.clear(Color.black);

    try canvas.draw(Shape.rectangle(32, 32, 192, 32), Color.white);
    try canvas.draw(Shape.circle(96, 160, 64), Color.white);

    try canvas.save("result.png");
}
```

## Installation

1. Add Canvaz using the package manager.

```sh
zig fetch --save "https://github.com/zigimg/zigimg/archive/[commit hash].tar.gz"
```

2. Add Canvaz as a dependency in your `build.zig`.

```zig
const canvaz = b.dependency("canvaz", .{
    .target = target,
    .optimize = optimize
})

exe.root_module.addImport("canvaz", canvaz.module("canvaz"));
```

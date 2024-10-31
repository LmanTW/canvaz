# Canvaz

A simple, easy-to-use image processing library written entirely in Zig.

> [!NOTE]
> Canvaz is still in early development, so breaking changes might get introduced.

## Example

```zig
const canvaz = @import("canvaz");
const std = @import("std");

const Shape = canvaz.Shape;

pub fn main() !void {
    const canvas = try canvaz.init(512, 512, std.heap.page_allocator);
    defer canvas.deinit();

    const image = try canvaz.Image.initFromFile("image.png", canvas.allocator);
    defer image.deinit();

    canvas.drawShape(Shape.circle(0, 0, 512), canvaz.Color.black);
    canvas.drawImage(image, Shape.roundRectangle(256, 256, 320, 320, 32).move(-0.5, -0.5), .cover);
    canvas.drawFilter(canvaz.Filter.posterize(0.15), Shape.rectangle(0, 0, 256, 512));

    try canvas.saveToFile("result.png");
}
```

## Installation

1. Add Canvaz using the package manager.

```sh
zig fetch --save "https://github.com/zigimg/zigimg/archive/[commit hash].tar.gz"
```

2. Add Canvaz as a dependency to your `build.zig`.

```zig
const canvaz = b.dependency("canvaz", .{
    .target = target,
    .optimize = optimize
})

exe.root_module.addImport("canvaz", canvaz.module("canvaz"));
```

> [!WARNING]
> Canvaz uses [zigimg](https://github.com/zigimg/zigimg) which uses the nominated [2024.10.0-mach](https://machengine.org/about/nominated-zig/) version of Zig.

## API Documentation

Canvaz is designed to be simple and easy-to-use while still offering the capability for advanced graphics processing. As a result, you can easily perform image and filter masking in Canvaz.

### Creating and moving a shape.

```zig
const Shape = canvaz.Shape;

// You can create a shape and assign it to an variable.
const rectangle = Shape.rectangle(0, 0, 255, 255);

// Move the shape relatively by its size.
rectangle.move(-0.5, -0.5);
rectangle.left(0.5);
rectangle.right(0.5);
rectangle.up(0.5);
rectangle.down(-0.5);

// Note: Operations these return a new shape.
// Note: It's better if just use it inline.

Shape.rectangle(0, 0, 255, 255).move(-0.5, -0.5)
```

### Drawing a shape.

```zig
const Color = canvaz.Color;
const Shape = canvaz.Shape;

const canvas = try canvaz.init(512, 512, std.heap.page_allocator);
defer canvas.deinit();

canvas.drawShape(Shape.rectangle(0, 0, 512, 512), Color.black);
canvas.drawShape(Shape.circle(256, 256, 64).move(-0.5, -0.5), Color.white);

// Note: Circle is not centered by default, so we need to center it manually.

try canvas.saveToFile("result.png");
```

### Drawing an image.

```zig
const Shape = canvaz.Shape;

pub fn main() !void {
    const canvas = try canvaz.init(512, 512, std.heap.page_allocator);
    defer canvas.deinit();

    const image = try canvaz.Image.initFromFile("image.png");
    defer image.deinit();

    canvas.drawImage(image, Shape.rectangle(0, 0, 512, 512), .cover);
    canvas.drawImage(image, Shape.circle(256, 256, 64).move(-0.5, -0.5), .scale);
        
    try canvas.saveToFile("result.png");
}
```

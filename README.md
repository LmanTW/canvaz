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

# Guide

Canvaz is designed to be simple and easy-to-use while still offering the capability for advanced more graphics processing. As a result, you can easily perform image and filter masking in Canvaz.

### Canvas

<table>

<tr>
  <td>Initialize and saving a canvas.</td>
  <td>Clearing and filling the canvas.</td>
</tr>
  
<tr>
<td>
    
```zig
const canvas = try canvaz.init(512, 512, std.heap.page_allocator);
defer canvas.deinit();

// Save the canvas to a file.
canvas.saveToFile("result.png")
```
  
</td>
<td>

```zig
// Clear the canvas.
canvas.clear();

// Fill the canvas with a color.
canvas.fill(canvaz.Color.black)
```

</td>
</tr>

</table>

### Color

<table>

<tr>
  <td>Initialize a color.</td>
  <td>Modifing the color.</td>
</tr>
  
<tr>
<td>
    
```zig
// Initialize a color from RGBA.
canvaz.Color.init(247, 164, 29, 1);

// Initialize a color from Hex.
canvaz.Color.initFromHex("#F7A41D");
```
  
</td>
<td>
    
```zig
const color = canvaz.Color.init(247, 164, 29, 1);

// Modify the color.
_ = canvaz.Color.posterize(0.25);

// Note: These methods return a new color, so it's better to use them inline.
```
  
</td>
</tr>

</table>

### Shape

<table>

<tr>
  <td>Initialize a shape.</td>
  <td>Moving the shape.</td>
  <td>Drawing the shape.</td>
</tr>
  
<tr>
<td>
    
```zig
// Initialize a shape.
_ = canvaz.Shape.rectangle(0, 0, 256, 256);
_ = canvaz.Shape.roundRectangle(0, 0, 256, 256, 64);
_ = canvaz.Shape.roundRectangle(0, 0, 256);
```
  
</td>
<td>
    
```zig
const rectangle = canvaz.Shape.rectangle(0, 0, 256, 256);

// Move the shape relatively by its size.
_ = rectangle.move(-0.5, -0.5);
_ = rectangle.left(0.5);
_ = rectangle.right(0.5);
_ = rectangle.up(0.5);
_ = rectangle.down(-0.5);

// Note: These methods return a new shape, so it's better to use them inline.
```
  
</td>
<td>
    
```zig
const canvas = try canvaz.init(512, 512, std.heap.page_allocator);
defer canvas.deinit();

// Draw a centered circle.
canvas.drawShape(canvaz.Shape.circle(256, 256, 512).move(-0.5, -0.5), canvaz.Color.white);
```
  
</td>
</tr>

</table>

### Image

<table>

<tr>
  <td>Initialize an image.</td>
  <td>Scaling the image.</td>
  <td>Drawing the image.</td>
</tr>
  
<tr>
<td>
    
```zig
// Initialize an image from a file.
const image_file = try canvaz.Image.initFromFile("image.png", std.heap.page_allocator);
defer image_file.deinit();

// Initialize an image from the memory.
const image_memory = try canvaz.Image.initFromFile(<buffer>, std.heap.page_allocator);
defer image_memory.deinit();
```
  
</td>
<td>
    
```zig
var image = try canvaz.Image.initFromFile("image.png", std.heap.page_allocator);
defer image.deinit();

// Scale the image.
try image.scale(64, 64);
```
  
</td>
<td>
    
```zig
const canvas = try canvaz.init(512, 512, std.heap.page_allocator);
defer canvas.deinit();

const image = try canvaz.Image.initFromFile("image.png", std.heap.page_allocator);
defer image.deinit();

// Draw the image with a rounded rectangle mask.
canvas.drawImage(image, canvaz.Shape.roundRectangle(0, 0, 512, 512, 64), .cover);
```
  
</td>
</tr>

</table>

### Filter

<table>

<tr>
  <td>Drawing the filter.</td>
</tr>
  
<tr>
<td>
    
```zig
const canvas = try canvaz.init(512, 512, std.heap.page_allocator);
defer canvas.deinit();

// Draw a filter with a circle mask.
canvas.drawFilter(canvaz.Filter.brighten(0.5), canvaz.Shape.circle(0, 0, 512));
```
  
</td> 
</tr>

</table>

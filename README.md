# Canvaz

A simple, easy-to-use image processing library written entirely in Zig.

> [!WARNING]
> Still in very early development.

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

# Canvaz

A simple, easy-to-use image processing library written entirely in Zig.

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

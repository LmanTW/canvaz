const std = @import("std");

// Build Canvaz.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zigimg = b.dependency("zigimg", .{
        .target = target,
        .optimize = optimize
    }); 

    const canvaz = b.addModule("canvaz", .{
        .root_source_file = b.path("src/main.zig"),

        .target = target,
        .optimize = optimize,
    });
    canvaz.addImport("zigimg", zigimg.module("zigimg"));

    const exe = b.addExecutable(.{
        .name = "canvaz",
        .root_source_file = b.path("src/main.zig"),

        .target = target,
        .optimize = optimize
    });
    exe.root_module.addImport("zigimg", zigimg.module("zigimg"));

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run and test Canvaz.");
    run_step.dependOn(&run_exe.step);
}

const std = @import("std");

pub const Options = struct {
    build_mode: std.builtin.Mode,
    target: std.zig.CrossTarget,
};

fn installExe(b: *std.Build, exe: *std.build.LibExeObjStep, comptime name: []const u8) !void{
    exe.want_lto = false;
    if (exe.optimize == .ReleaseFast)
        exe.strip = true;

    const install = b.step(name, "Build '" ++ name);
    install.dependOn(&b.addInstallArtifact(exe).step);

    const run_step = b.step(name ++ "-run", "Run " ++ name);
    const run_cmd = exe.run();
    run_cmd.step.dependOn(install);
    run_step.dependOn(&run_cmd.step);

    b.getInstallStep().dependOn(install);
}


pub fn build(b: *std.build.Builder) !void {

    const options = Options{
        .build_mode = b.standardOptimizeOption(.{}),
        .target = b.standardTargetOptions(.{}),
    };

    // const hello_triangle = @import("src/getting_started/hello_triangle/build.zig");
    // const hello_rectangle = @import("src/getting_started/hello_rectangle/build.zig");
    // const shaders = @import("src/getting_started/shaders/build.zig");
    // const textures = @import("src/getting_started/textures/build.zig");
    // const transformations = @import("src/getting_started/transformations/build.zig");
    // const coordinate_systems = @import("src/getting_started/coordinate_systems/build.zig");
    // const camera_rotate = @import("src/getting_started/camera_rotate/build.zig");
    const simple_camera = @import("src/getting_started/simple_camera/build.zig");

    // try installExe(b, hello_triangle.build(b, options), "hello_triangle");
    // try installExe(b, hello_rectangle.build(b, options), "hello_rectangle");
    // try installExe(b, shaders.build(b, options), "shaders");
    // try installExe(b, textures.build(b, options), "textures");
    // try installExe(b, transformations.build(b, options), "transformations");
    // try installExe(b, coordinate_systems.build(b, options), "coordinate_systems");
    // try installExe(b, camera_rotate.build(b, options), "camera_rotate");
    try installExe(b, simple_camera.build(b, options), "simple_camera");
}
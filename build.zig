const std = @import("std");
const glfw = @import("libs/mach-glfw/build.zig");
const zstbi = @import("libs/zstbi/build.zig");
const zmath = @import("libs/zmath/build.zig");

pub const Options = struct {
    build_mode: std.builtin.Mode,
    target: std.zig.CrossTarget,
};

const pkgs = struct {
    const gl = std.build.Pkg{
        .name = "gl",
        .source = .{.path = "libs/gl.zig"},
        .dependencies = &[_]std.build.Pkg{},
    };
    const shader = std.build.Pkg{
        .name = "Shader",
        .source = .{.path = "libs/Shader.zig"},
        .dependencies = &[_]std.build.Pkg{gl},
    };
        const common = std.build.Pkg{
        .name = "common",
        .source = .{.path = "libs/common.zig"},
        .dependencies = &[_]std.build.Pkg{},
    };
    const camera = std.build.Pkg{
        .name = "Camera",
        .source = .{.path = "libs/Camera.zig"},
        .dependencies = &[_]std.build.Pkg{gl, shader, zmath.pkg, common},
    };
};


fn installExe(b: *std.build.Builder, exe: *std.build.LibExeObjStep, comptime name: []const u8) !void{
    exe.want_lto = false;
    if (exe.build_mode == .ReleaseFast)
        exe.strip = true;

    exe.addPackage(glfw.pkg);
    exe.addPackage(zstbi.pkg);
    exe.addPackage(zmath.pkg);
    exe.addPackage(pkgs.gl);
    exe.addPackage(pkgs.shader);
    exe.addPackage(pkgs.common);
    exe.addPackage(pkgs.camera);

    try glfw.link(b, exe, .{});
    zstbi.link(exe);

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
        .build_mode = b.standardReleaseOptions(),
        .target = b.standardTargetOptions(.{}),
    };

    const hello_triangle = @import("src/getting_started/hello_triangle/build.zig");
    const hello_rectangle = @import("src/getting_started/hello_rectangle/build.zig");
    const shaders = @import("src/getting_started/shaders/build.zig");
    const textures = @import("src/getting_started/textures/build.zig");
    const transformations = @import("src/getting_started/transformations/build.zig");
    const coordinate_systems = @import("src/getting_started/coordinate_systems/build.zig");
    const camera_rotate = @import("src/getting_started/camera_rotate/build.zig");
    const simple_camera = @import("src/getting_started/simple_camera/build.zig");

    try installExe(b, hello_triangle.build(b, options), "hello_triangle");
    try installExe(b, hello_rectangle.build(b, options), "hello_rectangle");
    try installExe(b, shaders.build(b, options), "shaders");
    try installExe(b, textures.build(b, options), "textures");
    try installExe(b, transformations.build(b, options), "transformations");
    try installExe(b, coordinate_systems.build(b, options), "coordinate_systems");
    try installExe(b, camera_rotate.build(b, options), "camera_rotate");
    try installExe(b, simple_camera.build(b, options), "simple_camera");
}
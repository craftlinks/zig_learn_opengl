const std = @import("std");
const zmath = @import("../../../libs/zmath/build.zig");
const zstbi = @import("../../../libs/zstbi/build.zig");
const zglfw = @import("../../../libs/zglfw/build.zig");

const Options = @import("../../../build.zig").Options;

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}

const content_dir = "content/";

pub fn build(b: *std.Build, options: Options) *std.build.CompileStep {
    
    const zmath_pkg = zmath.package(b, .{});
    const zstbi_pkg = zstbi.package(b, .{});
    const zglfw_pkg = zglfw.package(b, .{});
    
    
    const gl = b.createModule(
        .{
            .source_file = .{.path = "libs/gl.zig"},
            .dependencies = &.{}
        }
    );
    const shader = b.createModule(
        .{
            .source_file = .{.path = "libs/Shader.zig"},
            .dependencies = &.{}
        }
    );
    const common = b.createModule(
        .{
            .source_file = .{.path = "libs/common.zig"},
            .dependencies = &.{}
        }
    );
    const camera = b.createModule(
        .{
            .source_file = .{.path = "libs/Camera.zig"},
            .dependencies = &.{
                .{ .name = "gl", .module = gl},
                .{ .name = "Shader", .module = shader},
                .{ .name = "common", .module = common},
                .{ .name = "zmath", .module = zmath_pkg.module}
            }
        }
    );
    
    const exe = b.addExecutable(.{
        .name = "simple_camera",
        .root_source_file = .{.path = thisDir() ++ "/main.zig"},
        .target = options.target,
        .optimize = options.build_mode,
    });

    const install_content_step = b.addInstallDirectory(.{
        .source_dir = thisDir() ++ "/" ++ content_dir,
        .install_dir = .{ .custom = "" },
        .install_subdir = "bin/" ++ content_dir,
    });
    exe.step.dependOn(&install_content_step.step);

    exe.addModule("zstbi", zstbi_pkg.module);
    exe.addModule("zmath", zmath_pkg.module);
    exe.addModule("gl", gl);
    exe.addModule("Shader", shader);
    exe.addModule("common", common);
    exe.addModule("Camera", camera);
    exe.addModule("glfw", zglfw_pkg.module);

    zglfw.link(exe);
    zstbi.link(exe);

    return exe;
}

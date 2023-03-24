const std = @import("std");

const Options = @import("../../../build.zig").Options;

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}

const content_dir = "content/";

pub fn build(b: *std.build.Builder, options: Options) *std.build.CompileStep {
    const exe = b.addExecutable(.{
        .name = "basic_lighting",
        .root_source_file = .{ .path = thisDir() ++ "/main.zig" },
        .target = options.target,
        .optimize = options.build_mode,
    });

    const install_content_step = b.addInstallDirectory(.{
        .source_dir = thisDir() ++ "/" ++ content_dir,
        .install_dir = .{ .custom = "" },
        .install_subdir = "bin/" ++ content_dir,
    });
    exe.step.dependOn(&install_content_step.step);

    return exe;
}

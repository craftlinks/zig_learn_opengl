const std = @import("std");

const Options = @import("../../../build.zig").Options;

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}

pub fn build(b: *std.Build, options: Options) *std.build.CompileStep {
    const exe = b.addExecutable(.{
        .name = "hello_rectangle",
        .root_source_file = .{ .path = thisDir() ++ "/main.zig" },
        .target = options.target,
        .optimize = options.build_mode,
    });

    return exe;
}

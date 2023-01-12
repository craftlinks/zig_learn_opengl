const std = @import("std");


pub const Options = struct {
    build_mode: std.builtin.Mode,
    target: std.zig.CrossTarget,
};


fn installExe(b: *std.build.Builder, exe: *std.build.LibExeObjStep, comptime name: []const u8) void{
    exe.want_lto = false;
    if (exe.build_mode == .ReleaseFast)
        exe.strip = true;

    const install = b.step(name, "Build '" ++ name);
    install.dependOn(&b.addInstallArtifact(exe).step);

    const run_step = b.step(name ++ "-run", "Run " ++ name);
    const run_cmd = exe.run();
    run_cmd.step.dependOn(install);
    run_step.dependOn(&run_cmd.step);

    b.getInstallStep().dependOn(install);

}


pub fn build(b: *std.build.Builder) void {

    const options = Options{
        .build_mode = b.standardReleaseOptions(),
        .target = b.standardTargetOptions(.{}),
    };

    const hello_window = @import("getting_started/hello_window/build.zig");

    installExe(b, hello_window.build(b, options), "hello_window");

}



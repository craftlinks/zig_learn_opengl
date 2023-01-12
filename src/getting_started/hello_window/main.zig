const std = @import("std");
const glfw = @import("glfw");
const gl = @import("gl");


fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.FunctionPointer {
    _ = p;
    return glfw.getProcAddress(proc);
}

fn framebuffer_size_callback(window: glfw.Window, width: u32, height: u32) void  {
     _ = window; gl.viewport(0, 0, @intCast(c_int, width), @intCast(c_int,height));
}

fn processInput(window: glfw.Window) void{
    if (glfw.Window.getKey(window, glfw.Key.escape) == glfw.Action.press) {
        // std.debug.print("pressed A\n",.{});
        _ = glfw.Window.setShouldClose(window, true);
    }
}

pub fn main() !void {
    if (!glfw.init(.{})) {
        
        std.log.err("GLFW initialization failed",.{});
        return;
    }
    defer glfw.terminate();

    const WindowSize = struct {
        pub const width: u32 = 800;
        pub const height: u32 = 600;
    };
    
    const window = glfw.Window.create(WindowSize.width, WindowSize.height, "mach-glfw + zig-opengl", null, null, .{
        .opengl_profile = .opengl_core_profile,
        .context_version_major = 4,
        .context_version_minor = 1,
    }) orelse {
        std.log.err("GLFW Window creation failed",.{});
        return;
    };
    defer window.destroy();

    glfw.makeContextCurrent(window);

    const proc: glfw.GLProc = undefined;
    try gl.load(proc, glGetProcAddress);

    
    glfw.Window.setFramebufferSizeCallback(window, framebuffer_size_callback);

    while (!window.shouldClose()) {
        processInput(window);
        
        window.swapBuffers();
        glfw.pollEvents();

        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT);

        
    }
}
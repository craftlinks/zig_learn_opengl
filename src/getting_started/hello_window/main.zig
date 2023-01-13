const std = @import("std");
const glfw = @import("glfw");
const gl = @import("gl");

fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.FunctionPointer {
    _ = p;
    return glfw.getProcAddress(proc);
}

fn framebuffer_size_callback(window: glfw.Window, width: u32, height: u32) void {
    _ = window;
    gl.viewport(0, 0, @intCast(c_int, width), @intCast(c_int, height));
}

fn processInput(window: glfw.Window) void {
    if (glfw.Window.getKey(window, glfw.Key.escape) == glfw.Action.press) {
        _ = glfw.Window.setShouldClose(window, true);
    }
}

pub fn main() !void {
    if (!glfw.init(.{})) {
        std.log.err("GLFW initialization failed", .{});
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
        std.log.err("GLFW Window creation failed", .{});
        return;
    };
    defer window.destroy();

    glfw.makeContextCurrent(window);

    const proc: glfw.GLProc = undefined;
    try gl.load(proc, glGetProcAddress);

    glfw.Window.setFramebufferSizeCallback(window, framebuffer_size_callback);

    // Triangle in normalized device coordinates
    const vertices = [9]f32{ -0.5, -0.5, 0.0, 0.5, -0.5, 0.0, 0.0, 0.5, 0.0 };

    // The integer handle to our future buffer
    var VBO: c_uint = undefined;

    // Create an opengl buffer and store the handle (=1)
    gl.genBuffers(1, &VBO);

    // Bind the buffer as an ARRAY_BUFFER target
    gl.bindBuffer(gl.ARRAY_BUFFER, VBO);

    // Fill our buffer with the vertex data
    gl.bufferData(gl.ARRAY_BUFFER, @sizeOf(f32) * vertices.len, &vertices, gl.STATIC_DRAW);

    // Create vertex shader
    var vertexShader: c_uint = undefined;
    vertexShader = gl.createShader(gl.VERTEX_SHADER);

    // Attach the shader source to the vertex shader object and compile it
    gl.shaderSource(vertexShader, 1, @ptrCast([*c]const [*c]const u8, &vertexShaderSource), 0);
    gl.compileShader(vertexShader);

    // Check if vertex shader was compiled successfully
    var success: c_int = undefined;
    var infoLog: [512]u8 = [_]u8{0} ** 512;

    gl.getShaderiv(vertexShader, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        gl.getShaderInfoLog(vertexShader, 512, 0, &infoLog);
        std.log.err("{s}", .{infoLog});
    }

    // Fragment shader
    // TODO...

    while (!window.shouldClose()) {
        processInput(window);

        window.swapBuffers();
        glfw.pollEvents();

        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT);
    }
}

const vertexShaderSource =
    \\ #version 330 core
    \\ layout (location = 0) in vec3 aPos;
    \\ void main()
    \\ {
    \\   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\ }
;

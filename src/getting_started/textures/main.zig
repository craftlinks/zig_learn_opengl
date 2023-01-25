const std = @import("std");
const glfw = @import("glfw");
const zstbi = @import("zstbi");
const gl = @import("gl");
const Shader = @import("Shader");
const common = @import("common");

const WindowSize = struct {
    pub const width: u32 = 800;
    pub const height: u32 = 600;
};

pub fn main() !void {

    // glfw: initialize and configure
    // ------------------------------
    if (!glfw.init(.{})) {
        std.log.err("GLFW initialization failed", .{});
        return;
    }
    defer glfw.terminate();

    // glfw window creation
    // --------------------
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
    glfw.Window.setFramebufferSizeCallback(window, framebuffer_size_callback);

    // Load all OpenGL function pointers
    // ---------------------------------------
    const proc: glfw.GLProc = undefined;
    try gl.load(proc, glGetProcAddress);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    var arena_allocator_state = std.heap.ArenaAllocator.init(allocator);
    defer arena_allocator_state.deinit();
    const arena = arena_allocator_state.allocator();

    // zstbi: loading an image.
    zstbi.init(allocator);
    defer zstbi.deinit();
    const image_path = common.pathToContent(arena, "content\\container.jpg") catch unreachable;
    var image = try zstbi.Image.init(&image_path, 0);
    defer image.deinit();
    std.debug.print("img width: {any}\nimg height: {any}\n", .{image.width, image.height});

    // Create and bind texture resource
    var texture: c_uint = undefined;

    gl.genTextures(1, &texture);
    gl.bindTexture(gl.TEXTURE_2D, texture);

    // Generate the texture
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, @intCast(c_int,image.width), @intCast(c_int,image.height), 0, gl.RGB, gl.UNSIGNED_BYTE, @ptrCast([*c] const u8, image.data));
    gl.generateMipmap(gl.TEXTURE_2D);


    // create shader program
    // var shader_program: Shader = Shader.create(arena_allocator, "shaders\\shader_ex3.vs", "shaders\\shader_ex3.fs");

    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------

    while (!window.shouldClose()) {
        processInput(window);

        gl.clearColor(0.0, 0.0, 0.0, 0.0);
        gl.clear(gl.COLOR_BUFFER_BIT);

        window.swapBuffers();
        glfw.pollEvents();
    }
}

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

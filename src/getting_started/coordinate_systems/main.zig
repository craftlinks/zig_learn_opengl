const std = @import("std");
const math = std.math;
const glfw = @import("glfw");
const zstbi = @import("zstbi");
const zm = @import("zmath");
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

    // create shader program
    var shader_program: Shader = Shader.create(arena, "content\\shader.vs", "content\\shader.fs");

    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------

    const vertices_2D = [_]f32{
        // positions      // colors        // texture coords
        0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, // top right
        0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, // bottom right
        -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, // bottom left
        -0.5, 0.5, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, // top left
    };

    _ = vertices_2D; 

    const vertices_3D = [_]f32 {
        -0.5, -0.5, -0.5,  0.0, 0.0,
         0.5, -0.5, -0.5,  1.0, 0.0,
         0.5,  0.5, -0.5,  1.0, 1.0,
         0.5,  0.5, -0.5,  1.0, 1.0,
        -0.5,  0.5, -0.5,  0.0, 1.0,
        -0.5, -0.5, -0.5,  0.0, 0.0,

        -0.5, -0.5,  0.5,  0.0, 0.0,
         0.5, -0.5,  0.5,  1.0, 0.0,
         0.5,  0.5,  0.5,  1.0, 1.0,
         0.5,  0.5,  0.5,  1.0, 1.0,
        -0.5,  0.5,  0.5,  0.0, 1.0,
        -0.5, -0.5,  0.5,  0.0, 0.0,

        -0.5,  0.5,  0.5,  1.0, 0.0,
        -0.5,  0.5, -0.5,  1.0, 1.0,
        -0.5, -0.5, -0.5,  0.0, 1.0,
        -0.5, -0.5, -0.5,  0.0, 1.0,
        -0.5, -0.5,  0.5,  0.0, 0.0,
        -0.5,  0.5,  0.5,  1.0, 0.0,

         0.5,  0.5,  0.5,  1.0, 0.0,
         0.5,  0.5, -0.5,  1.0, 1.0,
         0.5, -0.5, -0.5,  0.0, 1.0,
         0.5, -0.5, -0.5,  0.0, 1.0,
         0.5, -0.5,  0.5,  0.0, 0.0,
         0.5,  0.5,  0.5,  1.0, 0.0,

        -0.5, -0.5, -0.5,  0.0, 1.0,
         0.5, -0.5, -0.5,  1.0, 1.0,
         0.5, -0.5,  0.5,  1.0, 0.0,
         0.5, -0.5,  0.5,  1.0, 0.0,
        -0.5, -0.5,  0.5,  0.0, 0.0,
        -0.5, -0.5, -0.5,  0.0, 1.0,

        -0.5,  0.5, -0.5,  0.0, 1.0,
         0.5,  0.5, -0.5,  1.0, 1.0,
         0.5,  0.5,  0.5,  1.0, 0.0,
         0.5,  0.5,  0.5,  1.0, 0.0,
        -0.5,  0.5,  0.5,  0.0, 0.0,
        -0.5,  0.5, -0.5,  0.0, 1.0
    };

    const cube_positions = [_][3]f32{
        .{ 0.0,  0.0,  0.0}, 
        .{ 2.0,  5.0, -15.0}, 
        .{-1.5, -2.2, -2.5},  
        .{-3.8, -2.0, -12.3},  
        .{ 2.4, -0.4, -3.5},  
        .{-1.7,  3.0, -7.5},  
        .{ 1.3, -2.0, -2.5},  
        .{ 1.5,  2.0, -2.5}, 
        .{ 1.5,  0.2, -1.5}, 
        .{-1.3,  1.0, -1.5} 
    };

    var VBO: c_uint = undefined;
    var VAO: c_uint = undefined;

    gl.genVertexArrays(1, &VAO);
    defer gl.deleteVertexArrays(1, &VAO);

    gl.genBuffers(1, &VBO);
    defer gl.deleteBuffers(1, &VBO);

    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    gl.bindVertexArray(VAO);
    gl.bindBuffer(gl.ARRAY_BUFFER, VBO);
    // Fill our buffer with the vertex data
    gl.bufferData(gl.ARRAY_BUFFER, @sizeOf(f32) * vertices_3D.len, &vertices_3D, gl.STATIC_DRAW);

    // vertex
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 5 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);

    // texture coords
    const tex_offset: [*c]c_uint = (3 * @sizeOf(f32));
    gl.vertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 5 * @sizeOf(f32), tex_offset);
    gl.enableVertexAttribArray(1);

    // zstbi: loading an image.
    zstbi.init(allocator);
    defer zstbi.deinit();

    const image1_path = common.pathToContent(arena, "content\\container.jpg") catch unreachable;
    var image1 = try zstbi.Image.init(&image1_path, 0);
    defer image1.deinit();
    std.debug.print("\nImage 1 info:\n\n  img width: {any}\n  img height: {any}\n  nchannels: {any}\n", .{ image1.width, image1.height, image1.num_components });

    zstbi.setFlipVerticallyOnLoad(true);
    const image2_path = common.pathToContent(arena, "content\\awesomeface.png") catch unreachable;
    var image2 = try zstbi.Image.init(&image2_path, 0);
    defer image2.deinit();
    std.debug.print("\nImage 2 info:\n\n  img width: {any}\n  img height: {any}\n  nchannels: {any}\n", .{ image2.width, image2.height, image2.num_components });

    // Create and bind texture1 resource
    var texture1: c_uint = undefined;

    gl.genTextures(1, &texture1);
    gl.activeTexture(gl.TEXTURE0); // activate the texture unit first before binding texture
    gl.bindTexture(gl.TEXTURE_2D, texture1);

    // set the texture1 wrapping parameters
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT); // set texture wrapping to GL_REPEAT (default wrapping method)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    // set texture1 filtering parameters
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    // Generate the texture1
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, @intCast(c_int, image1.width), @intCast(c_int, image1.height), 0, gl.RGB, gl.UNSIGNED_BYTE, @ptrCast([*c]const u8, image1.data));
    gl.generateMipmap(gl.TEXTURE_2D);

    // Texture2
    var texture2: c_uint = undefined;

    gl.genTextures(1, &texture2);
    gl.activeTexture(gl.TEXTURE1); // activate the texture unit first before binding texture
    gl.bindTexture(gl.TEXTURE_2D, texture2);

    // set the texture1 wrapping parameters
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT); // set texture wrapping to GL_REPEAT (default wrapping method)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    // set texture1 filtering parameters
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    // Generate the texture1
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, @intCast(c_int, image2.width), @intCast(c_int, image2.height), 0, gl.RGBA, gl.UNSIGNED_BYTE, @ptrCast([*c]const u8, image2.data));
    gl.generateMipmap(gl.TEXTURE_2D);

    // Enable OpenGL depth testing (use Z-buffer information)
    gl.enable(gl.DEPTH_TEST);

    shader_program.use();
    shader_program.setInt("texture1", 0);
    shader_program.setInt("texture2", 1);

    // Create the transformation matrices:
    // Degree to radians conversion factor
    const rad_conversion = math.pi / 180.0;
    
    // Buffer to store Model matrix
    var model: [16]f32 = undefined;
    
    // View matrix
    const viewM = zm.translation(0.0, 0.0, -5.0);
    var view: [16]f32 = undefined;
    zm.storeMat(&view, viewM);
    
    // Buffer to store Orojection matrix (in render loop)
    var proj: [16]f32 = undefined;

    while (!window.shouldClose()) {
        processInput(window);

        gl.clearColor(0.0, 0.0, 0.0, 0.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, texture1);
        gl.activeTexture(gl.TEXTURE1);
        gl.bindTexture(gl.TEXTURE_2D, texture2);
        gl.bindVertexArray(VAO);

        // Projection matrix 
        var projM = x:  {
            var window_size = window.getSize();
            var fov = @intToFloat(f32,window_size.width) / @intToFloat(f32,window_size.height);
            var projM = zm.perspectiveFovRhGl(45.0 * rad_conversion, fov, 0.1, 100.0);
            break :x projM;
        };
        zm.storeMat(&proj, projM);

        const viewLoc = gl.getUniformLocation(shader_program.ID, "view");
        gl.uniformMatrix4fv(viewLoc, 1, gl.FALSE, &view);
        const projLoc = gl.getUniformLocation(shader_program.ID, "projection");
        gl.uniformMatrix4fv(projLoc, 1, gl.FALSE, &proj);


        for (cube_positions) | cube_position, i | {
            const cube_trans = zm.translation(cube_position[0], cube_position[1], cube_position[2]);
            const cube_rot = zm.matFromAxisAngle(zm.f32x4(1.0, 0.3, 0.5, 1.0), @floatCast(f32,glfw.getTime()) * 55.0 * (((@mod(@intToFloat(f32,i + 1),2.0))*2.0)-1.0) * rad_conversion);
            const modelM = zm.mul(cube_rot, cube_trans);
            zm.storeMat(&model, modelM);
            const modelLoc = gl.getUniformLocation(shader_program.ID, "model");
            gl.uniformMatrix4fv(modelLoc, 1, gl.FALSE, &model);

            gl.drawArrays(gl.TRIANGLES, 0, 36);

        } 

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

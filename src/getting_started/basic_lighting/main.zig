const std = @import("std");
const math = std.math;
const glfw = @import("glfw");
const zstbi = @import("zstbi");
const zm = @import("zmath");
const gl = @import("gl");
const Shader = @import("Shader");
const Camera = @import("Camera");
const common = @import("common");

// Camera
const camera_pos = zm.loadArr3(.{ 0.0, 0.0, 5.0 });
var lastX: f64 = 0.0;
var lastY: f64 = 0.0;
var first_mouse = true;
var camera = Camera.camera(camera_pos); 

// Timing
var delta_time: f32 = 0.0;
var last_frame: f32 = 0.0;

// lighting
const light_position = [_]f32{ 5.0, 1.0, -2.0 };

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
    // Capture mouse, disable cursor visibility
    glfw.Window.setInputMode(window, glfw.Window.InputMode.cursor, glfw.Window.InputModeCursor.disabled);
    glfw.Window.setCursorPosCallback(window, mouseCallback);
    glfw.Window.setScrollCallback(window, mouseScrollCallback); 

    // Load all OpenGL function pointers
    // ---------------------------------------
    const proc: glfw.GLProc = undefined;
    try gl.load(proc, glGetProcAddress);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    var arena_allocator_state = std.heap.ArenaAllocator.init(allocator);
    defer arena_allocator_state.deinit();
    const arena = arena_allocator_state.allocator();

    // Enable OpenGL depth testing (use Z-buffer information)
    gl.enable(gl.DEPTH_TEST);

    // create shader program
    var shader_program: Shader = Shader.create(arena, "content\\shader.vs", "content\\shader.fs");
    var light_shader: Shader = Shader.create(arena, "content\\light_shader.vs", "content\\light_shader.fs");

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

    const vertices_3D = [_]f32{ 
        -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,
         0.5, -0.5, -0.5,  0.0,  0.0, -1.0, 
         0.5,  0.5, -0.5,  0.0,  0.0, -1.0, 
         0.5,  0.5, -0.5,  0.0,  0.0, -1.0, 
        -0.5,  0.5, -0.5,  0.0,  0.0, -1.0, 
        -0.5, -0.5, -0.5,  0.0,  0.0, -1.0, 

        -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
         0.5, -0.5,  0.5,  0.0,  0.0, 1.0,
         0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
         0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
        -0.5,  0.5,  0.5,  0.0,  0.0, 1.0,
        -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,

        -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,
        -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,
        -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
        -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,
        -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,
        -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,

        0.5,  0.5,  0.5,  1.0,  0.0,  0.0,
        0.5,  0.5, -0.5,  1.0,  0.0,  0.0,
        0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
        0.5, -0.5, -0.5,  1.0,  0.0,  0.0,
        0.5, -0.5,  0.5,  1.0,  0.0,  0.0,
        0.5,  0.5,  0.5,  1.0,  0.0,  0.0,

        -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
         0.5, -0.5, -0.5,  0.0, -1.0,  0.0,
         0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
         0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
        -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,
        -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,

        -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
         0.5,  0.5, -0.5,  0.0,  1.0,  0.0,
         0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
         0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
        -0.5,  0.5,  0.5,  0.0,  1.0,  0.0,
        -0.5,  0.5, -0.5,  0.0,  1.0,  0.0
     };

    const cube_positions = [_][3]f32{ .{ 0.0, 0.0, 0.0 }, .{ 2.0, 5.0, -15.0 }, .{ -1.5, -2.2, -2.5 }, .{ -3.8, -2.0, -12.3 }, .{ 2.4, -0.4, -3.5 }, .{ -1.7, 3.0, -7.5 }, .{ 1.3, -2.0, -2.5 }, .{ 1.5, 2.0, -2.5 }, .{ 1.5, 0.2, -1.5 }, .{ -1.3, 1.0, -1.5 } };
    
    var VBO: c_uint = undefined;
    var VAO: c_uint = undefined;
    var light_VAO: c_uint = undefined;

    gl.genVertexArrays(1, &VAO);
    defer gl.deleteVertexArrays(1, &VAO);

    gl.genVertexArrays(1, &light_VAO);
    defer gl.deleteVertexArrays(1, &light_VAO);

    gl.genBuffers(1, &VBO);
    defer gl.deleteBuffers(1, &VBO);

    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    gl.bindVertexArray(VAO);
    gl.bindBuffer(gl.ARRAY_BUFFER, VBO);
    // Fill our buffer with the vertex data
    gl.bufferData(gl.ARRAY_BUFFER, @sizeOf(f32) * vertices_3D.len, &vertices_3D, gl.STATIC_DRAW);

    // vertex
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);

    // normal attribute
    const normal_offset: [*c]c_uint = (3 * @sizeOf(f32));
    gl.vertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), normal_offset);
    gl.enableVertexAttribArray(1);
    
    // Configure light VAO
    gl.bindVertexArray(light_VAO);
    gl.bindBuffer(gl.ARRAY_BUFFER, VBO);
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);

    // Buffer to store Model matrix
    var model: [16]f32 = undefined;

    // View matrix
    var view: [16]f32 = undefined;

    // Buffer to store Orojection matrix (in render loop)
    var proj: [16]f32 = undefined;

    var light_model: [16]f32 = undefined;

    while (!window.shouldClose()) {
        
        // Time per frame
        const current_frame = @floatCast(f32, glfw.getTime());
        delta_time = current_frame - last_frame;
        last_frame = current_frame;

        processInput(window);

        gl.clearColor(0.0, 0.0, 0.0, 0.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        shader_program.use();
        shader_program.setVec3f("objectColor", .{1.0, 0.5, 0.31});
        shader_program.setVec3f("lightColor", .{1.0, 1.0, 1.0});
        shader_program.setVec3f("lightPos", light_position); 
        
        // Projection matrix
        const projM = x: {
            const window_size = window.getSize();
            const aspect = @intToFloat(f32, window_size.width) / @intToFloat(f32, window_size.height);
            var projM = zm.perspectiveFovRhGl(camera.zoom * common.RAD_CONVERSION,  aspect, 0.1, 100.0);
            break :x projM;
        };
        zm.storeMat(&proj, projM);
        shader_program.setMat4f("projection", proj);

        // View matrix: Camera
        const viewM = camera.getViewMatrix();
        zm.storeMat(&view, viewM);
        shader_program.setMat4f("view", view);


        for (cube_positions) |cube_position, i| {
            // Model matrix
            const cube_trans = zm.translation(cube_position[0], cube_position[1], cube_position[2]);
            const rotation_direction = (((@mod(@intToFloat(f32, i + 1), 2.0)) * 2.0) - 1.0);
            const cube_rot = zm.matFromAxisAngle(zm.f32x4(1.0, 0.3, 0.5, 1.0), @floatCast(f32, glfw.getTime()) * 55.0 * rotation_direction * common.RAD_CONVERSION);
            const modelM = zm.mul(cube_rot, cube_trans);
            zm.storeMat(&model, modelM);
            shader_program.setMat4f("model", model);

            gl.bindVertexArray(VAO); 
            gl.drawArrays(gl.TRIANGLES, 0, 36);
        }

        const light_trans = zm.translation(light_position[0], light_position[1], light_position[2]);
        const light_modelM = zm.mul(light_trans,zm.scaling(0.2, 0.2, 0.2));
        zm.storeMat(&light_model, light_modelM);

        light_shader.use();
        light_shader.setMat4f("projection", proj);
        light_shader.setMat4f("view", view);
        light_shader.setMat4f("model", light_model); 
        gl.bindVertexArray(light_VAO);
        gl.drawArrays(gl.TRIANGLES, 0, 36);

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

    if (glfw.Window.getKey(window, glfw.Key.w) == glfw.Action.press) {
        camera.processKeyboard(Camera.CameraMovement.FORWARD, delta_time);
    }
    if (glfw.Window.getKey(window, glfw.Key.s) == glfw.Action.press) {
        camera.processKeyboard(Camera.CameraMovement.BACKWARD, delta_time);
    }
    if (glfw.Window.getKey(window, glfw.Key.a) == glfw.Action.press) {
        camera.processKeyboard(Camera.CameraMovement.LEFT, delta_time);
    }
    if (glfw.Window.getKey(window, glfw.Key.d) == glfw.Action.press) {
        camera.processKeyboard(Camera.CameraMovement.RIGHT, delta_time);
    }
}

fn mouseCallback(window: glfw.Window, xpos: f64, ypos: f64) void {
    _ = window;
    
    if (first_mouse)
    {
        lastX = xpos;
        lastY = ypos;
        first_mouse = false;
    }

    var xoffset = xpos - lastX;
    var yoffset = ypos - lastY;

    lastX = xpos;
    lastY = ypos;

    camera.processMouseMovement(xoffset, yoffset, true);
}

fn mouseScrollCallback(window: glfw.Window, xoffset: f64, yoffset: f64) void {
    _ = window;
    _ = xoffset;
    
    camera.processMouseScroll(yoffset);
}

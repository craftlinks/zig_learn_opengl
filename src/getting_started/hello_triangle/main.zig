const std = @import("std");
const glfw = @import("glfw");
const gl = @import("gl");

const vertexShaderSource =
    \\ #version 410 core
    \\ layout (location = 0) in vec3 aPos;
    \\ void main()
    \\ {
    \\   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\ }
;

const fragmentShaderSource_1 =
    \\ #version 410 core
    \\ out vec4 FragColor;
    \\ void main() {
    \\  FragColor = vec4(1.0, 0.5, 0.2, 1.0);   
    \\ }
;

const fragmentShaderSource_2 =
    \\ #version 410 core
    \\ out vec4 FragColor;
    \\ void main() {
    \\  FragColor = vec4(1.0, 1.0, 0.2, 1.0);   
    \\ }
;

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

    // Create vertex shader
    var vertexShader: c_uint = undefined;
    vertexShader = gl.createShader(gl.VERTEX_SHADER);
    defer gl.deleteShader(vertexShader);

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
    var fragmentShader_1: c_uint = undefined;
    fragmentShader_1 = gl.createShader(gl.FRAGMENT_SHADER);
    defer gl.deleteShader(fragmentShader_1);

    gl.shaderSource(fragmentShader_1, 1, @ptrCast([*c]const [*c]const u8, &fragmentShaderSource_1), 0);
    gl.compileShader(fragmentShader_1);

    gl.getShaderiv(fragmentShader_1, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        gl.getShaderInfoLog(fragmentShader_1, 512, 0, &infoLog);
        std.log.err("{s}", .{infoLog});
    }

    // Fragment shader
    var fragmentShader_2: c_uint = undefined;
    fragmentShader_2 = gl.createShader(gl.FRAGMENT_SHADER);
    defer gl.deleteShader(fragmentShader_2);

    gl.shaderSource(fragmentShader_2, 1, @ptrCast([*c]const [*c]const u8, &fragmentShaderSource_2), 0);
    gl.compileShader(fragmentShader_2);

    gl.getShaderiv(fragmentShader_2, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        gl.getShaderInfoLog(fragmentShader_2, 512, 0, &infoLog);
        std.log.err("{s}", .{infoLog});
    }

    // create a program object
    var shaderProgram_1: c_uint = undefined;
    shaderProgram_1 = gl.createProgram();
    defer gl.deleteProgram(shaderProgram_1);

        // create a program object
    var shaderProgram_2: c_uint = undefined;
    shaderProgram_2 = gl.createProgram();
    defer gl.deleteProgram(shaderProgram_2);

    // attach compiled shader objects to the program object and link
    gl.attachShader(shaderProgram_1, vertexShader);
    gl.attachShader(shaderProgram_1, fragmentShader_1);
    gl.linkProgram(shaderProgram_1);

    // attach compiled shader objects to the program object and link
    gl.attachShader(shaderProgram_2, vertexShader);
    gl.attachShader(shaderProgram_2, fragmentShader_2);
    gl.linkProgram(shaderProgram_2);

    // check if shader linking was successfull
    gl.getProgramiv(shaderProgram_1, gl.LINK_STATUS, &success);
    if (success == 0) {
        gl.getProgramInfoLog(shaderProgram_1, 512, 0, &infoLog);
        std.log.err("{s}", .{infoLog});
    }

    // check if shader linking was successfull
    gl.getProgramiv(shaderProgram_2, gl.LINK_STATUS, &success);
    if (success == 0) {
        gl.getProgramInfoLog(shaderProgram_2, 512, 0, &infoLog);
        std.log.err("{s}", .{infoLog});
    }

    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------
    const vertices_1 = [9]f32 { 
        // Triangle 1
        -1.0, -0.5, 0.0, 0.0, -0.5, 0.0, -0.5, 0.5, 0.0,
    };
    
    const vertices_2 = [9]f32 {
        // Triangle 2 
         0.0, -0.5, 0.0, 1.0, -0.5, 0.0, 0.5, 0.5, 0.0
    };   

    var VBOs: [2]c_uint = undefined;
    var VAOs: [2]c_uint = undefined;

    gl.genVertexArrays(2, &VAOs);
    defer gl.deleteVertexArrays(2, &VAOs);

    gl.genBuffers(2, &VBOs);
    defer gl.deleteBuffers(1, &VBOs);

    // bind the Vertex Array Object for trangle 1 first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    gl.bindVertexArray(VAOs[0]);
    gl.bindBuffer(gl.ARRAY_BUFFER, VBOs[0]);
    // Fill our buffer with the vertex data for traingle 1
    gl.bufferData(gl.ARRAY_BUFFER, @sizeOf(f32) * vertices_1.len, &vertices_1, gl.STATIC_DRAW);
    // Specify and link our vertext attribute description
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);
    
    // bind the Vertex Array Object for triangle 2 first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    gl.bindVertexArray(VAOs[1]);
    gl.bindBuffer(gl.ARRAY_BUFFER, VBOs[1]);
    // Fill our buffer with the vertex data
    gl.bufferData(gl.ARRAY_BUFFER, @sizeOf(f32) * vertices_2.len, &vertices_2, gl.STATIC_DRAW);
    // Specify and link our vertext attribute description
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);

    // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
    gl.bindBuffer(gl.ARRAY_BUFFER, 0);

    // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
    // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    gl.bindVertexArray(0);

    while (!window.shouldClose()) {
        processInput(window);

        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT);
        
        // Activate shaderProgram
        gl.useProgram(shaderProgram_1);
        // Draw triangle 1
        gl.bindVertexArray(VAOs[0]); 
        gl.drawArrays(gl.TRIANGLES, 0, 3);
        
        // Activate shaderProgram
        gl.useProgram(shaderProgram_2);
        // Draw triangle 2
        gl.bindVertexArray(VAOs[1]);
        gl.drawArrays(gl.TRIANGLES, 0, 3);

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

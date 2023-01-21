const std = @import("std");
const gl = @import("gl");
const Shader = @This();

// The program ID
ID: c_uint,

const fragmentShaderSource =
    \\ #version 330 core
    \\ out vec4 FragColor;
    \\ void main() {
    \\  FragColor = vec4(1.0, 0.6, 0.2, 1.0);
    \\ }
;

pub fn create(vertex_path: []const u8, fragment_path: []const u8) Shader {

    // open files and extract the content as byte stream
    const vs_file = std.fs.openFileAbsolute(vertex_path, .{}) catch unreachable;
    defer vs_file.close();
    
    // also, we should work with a content dir that copies the shader source to the exe install path so that we can call fs.cwd().openfilewith relative path instead of full path
    var vs_code: [10 * 1024]u8 = [_]u8{0} ** (10 * 1024);
    _ = vs_file.readAll(&vs_code) catch unreachable;
    //defer allocator.free(vs_code);

    const fs_file = std.fs.openFileAbsolute(fragment_path, .{}) catch unreachable;
    defer fs_file.close();
    var fs_code: [10 * 1024]u8 = [_]u8{0} ** (10 * 1024); 
    _ = fs_file.readAll(&fs_code) catch unreachable;


    var success: c_int = undefined;
    var infoLog: [1024]u8 = [_]u8{0} ** 1024;

    // Create vertex shader
    var vertexShader = gl.createShader(gl.VERTEX_SHADER);
    defer gl.deleteShader(vertexShader);

    var vs_code_c = @ptrCast([*c]const [*c]const u8, &&vs_code);
    std.debug.print("VERTEX SHADER: \n{s}\n", .{ vs_code_c.*});

    var fs_code_c = @ptrCast([*c]const [*c]const u8, &fragmentShaderSource);
    std.debug.print("FRAGMENT SHADER: \n{s}\n", .{ fs_code_c.*});


    // Attach the shader source to the vertex shader object and compile it
    gl.shaderSource(vertexShader, 1,vs_code_c, null);
    gl.compileShader(vertexShader);

    gl.getShaderiv(vertexShader, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        gl.getShaderInfoLog(vertexShader, 1024, 0, &infoLog);
        std.log.err("{s}", .{infoLog});
    }

    // Fragment shader
    var fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
    defer gl.deleteShader(fragmentShader);

    gl.shaderSource(fragmentShader, 1, fs_code_c, null);
    gl.compileShader(fragmentShader);

    gl.getShaderiv(fragmentShader, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        gl.getShaderInfoLog(fragmentShader, 1024, 0, &infoLog);
        std.log.err("{s}", .{infoLog});
    }

    // create a program object
    const ID = gl.createProgram();
    // std.debug.print("{any}", .{ID});
    defer gl.deleteProgram(ID);

    // attach compiled shader objects to the program object and link
    gl.attachShader(ID, vertexShader);
    gl.attachShader(ID, fragmentShader);
    gl.linkProgram(ID);

    // check if shader linking was successfull
    gl.getProgramiv(ID, gl.LINK_STATUS, &success);
    if (success == 0) {
        gl.getProgramInfoLog(ID, 512, 0, &infoLog);
        std.log.err("{s}", .{infoLog});
    }

    return Shader{.ID = ID};
}

pub fn use(self: Shader) c_uint {
    // std.debug.print("{any}", .{self.ID});
    gl.useProgram(self.ID);
    return self.ID;
}

pub fn setBool(self: Shader, name: []const u8, value: bool) void {
    gl.uniform1i(gl.getUniformLocation(self.ID, name), @boolToInt(value));
}

pub fn setInt(self: Shader, name: []const u8, value: u32) void {
    gl.uniform1i(gl.getUniformLocation(self.ID, name), @intCast(c_int,value));
}

pub fn setFloat(self: Shader, name: []const u8, value: f32) void {
    gl.uniform1f(gl.getUniformLocation(self.ID, name), value);
}
const std = @import("std");
const gl = @import("gl");
const Shader = @This();

// The program ID
ID: c_uint,

pub fn create(vertex_path:[]const u8, fragment_path:[]const u8) Shader {

    // Create vertex shader
    var vertexShader: c_uint = undefined;
    vertexShader = gl.createShader(gl.VERTEX_SHADER);
    defer gl.deleteShader(vertexShader);

    const vs_file = std.fs.openFileAbsolute(vertex_path, .{}) catch unreachable;
    var vs_code: [10 * 1024]u8 = [_]u8{0} ** (10 * 1024);
    _ = vs_file.readAll(&vs_code) catch unreachable;

    const fs_file = std.fs.openFileAbsolute(fragment_path, .{}) catch unreachable;
    var fs_code: [10 * 1024]u8 = [_]u8{0} ** (10 * 1024);
    _ = fs_file.readAll(&fs_code) catch unreachable;

    // Attach the shader source to the vertex shader object and compile it
    gl.shaderSource(vertexShader, 1, @ptrCast([*c]const [*c]const u8, &&vs_code), 0);
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
    var fragmentShader: c_uint = undefined;
    fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
    defer gl.deleteShader(fragmentShader);

    gl.shaderSource(fragmentShader, 1, @ptrCast([*c]const [*c]const u8, &&fs_code), 0);
    gl.compileShader(fragmentShader);

    gl.getShaderiv(fragmentShader, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        gl.getShaderInfoLog(fragmentShader, 512, 0, &infoLog);
        std.log.err("{s}", .{infoLog});
    }

    // create a program object
    const shaderProgram = gl.createProgram();
    std.debug.print("{any}", .{shaderProgram});

    // attach compiled shader objects to the program object and link
    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);
    gl.linkProgram(shaderProgram);

    // check if shader linking was successfull
    gl.getProgramiv(shaderProgram, gl.LINK_STATUS, &success);
    if (success == 0) {
        gl.getProgramInfoLog(shaderProgram, 512, 0, &infoLog);
        std.log.err("{s}", .{infoLog});
    }
    return Shader{.ID = shaderProgram};
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
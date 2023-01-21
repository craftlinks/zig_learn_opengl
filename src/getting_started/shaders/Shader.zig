const std = @import("std");
const gl = @import("gl");
const Shader = @This();

// The program ID
ID: c_uint,

pub fn create(allocator: std.mem.Allocator,vertex_path: []const u8, fragment_path: []const u8) Shader {
    
    // open files and extract the content as byte stream
    const vs_file = std.fs.openFileAbsolute(vertex_path, .{}) catch unreachable;
    defer vs_file.close();
    
    // also, we should work with a content dir that copies the shader source to the exe install path so that we can call fs.cwd().openfilewith relative path instead of full path
    
    const vs_code = vs_file.readToEndAlloc(allocator, 10 * 1024) catch unreachable;
    defer allocator.free(vs_code);

    const fs_file = std.fs.openFileAbsolute(fragment_path, .{}) catch unreachable;
    // defer fs_file.close();
    const fs_code = fs_file.readToEndAlloc(allocator, 10 * 1024) catch unreachable;
    // defer allocator.free(fs_code);

    var success: c_int = undefined;
    var infoLog: [1024]u8 = [_]u8{0} ** 1024;

    // Create vertex shader
    var vertexShader = gl.createShader(gl.VERTEX_SHADER);
    defer gl.deleteShader(vertexShader);

    // Attach the shader source to the vertex shader object and compile it
    gl.shaderSource(vertexShader, 1, @ptrCast([*c]const [*c]const u8, &&vs_code), null);
    gl.compileShader(vertexShader);

    gl.getShaderiv(vertexShader, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        gl.getShaderInfoLog(vertexShader, 1024, 0, &infoLog);
        std.log.err("{s}", .{infoLog});
    }

    // Fragment shader
    var fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
    defer gl.deleteShader(fragmentShader);

    gl.shaderSource(fragmentShader, 1, @ptrCast([*c]const [*c]const u8, &&fs_code), null);
    gl.compileShader(fragmentShader);

    gl.getShaderiv(fragmentShader, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        gl.getShaderInfoLog(fragmentShader, 1024, 0, &infoLog);
        std.log.err("{s}", .{infoLog});
    }

    // create a program object
    const ID = gl.createProgram();
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

pub fn use(self: Shader) void {
    gl.useProgram(self.ID);
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
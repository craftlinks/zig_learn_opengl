const gl = @import("gl");

// The program ID
pub const ID = c_uint;

const Shader = @This();

pub const haha = "This is a test";

pub fn create(vertex_path: []const u8, fragment_path: []const u8) *Shader {
    _ = vertex_path;
    _ = fragment_path;

    // TODO READING FROM FILE
}

pub fn use() void {
    gl.useProgram(ID);
}

pub fn setBool(name: []const u8, value: bool) void {
    gl.uniform1i(gl.getUniformLocation(ID, name), @boolToInt(value));
}

pub fn setInt(name: []const u8, value: u32) void {
    gl.uniform1i(gl.getUniformLocation(ID, name), @intCast(c_int,value));
}

pub fn setFloat(name: []const u8, value: f32) void {
    gl.uniform1f(gl.getUniformLocation(ID, name), value);
}
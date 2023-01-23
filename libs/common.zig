const std = @import("std");

pub fn pathToContent(arena: std.mem.Allocator, resource_relative_path: [:0]const u8) ![4096:0] u8 {
    const exe_path = std.fs.selfExeDirPathAlloc(arena) catch unreachable;
    const content_path = std.fs.path.join(arena, &.{exe_path, resource_relative_path}) catch unreachable;
    var content_path_zero : [4096:0]u8 = undefined;
    if (content_path.len >= 4096) return error.NameTooLong;
    std.mem.copy(u8, &content_path_zero, content_path);
    content_path_zero[content_path.len] = 0; 
    return content_path_zero; 
}
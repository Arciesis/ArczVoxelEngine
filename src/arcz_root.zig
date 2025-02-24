const std = @import("std");
const vk = @import("vulkan");
const glfw = @import("glfw");
pub const vector = @import("maths/mod.zig");

test "refAllDecls" {
    std.testing.refAllDeclsRecursive(@This());
}

const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "ArczEngine",
        .root_source_file = b.path("src/arcz_root.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "ArczEngine",
        .root_source_file = b.path("src/arcz.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());
    const vkzig_dep = b.dependency("vulkan_zig", .{
        .registry = @as([]const u8, b.pathFromRoot("../../../bin/vulkan_sdk/source/Vulkan-Headers/registry/vk.xml")),
    });
    const vkzig_bindings = vkzig_dep.module("vulkan-zig");
    exe.root_module.addImport("vulkan", vkzig_bindings);

    exe.linkSystemLibrary("glfw");
    const glfw_mod = b.addModule("glwf", .{
        .root_source_file = b.path("bindings/glfw.zig"),
    });
    exe.root_module.addImport("glfw", glfw_mod);

    // const glfw_dep = b.dependency("glfw", .{ .registry = @as([]const u8, b.pathFromRoot("bindings/glfw.zig"))});
    // exe.root_module.addImport("glfw", .{});

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/arcz_root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/arcz.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}

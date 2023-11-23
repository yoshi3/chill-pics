const std = @import("std");

// Number of pages reserved for heap memory.
// This must match the number of pages used on JavaScript.
const number_of_pages = 100;
pub fn build(b: *std.Build) void {
    const lib = b.addSharedLibrary(.{
        .name = "removeNoise",
        .root_source_file = .{ .path = "zig-src/removeNoise.zig" },
        .target = .{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
            .abi = .musl,
        },
        .optimize = .Debug,
    });

    // <https://github.com/ziglang/zig/issues/8633>
    lib.global_base = 6560;
    lib.rdynamic = true;
    lib.import_memory = true;
    lib.stack_size = std.wasm.page_size;

    lib.initial_memory = std.wasm.page_size * number_of_pages;
    lib.max_memory = std.wasm.page_size * number_of_pages * 2;

    b.installArtifact(
        lib,
    );
}

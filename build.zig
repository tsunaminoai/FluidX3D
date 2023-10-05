const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "Fluid3DX",
        .target = target,
        .optimize = optimize,
    });
    if (builtin.os.tag == .macos) {
        exe.linkFramework("OpenCL");
    } else {
        exe.linkSystemLibrary("OpenCL");
    }
    exe.addIncludePath(.{ .path = "src/" });
    exe.addIncludePath(.{ .path = "src/OpenCL/include" });
    exe.linkLibCpp();

    exe.installHeader("src/OpenCL/include/CL/cl.hpp", "CL/cl.hpp");
    for (FluidX3D_headers) |h| exe.installHeader(h, h);
    exe.addCSourceFiles(&FluidX3D_sources, &[_][]const u8{
        "-DBUILDING_FluidX3D",
    });

    b.installArtifact(exe);
}

const FluidX3D_sources = [_][]const u8{
    "src/kernel.cpp",
    "src/lodepng.cpp",
    "src/setup.cpp",
    "src/graphics.cpp",
    "src/shapes.cpp",
    "src/info.cpp",
    "src/lbm.cpp",
    "src/main.cpp",
};

const FluidX3D_headers = [_][]const u8{
    "src/shapes.hpp",
    "src/defines.hpp",
    "src/info.hpp",
    "src/lbm.hpp",
    "src/graphics.hpp",
    "src/lodepng.hpp",
    "src/setup.hpp",
    "src/utilities.hpp",
    "src/units.hpp",
    "src/opencl.hpp",
    "src/kernel.hpp",
};

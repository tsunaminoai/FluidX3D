const std = @import("std");
const builtin = @import("builtin");

const Program = struct {
    name: []const u8,
    path: []const u8,
    desc: []const u8,
};
const Option = struct {
    name: []const u8,
    value: ?[]const u8,
    description: ?[]const u8,
};

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "Fluid3DX",
        .target = target,
        .optimize = optimize,
    });
    if (builtin.os.tag == .windows) {
        std.debug.warn("Windows detected, adding default CUDA SDK x64 lib search path. Change this in build.zig if needed...");
        exe.addLibPath("C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v10.1/lib/x64");
    }
    if (builtin.os.tag == .macos) {
        exe.linkFramework("OpenCL");
    } else {
        exe.linkSystemLibrary("OpenCL");
        exe.linkSystemLibrary("X11");
    }
    exe.addIncludePath(.{ .path = "src/" });
    exe.addIncludePath(.{ .path = "src/OpenCL/include" });
    exe.addIncludePath(.{ .path = "src/X11/include/" });
    exe.linkLibCpp();

    exe.installHeader("src/OpenCL/include/CL/cl.hpp", "CL/cl.hpp");
    for (FluidX3D_headers) |h| exe.installHeader(h, h);
    exe.addCSourceFiles(&FluidX3D_sources, &[_][]const u8{
        "-DBUILDING_FluidX3D",
    });

    b.installArtifact(exe);
    // zig fmt: off
    const options = [_]Option{
      // .{ .name = "D2Q9", .value = null, .description = "choose D2Q9 velocity set for 2D; allocates 53 (FP32) or 35 (FP16) Bytes/cell"},
      // .{ .name = "D3Q15", .value = null, .description = "choose D3Q15 velocity set for 3D; allocates 77 (FP32) or 47 (FP16) Bytes/cell",},
      .{ .name = "D3Q19", .value = null, .description = "choose D3Q19 velocity set for 3D; allocates 93 (FP32) or 55 (FP16) Bytes/cell; (default)",},
      // .{ .name = "D3Q27", .value = null, .description = "choose D3Q27 velocity set for 3D; allocates 125 (FP32) or 71 (FP16) Bytes/cell",},
      .{ .name = "SRT", .value = null, .description = "choose single-relaxation-time LBM collision operator; (default)",},
      // .{ .name = "TRT", .value = null, .description = "choose two-relaxation-time LBM collision operator",},
      // .{ .name = "FP16S", .value = null, .description = "compress LBM DDFs to range-shifted IEEE-754 FP16; number conversion is done in hardware; all arithmetic is still done in FP32",},
      // .{ .name = "FP16C", .value = null, .description = "compress LBM DDFs to more accurate custom FP16C format; number conversion is emulated in software; all arithmetic is still done in FP32",},
      // .{ .name = "BENCHMARK", .value = null, .description = "disable all extensions and setups and run benchmark setup instead",},
      // .{ .name = "VOLUME_FORCE", .value = null, .description = "enables global force per volume in one direction (equivalent to a pressure gradient); specified in the LBM class constructor; the force can be changed on-the-fly between time steps at no performance cost",},
      // .{ .name = "FORCE_FIELD", .value = null, .description = "enables computing the forces on solid boundaries with lbm.calculate_force_on_boundaries(); and enables setting the force for each lattice point independently (enable VOLUME_FORCE too); allocates an extra 12 Bytes/cell",},
      // .{ .name = "EQUILIBRIUM_BOUNDARIES", .value = null, .description = "enables fixing the velocity/density by marking cells with TYPE_E; can be used for inflow/outflow; does not reflect shock waves",},
      // .{ .name = "MOVING_BOUNDARIES", .value = null, .description = "enables moving solids: set solid cells to TYPE_S and set their velocity u unequal to zero",},
      // .{ .name = "SURFACE", .value = null, .description = "enables free surface LBM: mark fluid cells with TYPE_F; at initialization the TYPE_I interface and TYPE_G gas domains will automatically be completed; allocates an extra 12 Bytes/cell",},
      // .{ .name = "TEMPERATURE", .value = null, .description = "enables temperature extension; set fixed-temperature cells with TYPE_T (similar to EQUILIBRIUM_BOUNDARIES); allocates an extra 32 (FP32) or 18 (FP16) Bytes/cell",},
      // .{ .name = "SUBGRID", .value = null, .description = "enables Smagorinsky-Lilly subgrid turbulence LES model to keep simulations with very large Reynolds number stable",},
      // .{ .name = "PARTICLES", .value = null, .description = "enables particles with immersed-boundary method (for 2-way coupling also activate VOLUME_FORCE and FORCE_FIELD; only supported in single-GPU)",},
      // .{ .name = "INTERACTIVE_GRAPHICS", .value = null, .description = "enable interactive graphics; start/pause the simulation by pressing P; either Windows or Linux X11 desktop must be available; on Linux: change to \"compile on Linux with X11\" command in make.sh",},
      .{ .name = "INTERACTIVE_GRAPHICS_ASCII", .value = null, .description = "enable interactive graphics in ASCII mode the console; start/pause the simulation by pressing P",},
      // .{ .name = "GRAPHICS", .value = null, .description = "run FluidX3D in the console, but still enable graphics functionality for writing rendered frames to the hard drive",},

      .{ .name = "GRAPHICS_FRAME_WIDTH", .value = "1920"     ,.description =  "set frame width if only GRAPHICS is enabled" },
      .{ .name = "GRAPHICS_FRAME_HEIGHT", .value = "1080"       ,.description =  "set frame height if only GRAPHICS is enabled" },
      .{ .name = "GRAPHICS_BACKGROUND_COLOR", .value = "0x000000" ,.description =  "set background color; black background (default) = 0x000000, white background = 0xFFFFFF" },
      // .{ .name = "GRAPHICS_TRANSPARENCY", .value = "0.7f"     ,.description =  "optional: comment/uncomment this line to disable/enable semi-transparent rendering (looks better but reduces framerate), number represents transparency (equal to 1-opacity) (default: 0.7f)" },
      .{ .name = "GRAPHICS_U_MAX", .value = "0.25f"    ,.description =  "maximum velocity for velocity coloring in units of LBM lattice speed of sound (c=1/sqrt(3)) (default: 0.25f)" },
      .{ .name = "GRAPHICS_Q_CRITERION", .value = "0.0001f"  ,.description =  "Q-criterion value for Q-criterion isosurface visualization (default: 0.0001f)" },
      .{ .name = "GRAPHICS_F_MAX", .value = "0.002f"   ,.description =  "maximum force in LBM units for visualization of forces on solid boundaries if VOLUME_FORCE is enabled and lbm.calculate_force_on_boundaries(); is called (default: 0.002f)" },
      .{ .name = "GRAPHICS_STREAMLINE_SPARSE", .value = "4"        ,.description =  "set how many streamlines there are every x lattice points" },
      .{ .name = "GRAPHICS_STREAMLINE_LENGTH", .value = "128"        ,.description =  "set maximum length of streamlines" },
      .{ .name = "GRAPHICS_RAYTRACING_TRANSMITTANCE", .value = "0.25f"    ,.description =  "transmitted light fraction in raytracing graphics (\"0.25f\" = 1/4 of light is transmitted and 3/4 is absorbed along longest box side length, \"1.0f\" = no absorption)" },
      .{ .name = "GRAPHICS_RAYTRACING_COLOR", .value = "0x005F7F" ,.description =  "absorption color of fluid in raytracing graphics" },

      .{ .name = "TYPE_S", .value = "0b00000001", .description = "(stationary or moving) solid boundary" },
      .{ .name = "TYPE_E", .value = "0b00000010", .description = "equilibrium boundary (inflow/outflow)" },
      .{ .name = "TYPE_T", .value = "0b00000100", .description = "temperature boundary" },
      .{ .name = "TYPE_F", .value = "0b00001000", .description = "fluid" },
      .{ .name = "TYPE_I", .value = "0b00010000", .description = "interface" },
      .{ .name = "TYPE_G", .value = "0b00100000", .description = "gas" },
      .{ .name = "TYPE_X", .value = "0b01000000", .description = "reserved type X" },
      .{ .name = "TYPE_Y", .value = "0b10000000", .description = "reserved type Y" },
      .{ .name = "VIS_FLAG_LATTICE", .value = "0b00000001"  , .description = null },
      .{ .name = "VIS_FLAG_SURFACE", .value = "0b00000010" , .description = null },
      .{ .name = "VIS_FIELD", .value = "0b00000100" , .description = null },
      .{ .name = "VIS_STREAMLINES", .value = "0b00001000" , .description = null },
      .{ .name = "VIS_Q_CRITERION", .value = "0b00010000" , .description = null },
      .{ .name = "VIS_PHI_RASTERIZE", .value = "0b00100000" , .description = null },
      .{ .name = "VIS_PHI_RAYTRACE", .value = "0b01000000" , .description = null },
      .{ .name = "VIS_PARTICLES", .value = "0b10000000" , .description = null },

      // #ifdef BENCHMARK
      // #undef UPDATE_FIELDS
      // #undef VOLUME_FORCE
      // #undef FORCE_FIELD
      // #undef MOVING_BOUNDARIES
      // #undef EQUILIBRIUM_BOUNDARIES
      // #undef SURFACE
      // #undef TEMPERATURE
      // #undef SUBGRID
      // #undef PARTICLES
      // #undef INTERACTIVE_GRAPHICS
      // #undef INTERACTIVE_GRAPHICS_ASCII
      // #undef GRAPHICS
      // #endif // BENCHMARK

    };
    // zig fmt: on
    exe.defineCMacro("fpxx", "float");
    exe.defineCMacro("CONFIG_SET", null);
    for (options) |opt| {
        exe.defineCMacro(opt.name, opt.value);
        if (std.mem.eql(u8, opt.name, "FP16S") or std.mem.eql(u8, opt.name, "FP16C")) {
            exe.defineCMacro("fpxx", "ushort");
        }
        if (std.mem.eql(u8, opt.name, "INTERACTIVE_GRAPHICS") or std.mem.eql(u8, opt.name, "INTERACTIVE_GRAPHICS_ASCII")) {
            exe.defineCMacro("GRAPHICS", null);
            exe.defineCMacro("UPDATE_FIELDS", null);
        }
        if (std.mem.eql(u8, opt.name, "TEMPERATURE")) {
            exe.defineCMacro("VOLUME_FORCE", null);
        }
        if (std.mem.eql(u8, opt.name, "TEMPERATURE")) {
            exe.defineCMacro("VOLUME_FORCE", null);
        }
        if (std.mem.eql(u8, opt.name, "PARTICLES") or std.mem.eql(u8, opt.name, "SURFACE")) {
            exe.defineCMacro("UPDATE_FIELDS", null);
        }
    }
    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run FluidX3D");
    run_step.dependOn(&run_cmd.step);

    const examples = [_]Program{
        .{
            .name = "basic_window",
            .path = "examples/core/basic_window.zig",
            .desc = "Creates a basic window with text",
        },
    };
    const examples_step = b.step("examples", "Builds all the examples");
    const system_lib = b.option(bool, "system-raylib", "link to preinstalled raylib libraries") orelse false;
    _ = system_lib;

    for (examples) |ex| {
        const ex_bin = b.addExecutable(.{
            .name = ex.name,
            .root_source_file = .{ .path = ex.path },
            .optimize = optimize,
            .target = target,
        });
        const ex_run_cmd = b.addRunArtifact(ex_bin);
        const ex_run_step = b.step(ex.name, ex.desc);
        ex_run_step.dependOn(&ex_run_cmd.step);
        examples_step.dependOn(&ex_bin.step);
    }
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

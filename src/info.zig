const std = @import("std");
const defines = @import("defines.zig");

const Info = @This();

allow_rendering: bool = false,
runtime_lbm: f32 = 0.0,
runtime_total: f32 = 0.0,
runtime_lbm_timestep_last: f32 = 1.0,
runtime_lbm_timestep_smooth: f32 = 1.0,
runtime_lbm_last: f32 = 0.0,
steps: u64 = 18446744073709551615,
steps_last: u64 = 0,
cpu_mem_required: u32 = 0,
gpu_mem_required: u32 = 0,
clock: std.time.Timer,

pub fn init(config: defines.Configuration) !Info {
    //todo: set lmb

    std.log.info("Relaxation: {s}", .{@tagName(config.relax)});
    std.log.info("Floating Point: {s}", .{@tagName(config.fpx)});

    //todo: add cpu and gpu mem requirements
    std.log.info("Allocating memory. This may take a few seconds.", .{});
    return Info{
        .clock = try std.time.Timer.start(),
    };
}

pub fn append(self: *Info, steps: u64, t: u64) void {
    self.steps = steps;
    self.steps_last = t;
    self.runtime_lbm_last = self.runtime_lbm;
    self.runtime_total = self.clock.lap();
}

pub fn update(self: *Info, dt: u64) void {
    self.runtime_lbm_timestep_last = dt;
    self.runtime_lbm_timestep_smooth = (dt + 0.3) / (0.3 / self.runtime_lbm_timestep_smooth + 1.0);
    self.runtime_lbm += dt;
    self.runtime_total = self.clock.lap();
}

pub fn time(self: *Info) u64 {
    if (self.steps == 18446744073709551615) {
        return self.runtime_lbm;
    } else {
        //todo: update for lbm
        const LBM: f64 = 1;
        return (self.steps / LBM - 1.0) * (self.runtime_lbm - self.runtime_lbm_last);
    }
}
// 	void print_logo() const;
pub fn logo(self: *Info) void {
    _ = self;
    //todo: add color
    //const ED = comptime "\x1b[";
    std.log.info(
        \\.-----------------------------------------------------------------------------.
        \\|                       ______________   ______________                       |
        \\|                       \   ________  | |  ________   /                       |
        \\|                        \  \       | | | |       /  /                        |
        \\|                         \  \      | | | |      /  /                         |
        \\|                          \  \     | | | |     /  /                          |
        \\|                           \  \_.-"  | |  "-._/  /                           |
        \\|                            \    _.-" _ "-._    /                            |
        \\|                             \.-" _.-" "-._ "-./                             |
        \\|                               .-"  .-"-.  "-.                               |
        \\|                               \  v"     "v  /                               |
        \\|                                \  \     /  /                                |
        \\|                                 \  \   /  /                                 |
        \\|                                  \  \ /  /                                  |
        \\|                                   \  '  /                                   |
        \\|                                    \   /                                    |
        \\|                                     \ /                FluidX3D Version 2.9 |
        \\|                                      '     Copyright (c) Dr. Moritz Lehmann |
        \\|-----------------------------------------------------------------------------|
    , .{});
}
// 	void print_initialize(); // enables interactive rendering
// 	void print_update() const;
// 	void print_finalize(); // disables interactive rendering

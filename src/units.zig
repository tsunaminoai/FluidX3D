/// contains the 3 base units m, kg, s for unit conversions and vtk output
const std = @import("std");
const utils = @import("utilities.zig");

const Units = @This();

// 1 lattice unit times m/kg/s is meter/kilogram/seconds
var m: f32 = 1;
var kg: f32 = 1;
var s: f32 = 1;

/// length x, velocity u, density rho in both simulation and SI units
pub fn set_m_kg_s_SI(self: *Units, length: f32, velocity: f32, density: f32, si_x: f32, si_u: f32, si_rho: f32) void {
    // length si_x = x*[m]
    self.m = si_x / length;
    // density si_rho = rho*[kg/m^3]
    self.kg = si_rho / density * utils.cube(m);
    // velocity si_u = u*[m/s]
    self.s = velocity / si_u * m;
}

/// manual setting of units
pub fn set_m_kg_s(self: *Units, meters: f32, kilograms: f32, seconds: f32) void {
    self.m = meters;
    self.kg = kilograms;
    self.s = seconds;
}

// the following methods convert SI units into simulation units (have to be called after set_m_kg_s(...);)
/// length
pub fn x(self: *Units, si_x: f32) f32 {
    return si_x / self.m;
}
/// mass
pub fn M(self: *Units, si_M: f32) f32 {
    return si_M / self.kg;
}
/// time
pub fn t(self: *Units, si_t: f32) u64 {
    return @as(u64, @intFromFloat(si_t / self.s));
}
/// frequency
pub fn frequency(self: *Units, si_frequency: f32) f32 {
    return si_frequency * self.s;
}
/// resistance
pub fn omega(self: *Units, si_omega: f32) f32 {
    return si_omega * self.s;
}
/// velocity
pub fn u(self: *Units, si_u: f32) f32 {
    return si_u * self.s / self.m;
}
/// density
pub fn rho(self: *Units, si_rho: f32) f32 {
    return si_rho * utils.cube(self.m) / self.kg;
}
/// Q-factor
pub fn Q(self: *Units, si_Q: f32) f32 {
    return si_Q * self.s / utils.cube(self.m);
}
pub fn nu(self: *Units, si_nu: f32) f32 {
    return si_nu * self.s / utils.square(self.m);
}
pub fn mu(self: *Units, si_mu: f32) f32 {
    return si_mu * self.s * self.m / self.kg;
}
/// gravity
pub fn g(self: *Units, si_g: f32) f32 {
    return si_g / self.m * utils.square(self.s);
}
/// acceleration as force
pub fn f(self: *Units, si_f: f32) f32 {
    return si_f * utils.square(self.m * self.s) / self.kg;
}
/// acceleration as gravity
pub fn fg(self: *Units, si_rho: f32, si_g: f32) f32 {
    return si_rho * si_g * utils.square(self.m * self.s) / self.kg;
}
pub fn F(self: *Units, si_F: f32) f32 {
    return si_F * utils.square(self.s) / (self.kg * self.m);
}
pub fn T(self: *Units, si_T: f32) f32 {
    return si_T * utils.square(self.s) / (self.kg * utils.square(self.m));
}
pub fn sigma(self: *Units, si_sigma: f32) f32 {
    return si_sigma * utils.square(self.s) / self.kg;
}

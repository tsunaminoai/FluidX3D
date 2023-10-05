const std = @import("std");
const Config = @import("defines.zig").Configuration;

pub fn main() anyerror!void {
    var c = Config.defaults();
    _ = c;
}

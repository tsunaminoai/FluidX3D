const std = @import("std");
const Config = @import("defines.zig").Configuration;
const Info = @import("info.zig");

pub fn main() anyerror!void {
    var c = Config.defaults();
    var info = try Info.init(c);
    info.logo();
}

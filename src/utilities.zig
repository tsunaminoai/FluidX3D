const std = @import("std");

const pif: f16 = 3.1415927;
const pi: f32 = 3.141592653589793;
const min_char: i8 = -128;
const max_char: i8 = 127;
const max_uchar: u8 = 255;
const min_short: i16 = 32768;
const max_short: i16 = 32767;
const max_ushort: u16 = 65535;
const min_int: i32 = -2147483648;
const max_int: i32 = 2147483647;
const max_uint: u32 = 4294967295;
const min_slong: i64 = -9223372036854775808;
const max_slong: i64 = 9223372036854775807;
const max_ulong: u64 = 18446744073709551615;
const min_float: f32 = 1.401298464E-45;
const max_float: f32 = 3.402823466E38;
const epsilon_float: f32 = 1.192092896E-7;
const inf_float: f32 = @as(f32, @floatFromInt(0x7F800000));
const nan_float: f32 = @as(f32, @floatFromInt(0xFFFFFFFF));
const min_double: f64 = 4.9406564584124654E-324;
const max_double: f64 = 1.7976931348623158E308;
const epsilon_double: f64 = 2.2204460492503131E-16;
const inf_double: f64 = @as(f64, @floatFromInt(0x7FF0000000000000));
const nan_double: f64 = @as(f64, @floatFromInt(0xFFFFFFFFFFFFFFFF));

pub fn cube(x: f32) f32 {
    return x * x * x;
}

pub fn square(x: f32) f32 {
    return x * x;
}

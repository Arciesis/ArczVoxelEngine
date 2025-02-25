const std = @import("std");

pub fn Mat(comptime T: type, comptime M: usize, comptime N: usize) type {
    comptime {
        if ((@typeInfo(T) != .Int) and (@typeInfo(T) != .Float)) {
            @compileError("Only numeric types are supported");
        }
    }

    return struct {
        const Self = @This();
        data: [M]@Vector(N, T),

        pub fn init(init_val: [M][N]T) Self {
            var res: Self = undefined;
            for (0..M) |i| {
                res.data[i] = init_val[i];
            }

            return res;
        }
    };
}

const testing = std.testing;

test "Mat init u32" {
    const data: [3][4]u32 = .{ .{ 2, 3, 4, 5 }, .{ 6, 7, 8, 9 }, .{ 10, 11, 12, 13 } };
    const Mat3x4u32 = Mat(u32, 3, 4).init(data);

    try testing.expect(Mat3x4u32.data[0][0] == 2);
    try testing.expect(Mat3x4u32.data[1][0] == 6);
    try testing.expect(Mat3x4u32.data[2][0] == 10);
    try testing.expect(Mat3x4u32.data[0][1] == 3);
    try testing.expect(Mat3x4u32.data[1][1] == 7);
    try testing.expect(Mat3x4u32.data[2][1] == 11);
    try testing.expect(Mat3x4u32.data[0][2] == 4);
    try testing.expect(Mat3x4u32.data[1][2] == 8);
    try testing.expect(Mat3x4u32.data[2][2] == 12);
    try testing.expect(Mat3x4u32.data[0][3] == 5);
    try testing.expect(Mat3x4u32.data[1][3] == 9);
    try testing.expect(Mat3x4u32.data[2][3] == 13);
}

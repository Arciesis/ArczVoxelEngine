const std = @import("std");
const VectorError = @import("vector.zig").VectorError;

pub fn Vec3(comptime T: type) type {
    return struct {
        const Self = @This();
        vec: @Vector(3, T),

        pub fn init(x: T, y: T, z: T) Self {
            return Self{
                .vec = @Vector(3, T){ x, y, z },
            };
        }

        fn isUnsigned(_: Self) bool {
            return switch (@typeInfo(T)) {
                .Int => |val| blk: {
                    if (val.signedness == .unsigned) break :blk true;
                    break :blk false;
                },
                else => return false,
            };
        }

        pub fn add(self: Self, other: Self) Self {
            const nx = self.vec[0] + other.vec[0];
            const ny = self.vec[1] + other.vec[1];
            const nz = self.vec[2] + other.vec[2];

            return Self.init(nx, ny, nz);
        }

        pub fn sub(self: Self, other: Self) Self {
            // const signedness = @typeInfo(T) == .Int { .signedness.unsigned };
            if (self.isUnsigned()) {
                const nx = if (self.vec[0] > other.vec[0]) self.vec[0] - other.vec[0] else 0;
                const ny = if (self.vec[1] > other.vec[1]) self.vec[1] - other.vec[1] else 0;
                const nz = if (self.vec[2] > other.vec[2]) self.vec[2] - other.vec[2] else 0;
                return Self.init(nx, ny, nz);
            }

            const nx = self.vec[0] - other.vec[0];
            const ny = self.vec[1] - other.vec[1];
            const nz = self.vec[2] - other.vec[2];
            return Self.init(nx, ny, nz);
        }

        pub fn scalarMul(self: Self, scalar: T) Self {
            const nx = scalar * self.vec[0];
            const ny = scalar * self.vec[1];
            const nz = scalar * self.vec[2];
            return Self.init(nx, ny, nz);
        }

        pub fn scalarDiv(self: Self, scalar: T) !Self {
            if (scalar == 0) {
                return VectorError.divByZero;
            }

            if (@typeInfo(T) == .Float) {
                return Self.init(self.vec[0] / scalar, self.vec[1] / scalar, self.vec[2] / scalar);
            }

            return Self.init(@divTrunc(self.vec[0], scalar), @divTrunc(self.vec[1], scalar), @divTrunc(self.vec[2], scalar));
        }

        pub fn norm2(self: Self) T {
            const typeinfo = @typeInfo(T);
            switch (typeinfo) {
                .Float => {
                    const x_norm = @abs(self.vec[0]);
                    const y_norm = @abs(self.vec[1]);
                    const z_norm = @abs(self.vec[2]);

                    return @sqrt((x_norm * x_norm) + (y_norm * y_norm) + (z_norm * z_norm));
                },
                .Int => {
                    const x: f128 = @floatFromInt(self.vec[0]);
                    const y: f128 = @floatFromInt(self.vec[1]);
                    const z: f128 = @floatFromInt(self.vec[2]);

                    const x_squared = x * x;
                    const y_squared = y * y;
                    const z_squared = z * z;

                    return @intFromFloat(@sqrt(x_squared + y_squared + z_squared));
                },
                else => unreachable,
            }
        }

        pub fn dot(self: Self, other: Self) T {
            return self.vec[0] * other.vec[0] + self.vec[1] * other.vec[1] + self.vec[2] * other.vec[2];
        }

        pub fn cross(self: Self, other: Self) Self {
            const nx = (self.vec[1] * other.vec[2]) - (self.vec[2] * other.vec[1]);
            const ny = (self.vec[2] * other.vec[0]) - (self.vec[0] * other.vec[2]);
            const nz = (self.vec[0] * other.vec[1]) - (self.vec[1] * other.vec[0]);

            return Self.init(nx, ny, nz);
        }
    };
}

test "Vec3i32 init" {
    const v1 = Vec3(i32).init(1, 2, 3);

    try std.testing.expect(v1.vec[0] == 1);
    try std.testing.expect(v1.vec[1] == 2);
    try std.testing.expect(v1.vec[2] == 3);
}

test "Vec3i32 add" {
    const v1 = Vec3(i32).init(1, 2, 3);
    const v2 = Vec3(i32).init(2, 4, 6);

    const res = v1.add(v2);

    try std.testing.expect(res.vec[0] == 3);
    try std.testing.expect(res.vec[1] == 6);
    try std.testing.expect(res.vec[2] == 9);
}

test "Vec3u32 sub" {
    const v1 = Vec3(u32).init(3, 2, 1);
    const v2 = Vec3(u32).init(4, 1, 2);
    const res = v1.sub(v2);

    try std.testing.expect(res.vec[0] == 0);
    try std.testing.expect(res.vec[1] == 1);
    try std.testing.expect(res.vec[2] == 0);
}

test "Vec3i32 sub" {
    const v1 = Vec3(i32).init(-3, 2, 1);
    const v2 = Vec3(i32).init(4, -1, 2);
    const res = v1.sub(v2);

    try std.testing.expect(res.vec[0] == -7);
    try std.testing.expect(res.vec[1] == 3);
    try std.testing.expect(res.vec[2] == -1);
}

test " Vec Signedness" {
    const v1 = Vec3(u32).init(3, 5, 7);
    const v2 = Vec3(i32).init(-4, -6, 8);
    const v3 = Vec3(f32).init(-6.5, -6.8, 8.5);

    try std.testing.expect(v1.isUnsigned());
    try std.testing.expect(!v2.isUnsigned());
    try std.testing.expect(!v3.isUnsigned());
}

test "Vecf32 scalarDiv by zero" {
    const v1 = Vec3(f32).init(3.4, -4.7, 0.5);
    const scalar = 0.0;
    const res = v1.scalarDiv(scalar);

    try std.testing.expectError(VectorError.divByZero, res);
}

test "Vec3i32 scalarDiv" {
    const v1 = Vec3(i32).init(32, -43, 5);
    const scalar = 4;
    const res = try v1.scalarDiv(scalar);

    try std.testing.expect(res.vec[0] == 8);
    try std.testing.expect(res.vec[1] == -10);
    try std.testing.expect(res.vec[2] == 1);
}

test "Vec3f32 normn2" {
    const v1 = Vec3(f32).init(-4.5, 5.7, 9.8);
    const norm = v1.norm2();

    try std.testing.expectApproxEqRel(norm, 12.19, 0.01);
    try std.testing.expect(@TypeOf(norm) == f32);
}

test "Vec3u32 normn2" {
    const v1 = Vec3(u32).init(5, 5, 9);
    const norm = v1.norm2();

    try std.testing.expect(norm == 11);
    try std.testing.expect(@TypeOf(norm) == u32);
}

test "Vec3i32 cross" {
    const v1 = Vec3(i32).init(-54, 67, -87);
    const v2 = Vec3(i32).init(34, -98, 56);
    const res = v1.cross(v2);

    try std.testing.expect(res.vec[0] == -4774);
    try std.testing.expect(res.vec[1] == 66);
    try std.testing.expect(res.vec[2] == 3014);
}

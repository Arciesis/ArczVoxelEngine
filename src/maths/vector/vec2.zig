const std = @import("std");
const VectorError = @import("vector.zig").VectorError;

/// Internal representation of a 2-Vector
pub fn Vec2(comptime T: type) type {
    return struct {
        const Self = @This();
        vec: @Vector(2, T),

        pub fn init(x: T, y: T) Self {
            return Self{
                .vec = @Vector(2, T){ x, y },
            };
        }

        pub fn add(self: Self, other: Self) Self {
            const nx = self.vec[0] + other.vec[0];
            const ny = self.vec[1] + other.vec[1];

            return Self.init(nx, ny);
        }

        pub fn sub(self: Self, other: Self) Self {
            const nx = if (other.vec[0] > self.vec[0]) 0 else self.vec[0] - other.vec[0];
            const ny = if (other.vec[1] > self.vec[1]) 0 else self.vec[1] - other.vec[1];

            return Self.init(nx, ny);
        }

        pub fn scalar_mul(self: Self, scalar: T) Self {
            const nx = self.vec[0] * scalar;
            const ny = self.vec[1] * scalar;
            return Self.init(nx, ny);
        }

        pub fn scalar_div(self: Self, scalar: T) !Self {
            if (scalar == 0) {
                return VectorError.divByZero;
            }

            if (@typeInfo(T) == .Float) {
                return Self.init(self.vec[0] / scalar, self.vec[1] / scalar);
            } else {
                return Self.init(@divTrunc(self.vec[0], scalar), @divTrunc(self.vec[1], scalar));
            }
        }

        pub fn norm2(self: Self) T {
            const prt = @typeInfo(T);

            switch (prt) {
                .Float => {
                    const x_norm = @abs(self.vec[0]);
                    const y_norm = @abs(self.vec[1]);
                    const x_squared = x_norm * x_norm;
                    const y_squared = y_norm * y_norm;

                    return @sqrt(x_squared + y_squared);
                },
                .Int => {
                    const x1: f128 = @floatFromInt(self.vec[0]);
                    const y1: f128 = @floatFromInt(self.vec[1]);

                    const x_squared = @abs(x1) * @abs(x1);
                    const y_squared = @abs(y1) * @abs(y1);
                    return @intFromFloat(@sqrt(x_squared + y_squared));
                },
                else => unreachable,
            }
        }

        pub fn dot(self: Self, other: Self) T {
            return self.vec[0] * other.vec[0] + self.vec[1] * other.vec[1];
        }

        pub fn proj(self: Self, other: Self) Self {
            const norm_sq = other.dot(other);
            if (norm_sq == 0) return Self.init(0, 0);

            if (@typeInfo(T) == .Float) {
                return other.scalar_mul(self.dot(other) / norm_sq);
            } else return other.scalar_mul(@divTrunc(self.dot(other), norm_sq));
        }
    };
}

test "vec2u32 add" {
    const v1 = Vec2(f32).init(64.0, 64.0);
    const v2 = Vec2(f32).init(65.0, 65.0);
    const res = v1.add(v2);

    try std.testing.expect(res.vec[0] == 129.0);
    try std.testing.expect(res.vec[1] == 129.0);
}

test "vec2u32 sub" {
    const v1 = Vec2(u32).init(64, 64);
    const v2 = Vec2(u32).init(65, 65);
    const res = v1.sub(v2);

    try std.testing.expect(res.vec[0] == 0);
    try std.testing.expect(res.vec[1] == 0);
}

test "vec2f32 scalar mul" {
    const v1 = Vec2(f32).init(98675.0, -87545.0);
    const fscalar = 512.0;

    const res = v1.scalar_mul(fscalar);
    try std.testing.expect(res.vec[0] == 50521600.0);
    try std.testing.expect(res.vec[1] == -44823040);
}

test "vec2u32 scalar div by zero" {
    const v1 = Vec2(u32).init(64, 64);
    const scalar = 0;
    const res = v1.scalar_div(scalar);

    try std.testing.expectError(VectorError.divByZero, res);
}

test "vec2f32 scalar div by zero" {
    const v1 = Vec2(f32).init(64, 64);
    const scalar = 0.0;
    const res = v1.scalar_div(scalar);

    try std.testing.expectError(VectorError.divByZero, res);
}

test "vec2u32 scalar div" {
    const v1 = Vec2(u32).init(64.0, 64.0);
    const scalar = 4.0;
    const res = try v1.scalar_div(scalar);

    try std.testing.expect(res.vec[0] == 16.0);
    try std.testing.expect(res.vec[1] == 16.0);
}

test "Vec2i32 norm2" {
    const v1 = Vec2(i32).init(-485, 7456);
    const res = v1.norm2();

    try std.testing.expect(res == 7471);
}

test "Vecf32 norm2" {
    const v1 = Vec2(f32).init(-485.876, 7856.765);
    const res = v1.norm2();

    try std.testing.expectApproxEqRel(7871.77, res, 0.001);
}

test "Vec32i dot" {
    const v1 = Vec2(i32).init(456, 512);
    const v2 = Vec2(i32).init(12, 9876);
    const res = v1.dot(v2);

    try std.testing.expect(res == 5061984);
}

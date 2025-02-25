const Vec2 = @import("vec2.zig").Vec2;
const Vec3 = @import("vec3.zig").Vec3;

pub const VectorError = error{
    divByZero,
};

pub const Vec2u32 = Vec2(u32);
pub const Vec2u64 = Vec2(u64);

pub const Vec2i32 = Vec2(i32);
pub const Vec2i64 = Vec2(i64);

pub const Vec2f32 = Vec2(f32);
pub const Vec2f64 = Vec2(f64);

pub const Vec3u32 = Vec3(u32);
pub const Vec3u64 = Vec3(u64);

pub const Vec3i32 = Vec3(i32);
pub const Vec3i64 = Vec3(i64);

pub const Vec3f32 = Vec3(f32);
pub const Vec3f64 = Vec3(f64);

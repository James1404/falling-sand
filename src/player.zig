const std = @import("std");
const rl = @import("raylib");

pos: @Vector(2, f32),

const Self = @This();

pub fn make() Self {
    return .{
        .pos = @splat(0),
    };
}

pub fn update(self: *Self) void {}
pub fn draw(self: *Self) void {}

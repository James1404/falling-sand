const std = @import("std");
const rl = @import("raylib");

pos: @Vector(2, f32),
vel: @Vector(2, f32),

const Size = @Vector(2, f32){ 2, 5 };

const Self = @This();

pub fn make() Self {
    return .{
        .pos = @splat(0),
    };
}

pub fn update(self: *Self) void {
    self.vel[0] = 0;
    if (rl.isKeyDown(.key_a) or rl.isKeyDown(.key_left)) {
        self.vel[0] -= 1;
    }
    if (rl.isKeyDown(.key_d) or rl.isKeyDown(.key_right)) {
        self.vel[0] += 1;
    }
}

pub fn draw(self: *Self) void {
    rl.drawRectangleV(
        .{ .x = self.pos[0], .y = self.pos[1] },
        Size,
        rl.Color.red,
    );
}

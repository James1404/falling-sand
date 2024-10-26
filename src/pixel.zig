const std = @import("std");
const rl = @import("raylib");
const Buffer = @import("buffer.zig");

pub const Loc = @Vector(2, isize);
pub const Tag = enum { Sand, Dirt, Water };

tag: Tag,
color: @Vector(4, u8),
pos: Loc,
vel: Loc,

const Self = @This();

pub fn make(tag: Tag, pos: Loc, rand: std.Random) Self {
    return .{
        .tag = tag,
        .color = switch (tag) {
            .Sand => .{
                218 - rand.intRangeAtMost(u8, 0, 10),
                203 - rand.intRangeAtMost(u8, 0, 10),
                74 - rand.intRangeAtMost(u8, 0, 10),
                255,
            },
            .Dirt => .{
                144 - rand.intRangeAtMost(u8, 0, 10),
                93 - rand.intRangeAtMost(u8, 0, 10),
                35 - rand.intRangeAtMost(u8, 0, 10),
                255,
            },
            .Water => .{
                69 - rand.intRangeAtMost(u8, 0, 10),
                108 - rand.intRangeAtMost(u8, 0, 10),
                215 - rand.intRangeAtMost(u8, 0, 10),
                100,
            },
        },
        .pos = pos,
        .vel = @splat(0),
    };
}

pub fn draw(self: Self) void {
    rl.drawRectangle(
        @intCast(self.pos[0]),
        @intCast(self.pos[1]),
        1,
        1,
        .{
            .r = self.color[0],
            .g = self.color[1],
            .b = self.color[2],
            .a = self.color[3],
        },
    );
}

pub fn weight(self: Self) usize {
    return switch (self.tag) {
        .Dirt => 2,
        .Sand => 2,
        .Water => 1,
    };
}

pub fn update(
    self: *Self,
    buffer: *Buffer,
) void {
    switch (self.tag) {
        .Sand => {
            if (self.moveTo(buffer, .{ 0, 1 })) return;
            if (self.moveTo(buffer, .{ -1, 1 })) return;
            if (self.moveTo(buffer, .{ 1, 1 })) return;
        },
        .Water => {
            if (self.moveTo(buffer, .{ 0, 1 })) return;
            if (self.moveTo(buffer, .{ -1, 1 })) return;
            if (self.moveTo(buffer, .{ 1, 1 })) return;
            if (self.moveTo(buffer, .{ -1, 0 })) return;
            if (self.moveTo(buffer, .{ 1, 0 })) return;
        },
        else => {},
    }
}

pub fn moveTo(self: *Self, buffer: *Buffer, dir: Loc) bool {
    const p = self.pos + dir;
    if (buffer.swap(self.pos, p)) {
        self.pos = p;
        return true;
    }

    return false;
}

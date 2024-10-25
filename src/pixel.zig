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

pub fn update(
    self: *Self,
    buffer: *Buffer,
) void {
    switch (self.tag) {
        .Sand => {
            const down = Loc{ 0, 1 };
            const left = Loc{ -1, 1 };
            const right = Loc{ 1, 1 };

            if (self.moveTo(buffer, down)) return;
            if (self.moveTo(buffer, left)) return;
            if (self.moveTo(buffer, right)) return;
        },
        .Dirt => {},
        .Water => {
            const down = Loc{ 0, 1 };
            const left = Loc{ -1, 0 };
            const right = Loc{ 1, 0 };
            const downleft = Loc{ -1, 1 };
            const downright = Loc{ 1, 1 };

            if (self.moveTo(buffer, down)) return;
            if (self.moveTo(buffer, left)) return;
            if (self.moveTo(buffer, right)) return;
            if (self.moveTo(buffer, downleft)) return;
            if (self.moveTo(buffer, downright)) return;
        },
    }
}

pub fn moveTo(self: *Self, buffer: *Buffer, dir: Loc) bool {
    const p = self.pos + dir;
    if (buffer.empty(p)) {
        const idx = buffer.at(self.pos);
        buffer.set(self.pos, null);
        self.pos = p;
        buffer.set(p, idx);
        return true;
    }

    return false;
}

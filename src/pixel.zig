const std = @import("std");
const rl = @import("raylib");
const Buffer = @import("buffer.zig");

pub const Loc = @Vector(2, isize);
pub const Tag = enum { Air, Sand, Dirt, Water };

tag: Tag,
velocity: isize,
color: @Vector(4, u8),

const Self = @This();

pub fn make(tag: Tag, rand: std.Random) Self {
    return .{
        .tag = tag,
        .velocity = 0,
        .color = switch (tag) {
            .Air => .{ 0, 0, 0, 0 },
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
    };
}

pub fn draw(self: Self, p: Loc) void {
    rl.drawRectangle(
        @intCast(p[0]),
        @intCast(p[1]),
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
    self: Self,
    p: Loc,
    in: Buffer,
    out: Buffer,
) void {
    switch (self.tag) {
        .Sand => {
            const down = Loc{ 0, 1 };
            // const left = .{ -1, 1 };
            // const right = .{ 1, 1 };

            // if (in.get(.{ p[0], p[1] + 1 }).tag == .Air and p[1] + 1 < in.height) {
            //     out.set(.{ p[0], p[1] + 1 }, self);
            // } else {
            //     const dir: isize = if (in.rand.boolean()) 1 else -1;
            //     const bottomDir = Loc{
            //         @intCast(std.math.clamp(@as(isize, @intCast(p[0])) + dir, 0, @as(isize, @intCast(in.width - 1)))),
            //         p[1] + 1,
            //     };
            //     const sideDir = .{ bottomDir[0], p[1] };

            //     if (bottomDir[1] < in.height) {
            //         if (in.get(sideDir).tag == .Air and sideDir[1] < in.height) {
            //             if (in.get(bottomDir).tag == .Air and bottomDir[1] < in.height) {
            //                 out.set(bottomDir, self);
            //                 return;
            //             }
            //         }
            //     }

            //     out.set(.{ p[0], p[1] }, self);
            // }

            var final = self;

            final.velocity += 1;

            if (in.get(p + down).tag == .Air) {
                out.set(final.moveTo(p, down, final.velocity, in), final);
            } else {
                final.velocity = 0;
                out.set(p, final);
            }
        },
        .Air => {},
        .Dirt => out.set(p, self),
        .Water => {
            // const down = .{ p[0], p[1] + 1 };
            // const left = .{ p[0] - 1, p[1] + 1 };
            // const right = .{ p[0] + 1, p[1] + 1 };
            // const downleft = .{ p[0] - 1, p[1] + 1 };
            // const downright = .{ p[0] + 1, p[1] + 1 };
            out.set(p, self);
        },
    }
}

pub fn moveTo(
    self: *Self,
    start: Loc,
    dir: Loc,
    velocity: isize,
    in: Buffer,
) Loc {
    var final = start + dir * @as(Loc, @splat(velocity));

    final[0] = std.math.clamp(final[0], 0, @as(isize, @intCast(in.width)) - 1);
    final[1] = std.math.clamp(final[1], 0, @as(isize, @intCast(in.height)) - 1);

    var p = start;
    while (p[0] != final[0] and p[1] != final[1]) : (p += dir) {
        if (in.get(p + dir).tag != .Air) {
            self.velocity = 0;
            break;
        }
    }

    return p;
}

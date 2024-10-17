const std = @import("std");
const rl = @import("raylib");

const Buffer = @import("buffer.zig");
const Pixel = @import("pixel.zig");

allocator: std.mem.Allocator,
rand: std.Random,

width: usize,
height: usize,
buffers: [2]Buffer,
index: isize,

const Self = @This();

pub fn make(
    allocator: std.mem.Allocator,
    rand: std.Random,
    width: usize,
    height: usize,
) !Self {
    return .{
        .allocator = allocator,
        .rand = rand,
        .width = width,
        .height = height,
        .buffers = [_]Buffer{
            try Buffer.make(allocator, rand, width, height),
            try Buffer.make(allocator, rand, width, height),
        },
        .index = 0,
    };
}

pub fn free(self: *Self) void {
    for (self.buffers) |buffer| {
        buffer.free();
    }
}

pub fn randomize(self: *Self) !void {
    for (0..self.width) |x| {
        for (0..self.height) |y| {
            const tag = self.rand.enumValue(Pixel.Tag);
            self.getBuffer().set(.{
                @intCast(x),
                @intCast(y),
            }, Pixel.make(tag, self.rand));
        }
    }
}

pub fn update(self: *Self) void {
    self.next();

    const in = self.getUnusedBuffer();
    const out = self.getBuffer();
    out.clear();

    var x: isize = 0;
    while (x < self.width) : (x += 1) {
        var y: isize = 0;
        while (y < self.height) : (y += 1) {
            const cell = in.get(.{ x, y });
            cell.update(.{ x, y }, in, out);
        }
    }
}

pub fn draw(self: *Self) void {
    var x: isize = 0;
    while (x < self.width) : (x += 1) {
        var y: isize = 0;
        while (y < self.height) : (y += 1) {
            const p = self.getBuffer().get(.{ x, y });
            p.draw(.{ x, y });
        }
    }

    // rl.drawRectangleLines(
    //     0,
    //     0,
    //     @intCast(self.width),
    //     @intCast(self.height),
    //     rl.Color.red,
    // );

    const p00 = rl.Vector2{ .x = 0, .y = 0 };
    const p10 = rl.Vector2{ .x = @floatFromInt(self.width), .y = 0 };
    const p11 = rl.Vector2{ .x = @floatFromInt(self.width), .y = @floatFromInt(self.height) };
    const p01 = rl.Vector2{ .x = 0, .y = @floatFromInt(self.height) };

    const color = rl.Color.red;
    rl.drawLineV(p00, p10, color);
    rl.drawLineV(p10, p11, color);
    rl.drawLineV(p11, p01, color);
    rl.drawLineV(p01, p00, color);
}

pub fn getBuffer(self: *Self) Buffer {
    return self.buffers[@intCast(self.index)];
}

fn getUnusedBuffer(self: *Self) Buffer {
    return self.buffers[@intCast(@mod((self.index - 1), self.buffers.len))];
}

fn next(self: *Self) void {
    self.index = @mod((self.index - 1), self.buffers.len);
}

test "neighbour count" {
    const allocator = std.testing.allocator;

    var world = try Self.make(allocator, 10, 10);
    defer world.free();

    for (world.buffers) |buffer| {
        buffer.clear();
    }

    world.getBuffer().set(.{ 0, 0 }, Pixel.make(.Air));

    try std.testing.expectEqual(world.getBuffer().getNeighbourCount(.{ 0, 0 }), 0);
    try std.testing.expectEqual(world.getBuffer().getNeighbourCount(.{ 1, 0 }), 1);
}

const std = @import("std");
const rl = @import("raylib");

const Buffer = @import("buffer.zig");
const Pixel = @import("pixel.zig");

allocator: std.mem.Allocator,
rand: std.Random,

width: usize,
height: usize,
buffer: Buffer,

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
        .buffer = try Buffer.make(allocator, rand, width, height),
    };
}

pub fn free(self: *Self) void {
    self.buffer.free();
}

pub fn randomize(self: *Self) !void {
    self.buffer.clear();

    for (0..self.width) |x| {
        for (0..self.height) |y| {
            const tag = self.rand.enumValue(Pixel.Tag);
            self.buffer.addPixel(Pixel.make(tag, .{
                @intCast(x),
                @intCast(y),
            }, self.rand));
        }
    }
}

pub fn update(self: *Self) void {
    self.buffer.update();
}

pub fn draw(self: *Self) void {
    self.buffer.draw();

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

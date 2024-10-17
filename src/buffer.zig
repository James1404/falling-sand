const std = @import("std");
const rl = @import("raylib");

pub fn getIndex(p: @Vector(2, isize), width: usize) usize {
    const idx = p[0] + @as(isize, @intCast(width)) * p[1];

    return @intCast(idx);
}

const Pixel = @import("pixel.zig");

allocator: std.mem.Allocator,
rand: std.Random,

memory: []Pixel,

width: usize,
height: usize,

const Self = @This();

pub fn make(
    allocator: std.mem.Allocator,
    rand: std.Random,
    width: usize,
    height: usize,
) !Self {
    const result = Self{
        .allocator = allocator,
        .rand = rand,
        .width = width,
        .height = height,
        .memory = try allocator.alloc(Pixel, width * height),
    };

    result.clear();

    return result;
}

pub fn free(self: Self) void {
    self.allocator.free(self.memory);
}

pub fn clone(self: Self, other: Self) void {
    @memcpy(self.memory, other.memory);
}

pub fn clear(self: Self) void {
    @memset(self.memory, Pixel.make(.Air, self.rand));
}

pub fn set(buffer: Self, p: @Vector(2, isize), pixel: Pixel) void {
    if (p[0] >= buffer.width or p[1] >= buffer.height) return;

    buffer.memory[getIndex(p, buffer.width)] = pixel;
}

pub fn get(buffer: Self, p: @Vector(2, isize)) Pixel {
    if (p[0] >= buffer.width or p[1] >= buffer.height) {
        return Pixel.make(.Air, buffer.rand);
    }

    return buffer.memory[getIndex(p, buffer.width)];
}

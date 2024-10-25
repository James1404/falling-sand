const std = @import("std");
const rl = @import("raylib");

pub fn getIndex(p: Loc, width: usize) usize {
    const idx = p[0] + @as(isize, @intCast(width)) * p[1];

    return @intCast(idx);
}

const Index = ?usize;

const Pixel = @import("pixel.zig");
const Loc = Pixel.Loc;

allocator: std.mem.Allocator,
rand: std.Random,

grid: []Index,
pixels: std.ArrayList(Pixel),

width: usize,
height: usize,

const Self = @This();

pub fn make(
    allocator: std.mem.Allocator,
    rand: std.Random,
    width: usize,
    height: usize,
) !Self {
    var result = Self{
        .allocator = allocator,
        .rand = rand,
        .width = width,
        .height = height,
        .grid = try allocator.alloc(Index, width * height),
        .pixels = std.ArrayList(Pixel).init(allocator),
    };

    result.clear();

    return result;
}

pub fn free(self: *Self) void {
    self.allocator.free(self.grid);
    self.pixels.deinit();
}

pub fn clear(self: *Self) void {
    @memset(self.grid, null);
}

pub fn removeAll(self: *Self) void {
    @memset(self.grid, null);
    self.pixels.clearRetainingCapacity();
}

pub fn addPixel(self: *Self, pixel: Pixel) void {
    if (!self.inBounds(pixel.pos)) {
        return;
    }

    const idx = self.pixels.items.len;
    self.pixels.append(pixel) catch |err| @panic(@errorName(err));
    self.set(pixel.pos, idx);
}

pub fn set(self: *Self, p: Loc, idx: Index) void {
    if (!self.inBounds(p)) {
        return;
    }

    self.grid[getIndex(p, self.width)] = idx;
}

pub fn get(self: *Self, p: Loc) ?Pixel {
    return if (self.at(p)) |idx| self.pixels.items[idx] else null;
}

pub fn at(self: *Self, p: Loc) Index {
    if (!self.inBounds(p)) {
        return null;
    }

    return self.grid[getIndex(p, self.width)];
}

pub fn empty(self: *Self, p: Loc) bool {
    return self.get(p) == null and self.inBounds(p);
}

pub fn inBounds(self: *Self, p: Loc) bool {
    return p[0] >= 0 and p[0] < self.width and p[1] >= 0 and p[1] < self.height;
}

pub fn update(self: *Self) void {
    for (self.pixels.items) |*pixel| {
        pixel.update(self);
    }
}

pub fn draw(self: *Self) void {
    for (self.pixels.items) |*pixel| {
        pixel.draw();
    }
}

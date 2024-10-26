const std = @import("std");
const rl = @import("raylib");

pub fn gridIdx(p: Loc, width: usize) usize {
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

    self.grid[gridIdx(p, self.width)] = idx;
}

pub fn get(self: *Self, p: Loc) ?Pixel {
    return if (self.at(p)) |idx| self.pixels.items[idx] else null;
}

pub fn getFromIndex(self: *Self, idx: Index) ?Pixel {
    return if (idx) |i| self.pixels.items[i] else null;
}

pub fn at(self: *Self, p: Loc) Index {
    if (!self.inBounds(p)) return null;
    return self.grid[gridIdx(p, self.width)];
}

pub fn empty(self: *Self, p: Loc) bool {
    return self.get(p) == null;
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

    if (comptime false) {
        var x: isize = 0;
        while (x < self.width) : (x += 1) {
            var y: isize = 0;
            while (y < self.width) : (y += 1) {
                if (self.get(.{ x, y })) |_| {
                    rl.drawCircleV(
                        .{
                            .x = @as(f32, @floatFromInt(x)) + 0.5,
                            .y = @as(f32, @floatFromInt(y)) + 0.5,
                        },
                        0.1,
                        rl.Color.green,
                    );
                }
            }
        }
    }
}

pub fn swap(self: *Self, a: Loc, b: Loc) bool {
    if (std.meta.eql(a, b)) return false;

    if (self.inBounds(a) and self.inBounds(b)) {
        const aidx = self.at(a);
        const bidx = self.at(b);

        const aweight = if (aidx) |idx| self.pixels.items[idx].weight() else 0;
        const bweight = if (bidx) |idx| self.pixels.items[idx].weight() else 0;

        if (aweight > bweight) {
            self.set(b, aidx);
            self.set(a, bidx);

            return true;
        }
    }

    return false;
}

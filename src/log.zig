const std = @import("std");
const print = std.debug.print;

pub fn info(comptime fmt: []const u8, args: anytype) void {
    print("Info: ", .{});
    print(fmt, args);
    print("\n", .{});
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    print("Warning: ", .{});
    print(fmt, args);
    print("\n", .{});
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    print("Error: ", .{});
    print(fmt, args);
    print("\n", .{});
}

const std = @import("std");

const rl = @import("raylib");
const rg = @import("raygui");
const ziglua = @import("ziglua");

const Log = @import("log.zig");

pub const World = @import("world.zig");
const Pixel = @import("pixel.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var lua = try ziglua.Lua.init(&allocator);
    defer lua.deinit();

    lua.openBase();
    lua.openLibs();
    lua.openIO();

    try lua.doFile("resources/test.lua");

    rl.initWindow(800, 600, "Hello, world");
    defer rl.closeWindow();

    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    var world = try World.make(
        allocator,
        rand,
        300,
        200,
    );
    defer world.free();

    var camera = rl.Camera2D{
        .offset = rl.Vector2.zero(),
        .rotation = 0,
        .target = rl.Vector2.zero(),
        .zoom = 1,
    };

    const dt: f32 = 1.0 / 30.0;
    var accumulator: f32 = 0;

    var paused = false;

    var currentTag = Pixel.Tag.Sand;
    const brushSize: usize = 10;

    while (!rl.windowShouldClose()) {
        if (rl.isMouseButtonDown(.mouse_button_right)) {
            const delta = rl.getMouseDelta().scale(-1.0 / camera.zoom);
            camera.target = camera.target.add(delta);
        }

        const wheel = rl.getMouseWheelMove();
        if (wheel != 0) {
            const mouseWorldPos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
            camera.offset = rl.getMousePosition();
            camera.target = mouseWorldPos;

            var scaleFactor = 1 + (0.25 * @abs(wheel));
            if (wheel < 0) {
                scaleFactor = 1 / scaleFactor;
            }

            camera.zoom = std.math.clamp(camera.zoom * scaleFactor, 0.125, 64);
        }

        if (rl.isKeyPressed(.key_r)) {
            try world.randomize();
        }

        if (rl.isMouseButtonDown(.mouse_button_left)) {
            const mouseworldpos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
            const mouseworld = .{
                @as(isize, @intFromFloat(mouseworldpos.x)),
                @as(isize, @intFromFloat(mouseworldpos.y)),
            };
            if (mouseworld[1] >= 0 and mouseworld[1] >= 0) {
                const top = mouseworld[1] - brushSize;
                const bottom = mouseworld[1] + brushSize;
                const left = mouseworld[0] - brushSize;
                const right = mouseworld[0] + brushSize;

                var y = top;
                while (y < bottom) : (y += 1) {
                    var x = left;
                    while (x < right) : (x += 1) {
                        const d = .{
                            mouseworld[0] - x,
                            mouseworld[1] - y,
                        };
                        const ps = d[0] * d[0] + d[1] * d[1];
                        if (ps <= @as(isize, @intCast(brushSize * brushSize)) and world.buffer.inBounds(.{ x, y }) and world.buffer.empty(.{ x, y })) {
                            world.buffer.addPixel(
                                Pixel.make(currentTag, .{ x, y }, rand),
                            );
                        }
                    }
                }
            }
        }

        if (rl.isKeyPressed(.key_space)) {
            paused = !paused;
        }

        if (!paused) {
            accumulator += rl.getFrameTime();
            while (accumulator >= dt) {
                world.update();
                accumulator -= dt;
            }
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.beginMode2D(camera);

        world.draw();

        const mouseworld = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
        rl.drawCircleLinesV(mouseworld, brushSize, rl.Color.white);

        rl.endMode2D();

        if (rg.guiButton(.{
            .x = 10,
            .y = 10,
            .width = 120,
            .height = 30,
        }, "Clear") == 1) {
            world.buffer.clear();
        }

        rl.drawText(@tagName(currentTag), rl.getScreenWidth() - 60, 10, 20, rl.Color.black);
        inline for (0.., std.meta.tags(@TypeOf(currentTag))) |idx, tag| {
            if (rg.guiButton(.{
                .x = @floatFromInt(rl.getScreenWidth() - 60),
                .y = (30 * idx) + (idx * 10) + 10,
                .width = 50,
                .height = 30,
            }, @tagName(tag)) == 1) {
                currentTag = tag;
            }
        }

        if (paused) {
            if (rg.guiButton(
                .{ .x = 10, .y = 40, .width = 120, .height = 30 },
                "step",
            ) == 1) {
                world.update();
            }
        }
    }
}

test {
    std.testing.refAllDecls(@This());
}

const std = @import("std");
const allocator = std.heap.page_allocator;
var memory: []u8 = undefined;

export fn removeNoise(data: [*]u8, width: usize, height: usize, range: usize) void {
    memory = allocator.alloc(u8, width * height * 4) catch return;
    defer allocator.free(memory);

    var y: i32 = 0;
    while (y < height) {
        var x: i32 = 0;
        while (x < width) {
            var totalR: i32 = 0;
            var totalG: i32 = 0;
            var totalB: i32 = 0;
            var count: i32 = 0;
            var dy: i32 = -@as(i32, @intCast(range));
            while (dy <= range) {
                var dx: i32 = -@as(i32, @intCast(range));
                while (dx <= range) {
                    const nx = x + dx;
                    const ny = y + dy;

                    if (nx >= 0 and nx < width and ny >= 0 and ny < height) {
                        const index = @as(usize, @intCast(ny * @as(i32, @intCast(width)) + nx * 4));
                        totalR += @as(i32, @intCast(data[index]));
                        totalG += @as(i32, @intCast(data[index + 1]));
                        totalB += @as(i32, @intCast(data[index + 2]));
                        count += 1;
                    }
                    dx += 1;
                }
                dy += 1;
            }

            const i = @as(usize, @intCast((y * @as(i32, @intCast(width)) + x) * 4));
            memory[i] = @as(u8, @intCast(@divTrunc(totalG, count)));
            memory[i] = @as(u8, @intCast(@divTrunc(totalR, count))); // 赤(R)の平均値を格納
            memory[i + 1] = @as(u8, @intCast(@divTrunc(totalG, count))); // 緑(G)の平均値を格納
            memory[i + 2] = @as(u8, @intCast(@divTrunc(totalB, count))); // 青(B)の平均値を格納
            memory[i + 3] = data[i + 3]; // アルファ値はそのまま保持

            x += 1;
        }
        y += 1;
    }

    var i: usize = 0;
    while (i < width * height * 4) {
        data[i] = memory[i];
        i += 1;
    }
}

export const wasmMemory = &memory;

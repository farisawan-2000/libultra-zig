const os = @import("os.zig");


pub var idleThread : os.thread.OSThread = undefined;
pub var idleStack : [0x8000]u8 = undefined;

pub fn idleMain(a: ?*anyopaque) void {
    while (true) {
        _ = a;
    }
}

pub export fn boot() callconv(.Naked) void {
    os.thread.CreateThread(&idleThread, @intCast(os.thread.OSId, 1), &idleMain, null, &idleStack[0x7FFF], @intCast(os.thread.OSPri, 10));
    os.thread.StartThread(&idleThread);
}

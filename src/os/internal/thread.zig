const thread = @import("../thread.zig");
const message = @import("../message.zig");

pub extern var ThreadTail : thread.OSThread;
pub extern var RunningThread : ?*thread.OSThread;
pub extern var ActiveQueue : *thread.OSThread;
pub extern var RunQueue : ?*thread.OSThread;
pub extern fn EnqueueThread(q: *?*thread.OSThread, t: *thread.OSThread) void;
pub extern fn EnqueueAndYield(q: *?*thread.OSThread) void;
pub extern fn PopThread(q: *?*thread.OSThread) *thread.OSThread;
pub extern fn CleanupThread() void;
pub extern fn DispatchThread() void;

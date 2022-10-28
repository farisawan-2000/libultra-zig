const thread = @import("../thread.zig");
const message = @import("../message.zig");

pub extern var ThreadTail : thread.OSThread;
pub extern var RunningThread : *thread.OSThread;
pub extern fn EnqueueAndYield(q: *?*thread.OSThread) void;
pub extern fn PopThread(q: *thread.OSThread) void;

const thread = @import("os_thread.zig");

pub const OSMesg = ?*anyopaque;

const OSMesgQueue = struct {
    mtqueue: union {pp: **thread.OSThread, p: *thread.OSThread,},
    fullqueue: union {pp: **thread.OSThread, p: *thread.OSThread,},
    validCount : i32,
    first : i32,
    msgCount : i32,
    msg : *OSMesg,
};

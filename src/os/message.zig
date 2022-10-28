const thread = @import("thread.zig");
const interrupt = @import("interrupt.zig");

pub const OSMesg = ?*anyopaque;
pub const OSEvent = u32;
pub const NUM_EVENTS : u32 = 15;
pub const Events = enum {
    SW1,
    SW2,
    CART,
    COUNTER,
    SP,
    SI,
    AI,
    VI,
    PI,
    DP,
    CPU_BREAK,
    SP_BREAK,
    FAULT,
    THREADSTATUS,
    PRENMI,
};

pub const OSMesgQueue = struct {
    mtqueue: union {pp: *?*thread.OSThread, p: ?*thread.OSThread,},
    fullqueue: union {pp: *?*thread.OSThread, p: ?*thread.OSThread,},
    validCount : u32,
    first : u32,
    msgCount : u32,
    msg : [*]OSMesg,
};

pub const blockflag = enum {
    BLOCK,
    NOBLOCK,
};

// extern void     osCreateMesgQueue(OSMesgQueue *mq, OSMesg *msg, s32 count);
// extern s32      osSendMesg(       OSMesgQueue *mq, OSMesg  msg, s32 flag);
// extern s32      osJamMesg(        OSMesgQueue *mq, OSMesg  msg, s32 flag);
// extern s32      osRecvMesg(       OSMesgQueue *mq, OSMesg *msg, s32 flag);

// /* Event operations */

// extern void     osSetEventMesg(OSEvent e, OSMesgQueue *mq, OSMesg m);

pub fn CreateMesgQueue(mq: *OSMesgQueue, msg: [*]OSMesg, msgCount: u32) void {
    mq.*.mtqueue.pp = &thread.__.ThreadTail.next;
    mq.*.fullqueue.pp = &thread.__.ThreadTail.next;
    mq.*.validCount = 0;
    mq.*.first = 0;
    mq.*.msgCount = msgCount;
    mq.*.msg = msg;
}

pub fn SendMesg(mq: *OSMesgQueue, msg: OSMesg, flag: blockflag) i32 {
    var saveMask : u32 = 0;
    var last : u32 = 0;

    saveMask = interrupt.__.DisableInt();

    while (mq.*.validCount >= mq.*.msgCount) {
        if (flag == blockflag.BLOCK) {
            thread.__.RunningThread.*.state = thread.ThreadState.WAITING;
            thread.__.EnqueueAndYield(&mq.*.fullqueue.p);
        } else {
            interrupt.__.RestoreInt(saveMask);
            return -1;
        }
    }

    last = (mq.*.first + mq.*.validCount) % mq.*.msgCount;
    mq.*.msg[last] = msg;
    mq.*.validCount += 1;

    return 0;
}

pub fn JamMesg(mq: *OSMesgQueue, msg: OSMesg, flag: blockflag) i32 {
    var saveMask : u32 = 0;

    saveMask = interrupt.__.DisableInt();

    while (mq.*.validCount >= mq.*.msgCount) {
        if (flag == blockflag.BLOCK) {
            thread.__.RunningThread.*.state = thread.ThreadState.WAITING;
            thread.__.EnqueueAndYield(&mq.*.fullqueue.p);
        } else {
            interrupt.__.RestoreInt(saveMask);
            return -1;
        }
    }

    mq.*.first = (mq.*.first + mq.*.msgCount - 1) % mq.*.msgCount;
    mq.*.msg[mq.*.first] = msg;
    mq.*.validCount += 1;

    if (mq.*.mtqueue.p.?.*.next != null) {
        thread.StartThread(thread.__.PopThread(&mq.*.mtqueue.pp.?));
    }
    
    interrupt.__.RestoreInt(saveMask);
    return 0;
}

pub fn RecvMesg(mq: *OSMesgQueue, msg: *OSMesg, flags: blockflag) i32 {
    var saveMask : u32 = interrupt.__.DisableInt();

    while (mq.*.validCount == 0) {
        if (flags == blockflag.NOBLOCK) {
            interrupt.__.RestoreInt(saveMask);
            return -1;
        }

        thread.__.RunningThread.*.state = thread.ThreadState.WAITING;
        thread.__.EnqueueAndYield(&mq.*.mtqueue.p);
    }

    if (msg != null) {
        msg.* = mq.*.msg[mq.*.first];
    }

    mq.*.first = (mq.*.first + 1) % mq.*.msgCount;
    mq.*.validCount -= 1;

    if (mq.*.fullqueue.p.*.next != null) {
        thread.StartThread(thread.__.PopThread(&mq.*.fullqueue.p));
    }
    
    interrupt.__.RestoreInt(saveMask);
    return 0;
}

pub export fn boot() void {
    var m : OSMesgQueue = undefined;
    var ms : OSMesg = undefined;

    var msa : [8]OSMesg = undefined;

    CreateMesgQueue(&m, &msa, 8);
    _ = SendMesg(&m, ms, blockflag.BLOCK);
    _ = JamMesg(&m, ms, blockflag.BLOCK);
    _ = RecvMesg(&m, &ms, blockflag.BLOCK);
}

pub const __OSEventState = struct{    
    messageQueue : *OSMesgQueue,
    message : OSMesg,
};

extern var __osShutdown : u32;

pub var __osEventStateTab : [NUM_EVENTS]__OSEventState = undefined;
pub var __osPreNMI : u32 = false;

pub fn SetEventMesg(event: OSEvent, mq: *OSMesgQueue, msg: OSMesg) void {
    var saveMask : u32 = interrupt.__.DisableInt();
    var es : *__OSEventState = &__osEventStateTab[event];

    es.*.messageQueue = mq;
    es.*.message = msg;

    if (event == Events.PRENMI) {
        if (__osShutdown and !__osPreNMI) {
            SendMesg(mq, msg, blockflag.NOBLOCK);
        }
        __osPreNMI = true;
    }

    interrupt.__.RestoreInt(saveMask);
}


const thread = @import("../../include/os_thread.zig");
const mesg = @import("../../include/os_message.zig");

// extern void     osCreateMesgQueue(OSMesgQueue *mq, OSMesg *msg, s32 count);
// extern s32      osSendMesg(       OSMesgQueue *mq, OSMesg  msg, s32 flag);
// extern s32      osJamMesg(        OSMesgQueue *mq, OSMesg  msg, s32 flag);
// extern s32      osRecvMesg(       OSMesgQueue *mq, OSMesg *msg, s32 flag);

// /* Event operations */

// extern void     osSetEventMesg(OSEvent e, OSMesgQueue *mq, OSMesg m);

pub export fn osCreateMesgQueue(mq: *mesg.OSMesgQueue, msg: *mesg.OSMesg, msgCount: i32) void {
    mq.*.mtqueue.pp = &thread.__osThreadTail.next;
    mq.*.fullqueue.pp = &thread.__osThreadTail.next;
    mq.*.validCount = 0;
    mq.*.first = 0;
    mq.*.msgCount = msgCount;
    mq.*.msg = msg;
}

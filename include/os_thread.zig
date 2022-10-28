pub const OSPri = i32;
pub const OSId = i32;
const __OSfp = union {
    f : struct {
        f_odd : f32,
        f_even : f32,
    },
    d : f64,
};

const __OSThreadContext = struct {
    at : u64, v0 : u64, v1 : u64, a0 : u64, a1 : u64, a2 : u64, a3 : u64,
    t0 : u64, t1 : u64, t2 : u64, t3 : u64, t4 : u64, t5 : u64, t6 : u64, t7 : u64,
    s0 : u64, s1 : u64, s2 : u64, s3 : u64, s4 : u64, s5 : u64, s6 : u64, s7 : u64,
    t8 : u64, t9 : u64,                     gp : u64, sp : u64, s8 : u64, ra : u64,
    lo : u64, hi : u64,
    sr : u32, pc : u32, cause : u32, badvaddr : u32, rcp : u32,
    fpcsr : u32,
    fp0  : __OSfp, fp2  : __OSfp, fp4  : __OSfp, fp6  : __OSfp,
    fp8  : __OSfp, fp10 : __OSfp, fp12 : __OSfp, fp14 : __OSfp,
    fp16 : __OSfp, fp18 : __OSfp, fp20 : __OSfp, fp22 : __OSfp,
    fp24 : __OSfp, fp26 : __OSfp, fp28 : __OSfp, fp30 : __OSfp,
};

const __OSThreadprofile = struct {
    flag : u32,
    count : u32,
    time : u64,
};

pub const OSThread = struct {
    next : *OSThread,
    priority : OSPri,
    queue : **OSThread,
    tlnext: *OSThread,
    state : u16,
    flags : u16,
    id : OSId,
    fp : i32,
    thprof : *__OSThreadprofile,
    context : __OSThreadContext,
};

pub extern var __osThreadTail : OSThread;
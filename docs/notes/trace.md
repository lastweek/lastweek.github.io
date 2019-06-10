# Linux Tracing

Some general notes about the various tracers inside Linux kernel.

Link to my old notes about the profilers/tracers in LegoOS: [notes](http://lastweek.io/lego/kernel/profile/).
The [profile points](http://lastweek.io/lego/kernel/profile_points/),
which is able to profile arbitray code piece is still my favorite thing.

In Linux kernel, we have:

  - ftrace
  - kprobe
  - uprobe
  - perf_event
  - tracepoints
  - eBPF

I tend to think this way:

  - Tracing needs two parts, `1)` __Mechanims to do callback.__ This means we need a way
    let our tracing/profiling code got invoked on a running system. This can be static
    or dynamic. Static means we added our tracing code to source code, like tracepoints.
    Dynamic means we added our tracing code when system is running, like ftrace and kprobe.
    `2)` __Do stuff within callback.__ All of them provide some sort of handling. But eBPF is the
    most extensive one.
  - `ftrace`, `kprobe`, and `perf_event` implements the callback facilities.
    For example, ftrace has the `call mount` way to do callback on function invocation.
    kprobe dynamically patch instructions and to do callback within exception handlers.
  - The blog from Julia explains it well: [Linux tracing systems & how they fit together](https://jvns.ca/blog/2017/07/05/linux-tracing-systems/)

`ftrace`:

  - Mechanism
    - For each un-inlined function, gcc inserts a `call mcount`, or a `call fentry`
    instruction at the very beginning. This means whenever a function is called,
    the `mcount()` or the `fentry()` callback will be invoked, and they will be
    able to do some bookkeeping.
    - Having these `call` instructions introduce a lot overheads. So by default kernel
    replace `call` with `nop`. Only after we `echo something > setup_filter_functions`
    will the ftrace code replace `nop` with `call`.
    - You can do a `objdump vmlinux -d`, and able to see the following instructions for
    almost all functions: `callq  ffffffff81a01560 <__fentry__>`.
    - x86 related code: `arch/x86/kernel/ftrace_64.S`, `arch/x86/kernel/ftrace.c`
  - Resources
    - [ftrace internal from Steven](https://blog.linuxplumbersconf.org/2014/ocw/system/presentations/1773/original/ftrace-kernel-hooks-2014.pdf)

`kprobe`:

  - Mechanism
    - Kprobe replaces the original assembly instruction with a int3 trap instruction.
      So when we ran into the original instruction, a int3 CPU exception will happen.
      Within `do_in3()`, kernel will callback to core kprobe layer to do pre-handler.
      After singlestep, CPU have debug exception. Kernel walks into `do_debug()`,
      where kprobe run post-handler.
    - Kprobe is powerful, because it's able to trace almost everything at instruction level.
    - Kprobe can NOT touch things inside `entry.S`. It needs a valid `pt_regs` to operate.
  - Resources
    - [An introduction to kprobes (LWN)](https://lwn.net/Articles/132196/)

`eBPF`:

  - Mechanism
    - I think the most important thing is to understand what's the relationship between
    eBPF and the others.
    - Part I: Hook. eBPF attach its program to kprobe/uprobe/ftrace/perf_event.
    You can think eBPF of __a generic callback layer__ for kprobe/uprobe/ftrace/perf_event.
    It's essentially the second part of tracing as we mentioned above.
    - Part II Run: eBPF run program when the above hook got invoked. eBPF is event-driven.
    The program can be user-written eBPF code. Other articles explained it well.
  - Resources
    - [Brendan D. Gregg Blog](http://www.brendangregg.com/index.html)
    - [Bcc](https://github.com/iovisor/bcc)

--  
Yizhou Shan  
Created: Jun 10, 2019  
Last Updated: Jun 10, 2019

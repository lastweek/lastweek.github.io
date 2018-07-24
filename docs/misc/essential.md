# System Developing Essentials

## Tools

- Stack and Register Dumper
- Software Watchdog
- NMI Watchdog
- Tracepoint and Ring Buffer
- Profilers
- Counters
- Whiskey
- Luck

## Keep in mind

- __Stress your system__
    - Every single critical subsystem
    - Confident with your base subsystem
    - Fix bug/Improve perf at early stage
- __Plan ahead__
    - Single thread, or thread pool?
    - How to avoid using `lock`?
    - What lock to use?
    - How to reduce `lock contention`?
    - Does this data structure need `reference counter`?
    - Should I use per-cpu data structures?
    - Should I pad this lock $-line aligned to avoid pingpong?
- __Decent Cleanup__
    - I fucking hate a crap kernel module just kill my machine, either stuck or bug.
    - Free buffer/structure
    - Remove the __pointer__ from friends' list/tree. If you forgot to do so, mostly you will have some silent memory corruption. So be kind, cleanup what you have done during intilization.
    - Report error. Do not be SILENT.

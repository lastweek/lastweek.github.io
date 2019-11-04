# System Developing Essentials

## Misc Advice

- [Elevator Pitches, John Wilkes](http://conferences.inf.ed.ac.uk/EuroDW2018/keynotes/John-Wilkes-Keynote.pdf)
- [Creating an effective poster, John Wilkes](https://docs.google.com/document/d/1gkUWgYMQ37kJ-Bu4wmcEi7x30ZEnmRw99ZMSUhZcQtI/edit)
- [How to Get a Paper Accepted at OOPSLA](https://plg.uwaterloo.ca/~migod/research/beckOOPSLA.html)

## Tools

- Stack and Register Dumper
- NMI and software Watchdog
- Tracepoint and Ring Buffer
- Profilers
- Counters
- Whiskey and Luck

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
    - I'm fucking hate a crap kernel module just kill my machine, either stuck or bug.
    - Free buffer/structure
    - Remove the __pointer__ from friends' list/tree. If you forgot to do so, mostly you will have some silent memory corruption. So be kind, cleanup what you have done during intilization.
    - Report error. Do not be SILENT.

- __Clever Buffer Management__
    - kmem_cache?
    - static pre-allocated array?
    - Ring buffer?
    - Other than kmem_cache, I used other two solutions to optimize various dynamic allocation in LegoOS. The motivation is very simple: some data structures will be allocated/free very very frequently at runtime. So we want to speed it up!

## System Building Advice

- [John Ousterhout](http://web.stanford.edu/~ouster/cgi-bin/sayings.php)
    - If you don't know what the problem was, you haven't fixed it
    - If it hasn't been used, it doesn't work

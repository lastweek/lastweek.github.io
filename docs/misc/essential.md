# System Developing Essentials

## Tools

- Stack and Register Dumper
- Software Watchdog
- NMI Watchdog
- Tracepoint and Ring Buffer
- Profilers
- Whiskey
- Luck

## Keep in mind

- __Stress__ your system
    - Every single critical subsystem
    - Confident with your base subsystem
    - Fix bug/Improve perf in early stage
- Plan ahead
    - Single thread, or thread pool?
    - How to avoid use `lock`?
    - What lock to use?
    - How to reduce `lock contention`?
    - Does this data structure need `reference counter`?

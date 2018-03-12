# wait4(), waitid(), and exit()

Lego supports `wait4()` and `waitid()` syscalls, and they are compatible with Linux programs. These two syscalls rely on `exit_notify()` function when a thread `exit()`. Basically, when a thread exit, it will notify its parent, and reparent[^3] its children if necessary.

Facts in Lego:

- Lego does not have __process group and session__[^2] concept. Each process is within its own process group and session.
- This implies Lego will not have __Orphaned Process Group__[^1] when a process exit.
- __Orphan process__[^3] is adopted by init process (pid 1) if its father is a single-thread process, otherwise it will be adopted by other thread within its father's process. This is performed by function `forget_original_parent()`.
- wait, signal, exec, fork are close related.

[^1]: [Orphaned Process Groups](https://www.gnu.org/software/libc/manual/html_node/Orphaned-Process-Groups.html)
[^2]: [Process Group](https://en.wikipedia.org/wiki/Process_group)
[^3]: [Orphan Process](https://en.wikipedia.org/wiki/Orphan_process)

--  
Yizhou Shan  
Created: Mar 8, 2018  
Last Updated: Mar 10, 2018

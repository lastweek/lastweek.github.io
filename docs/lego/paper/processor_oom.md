# Process/Memory Kernel Memory

This document is based on discussion with Yiying, about how to deal with processor or memory component's out-of-kernel-memory situation. It mainly bothers processor component, which has a small kernel memory while needs to support all running user threads.

Process's local kernel memory is limited by design. There are several major users:

- 1) pcache's rmap, which is propotional to pcache size.
- 2) IB, which depends on concurrent outgoing messages.
- 3) running threads. For each thread at processor, Lego needs to allocate some kernel memory for it, e.g, `kernel stack`, `task_strcut`, and so on.

Both 1) and 2) are fine, they can be easily controlled. However we can not limit how many threads user can create, thus 3) becomes the critical criminal of oom.

When processor is running out of kernel memory, Lego needs to deal with it. Currently, we propose three different solutions:

- s1) `Swap` kernel memory to remote memory component
- s2) `Kill` some threads to have some usable memory (OOM killer)
- s3) `Migrate`, or `checkpoint`, threads to processors that have usable kernel memory

For solution 3), there is a case where `all` processors are running out of memory. Then we have to use solution 1) or 2).

--  
Yizhou Shan  
Feb 17, 2018

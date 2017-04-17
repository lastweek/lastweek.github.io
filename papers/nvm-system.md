# Systems on NVM
Collected by `Yizhou` <shan13@purdue.edu>  
First line is a five star rating, range from [1:5]

## NOVA: A Log-structured File System for Hybrid Volatile/Non-volatile Main Memories, FAST'16
- 4
- Yet another filesystem. Just a student and the professor, he must have done a
lot of work, hats off to him.
- What is new here? As its name, a LSF fs and use a lot of optimizations to
improve performance. The paper also talk about how to ensure ordering (DUH),
and they use the clwb and pcommit way (old-fashioned, huh?). And the paper
has a VERY GOOD summary about previous NVM filesystems, e.g. BPFS, PMFS.
- Quotes from the paper which I think are good:
- Providing strong consistency guarantees is particularly challenging for
memory-based file systems because maintaining data consistency in NVMM can be
costly. Modern CPU and memory systems may reorder stores to memory to improve
performance, breaking consistency in case of system failure. To compensate, the
file system needs to explicitly flush data from the CPU’s caches to enforce
orderings, adding significant overhead and squandering the improved performance
that NVMM can provide
- Disks provide atomic sector writes and processors guarantee only that 8-byte
(or smaller), aligned stores are atomic. To build the more complex atomic
updates that file systems require, programmers must use more complex techniques
such as: Journaling (WAL), Shadow paging, Log-structuring.

## WORT: Write Optimal Radix Tree for Persistent Memory Storage Systems, FAST'17
- 4
- Interesting, first time reading a paper about data structures in PM.
- This paper is first to port Radix Tree to PM.
- Indexing data structures like B-tree is built as disk-based indexing,
arbitrary changes to a volatile copy of a tree node in DRAM can be made without
considering memory write ordering because it is a volatile copy and its
persistent copy always exists in disk storage and is updated in disk block
units. However, with failure-atomic write granularity of 8 bytes in PM, changes
to an existing tree node must be carefully ordered to enforce consistency and
recoverability. Existing B-tree papers in PM: NVTree, wB+Tree, and FPTree.
- Damn it! Learn data structures! -:(

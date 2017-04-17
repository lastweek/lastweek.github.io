# Data structures in PM

## WORT: Write Optimal Radix Tree for Persistent Memory Storage Systems, FAST'17
- 4
- This paper is the first to port Radix Tree to PM.
- Indexing data structures like B-tree is built as disk-based indexing,
arbitrary changes to a volatile copy of a tree node in DRAM can be made without
considering memory write ordering because it is a volatile copy and its
persistent copy always exists in disk storage and is updated in disk block
units. However, with failure-atomic write granularity of 8 bytes in PM, changes
to an existing tree node must be carefully ordered to enforce consistency and
recoverability. Existing B-tree papers in PM: NVTree, wB+Tree, and FPTree.
- Damn it! Learn data structures! -:(

## Failure-Atomic Slotted Paging for Persistent Memory, ASPLOS'17
- 4
- The `slotted-page structure` is a database page format commonly used for
managing variable-length records. This paper develop a failure-atomic
slotted-page structure for PM. Two key elements: (i) `in-place commit` per
page using `hardware transactional memory` (e.g. Intel's HTM) and (ii)
slot-header logging that logs the commit mark of each page (when involve
multiple papers, which can not be updated atomically by the in-place commit).
- Leverage the Hardware Transactional Memory from hardware. Hmm, we need to
think about this too.

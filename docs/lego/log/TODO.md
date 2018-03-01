# TODO

- `vDSO`: if later we find applications are using `gettimeofday`, `time`, and `getcpu` a lot, and it truly hurt performance, then we should consider adding this in the processor side. (Check Processor Loader document for code that needs to be patched). (02/27/18)

- `VA randomization`: our loader does not add any randomization. For security reasons, we probably want to add this.

- `VM Organization`: multiple vm choice at M side, on a per-vma basis.

- `fork: dup free pool`: duplicate the free VA pool at both P and M.

- `pcache`: send each page's type back. something like PcacheAnon, PcacheFile. So the pcache_evict/do_exit routine can be optimized.

- `mm alloc`: don't use the kmalloc to get a new mm_struct. This is a hot data structure, use get_free_page instead maybe. Like task_struct.

- `fork_dup_pcache`: have real vm_flags to guide write-protect. Get vm ranges from memory to optimize the duplication.

- `P side mm sem`: check if we need the sem in P side. pgfault need read, fork and others need W. Even though M side also serialize this, but  out ops are divided.

- `mprotect`: it is empty now. We assume applications are well-written. But does any of them rely on this COW feature?

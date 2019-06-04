# Userfaultfd

(Notes based on linux 5.2-rc3)

- Code Layout
	- Major file: `fs/userfaultfd.c`, which has all the functions and callbacks.
	- Callers spread across: `mm/memory.c`, `mm/mremap.c`, `mm/mmap.c`, and some others.
	- The userfaultfd code is not that hard to understand if you already know how waitqueue etc work. It's built center around the `file_ops`, and couple callbacks for mm.
- `handle_userfault()`, called by `mm/memory.c`:
	- Userfaultfd callback only happens for anonymous pgfault
	- __Userfaultfd skip all the LRU, rmap, cgroup__
	- Userfaultfd does not use the shared global zero page
- `userfaultfd_unmap_prep(), userfaultfd_unmap_complete()`, called by `mm/mmap.c`, and `mm/mremap.c`:
	- Userfaultfd got notified if there are remap and unmap
	- Userfaultfd deliver events via `userfaultfd_event_wait_completion()`
	- I found code in mmap.c and mremap.c is NOT skipping rmap/lru code. Since userfaultfd related pages don't have these setup during pgfault, I think those rmap/lru cleanup code will notice this and handle it well. __In conclusion, userfault skip the expansive rmap/lru setup/teardown.__

- Why userfaultfd?
	- At first developed to enhance VM migration: after migration, the destination QEMU can handle pgfault and bring pages from remote via network.
	- Some databases also use it to have customized feature: http://tech.adroll.com/blog/data/2016/11/29/traildb-mmap-s3.html
	- My thought? The ideal use case is very similar to we did in Hotpot: get the faulting user address, and fetch it from remote. Due to kernel limitations and security constraints, the userfaultfd has to go through many layers and multiple kernel/user crossing. It would be interesting to use user eBPF code to handle pgfault.



--  
Yizhou Shan  
Created: Jun 4, 2019 (8964)  
Last Updated: Jun 4, 2018

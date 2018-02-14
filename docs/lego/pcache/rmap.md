# Reverse Mapping of Pcache

This document explains Lego's reverse mapping design for pcache. We also present Lego internal functions that eventually manipulate rmap data structures.
For readers who are not familiar with reverse mapping, I recommend you search _what is rmap in Linux_ first.

## Design
The reverse mapping, or rmap, of our pcache is implemented in a very basic and
straightforward way: pointing back to all page table entries (ptes) directly.
Shared pcache lines will have a list of ptes that point to this pcache line.
We also did this way in Hotpot.

rmap is used by __1)__ a bunch of syscalls, such as `fork()`, `execv()`, `mmap()`,
`munmap()`, `mremap()`, `brk()`. __2)__ page reclaim, which needs to unmap all ptes for a
given swapped page. Other than `fork()` and `execv()`, other vm related syscalls
are invoked very frequently for a typical datacenter application. Moreover, page
reclaim and swap also run concurrently to gain exclusive access to rmap.

So, rmap operations have to be fast. Directly pointing to pte seems the best
solution here. However, this fine-granularity design will consume a lot memory
for the per-pte list.
Furthermore, vma creation, deletion, split and merge happen frequently, the overhead
to manage rmap is quite high. No wonder Linux choses another object-based way to do so,
which leverages vma itself to take a longer path towards pte.

The important question is: *does this naive solution fit __current__ Lego?*

Yes, it fits, for several reasons. __1)__ Current Lego run static-linked ELF binary only,
thus there will not be any shared hot library pages, which implies rmap list maintenance
is simplified. __2)__ Our targeted applications
mostly are single process. Even for multiple process ones, the number of processes
stay stable and `fork()` happen at early init time. __3)__ major users of rmap such
as `mremap()` and `munmap()`  perform rmap operation explicitly, `mmap()` perform
rmap implicitly via pgfault (or pcache miss), `pcache reclaim` perform sweep async.
All of them, combined with 1) and 2), most of the time will perform rmap operation
on a single pte.

## Internal

The following table describes different contexts that manipulate rmap data structures. Currently, rmap only has four possible operations. The context field describes the large context that trigger such rmap operation. The related functions and pcache callback field lists functions that actually did the dirty work.

| rmap operation | Context | Related functions and pcache callback |
|-|-|-|
| Add | `fork()` <br>`pgfault` | `copy_pte_range()` -> `pcache_copy_pte()` <br> `pcache_add_rmap()`|
| Remove | `munmap()` <br> `exit_mmap()` | `zap_pte_range()` -> `pcache_zap_pte()`|
| Update | `mremap()`| `move_ptes()` -> `pcache_move_pte()`|
| Lookup | pcache eviction sweep, etc.| `pcache_referenced()`, `pcache_wrprotect()` <br> `pcache_try_to_unmap()` |

## Thought

One function I personally love the most is `rmap_walk()`, whose name pretty much tells the story. To use `rmap_walk()`, caller passes a `struct rmap_walk_control`, which including caller specific callback for each rmap. This function also isolates the specific data structures used by rmap from various callers. In Lego, a lot pcache functions are built upon `rmap_walk()`.

`struct rmap_walk_control`, or `struct scan_control`, or `struct something_control` are used a lot by Linux kernel. Personally I do love this way of doing data structure walk, or reuse functions. However, even this way can greatly reduce duplicated code size, it will make the code unnecessary complex. As a system developer, no more expects to see a function longer than 100 lines. People love saying: *Do one thing and do it better*, while it not always works that perfectly. Coding is nothing different life, it is all about trade-off.

--  
Yizhou Shan  
Feb 02, 2018

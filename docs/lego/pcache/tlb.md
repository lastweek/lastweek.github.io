# TLB Coherence

x86 does not keep TLB coherent across cores, nor with in-memory page table. And that is why we need explicit TLB flush when some PTE modifications happen (e.g. downgrade RW to RO, clear PTE, etc.). Besides, TLB flush is very important and affect application correctness. I've had some really awful debugging experience which was eventually introduced by missed TLB flush. Below is a list of operations that should have TLB flush followed:

- `munmap` (optional, can be optimized by holding the old VA range)
- `mremap` (required)
- `fork (RW->RO)` (required)
- `CoW (RO->RW)` (required)
- `mprotect` (required)
- `migration` (required)

Unfortunately, TLB flush is costly, especially if we need to shootdown TLB entries on remote core. TLB shootdown[^1][^2][^3] is performed by sending IPI to remote core, and remote core will flush local TLB entries within its handler. Linux optimize this by batching TLB flush until context switch happens. Lego currently does not have this nice feature, we flush TLB one by one for each PTE change (listed as {==TODO==}).

--  
Yizhou Shan  
Created: Mar 19, 2018  
Last Updated: Mar 19, 2018

[^1]: [Optimizing the TLB Shootdown Algorithm with Page Access Tracking, ATC'18](https://www.usenix.org/conference/atc17/technical-sessions/presentation/amit)
[^2]: [LATR: Lazy Translation Coherence, ASPLOS'18]()
[^3]: [Hardware Translation Coherence for Virtualized Systems, ISCA'17](https://dl.acm.org/citation.cfm?id=3080211)

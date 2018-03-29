# Virtual Cache

- Reading the `GPU virtual cache ASPLOS'18` paper today. I mostly interested in how they handle synonymous and mremap issue.
    - Synonymous:
    - Their solution for synonymous is quite simple (not sure if practical or effective): use a `leading` virtual address, which is the first VA that has the virtual cache miss. Subsequent misses that from `different` VA will not have the their cache lines filled, instead, they will make subsequent VA forever miss, and fetch the content from the leading VA cache line (they call it replay). In all, synonymous is solved by only having one cache line, and does not fill other VA cache lines.
    - mremap:
    - They did not mention mremap. But I guess they do not need to care this. When remap happens, the original PTE is invalidated first, and TLB shootdown follows, all they need to do is to invalidate the virtual cache line (need to be flushed back to memory if dirty). When the new VA mapping established and accessed, it will be a normal virtual cache miss
    - OVC also does not need to care about this because they are doing a similar way (I guess).
    - Lego need to handle mremap differently. Because we don't want to flush the dirty line back to memory, to save 1) one clflush, 2) another pcache miss. This means Lego wants to keep the content in Pcache. So the set_index of new VA and old VA matters in our case.

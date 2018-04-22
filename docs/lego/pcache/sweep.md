# Pcache Sweep

Some notes while coding pcache sweep thread. The sweep thread wants to detect the hotness of pages, and then adjust LRU list accordingly.

## Data Worth a Billion

Pcache-reclaim, or any other object reclaim, need some __data__ to algorithm about. So specific algorithm can select the `best` candidate to reclaim. In reality, algorithms are designed quite well, but __how to get the data__ part becomes extremely hard. I think this applies to many different systems.

For example, to select the hot pages in x86 is notorious hard because x86 hardware only provides a `Referenced` bit for system software to reason about. To make it worse, `Referenced` bit is cached in TLB, which means CPU will _NOT_  set the `Referenced` bit even you reset in PTE, because CPU think the bit is already set. In order to get an _accurate_ hot pages tracking, you probably need a TLB flush after reset `Referenced` bit. But, are you kidding me, a TLB flush after each reset? We have to say NO here. The Linux code explains it well:
```c
static inline int ptep_clear_flush_young(pte_t *ptep)
{
        /*
         * On x86 CPUs, clearing the accessed bit without a TLB flush
         * doesn't cause data corruption. [ It could cause incorrect
         * page aging and the (mistaken) reclaim of hot pages, but the
         * chance of that should be relatively low. ]
         *
         * So as a performance optimization don't flush the TLB when
         * clearing the accessed bit, it will eventually be flushed by
         * a context switch or a VM operation anyway. [ In the rare
         * event of it not getting flushed for a long time the delay
         * shouldn't really matter because there's no real memory
         * pressure for swapout to react to. ]
         */
        return ptep_test_and_clear_young(ptep);
}
```

## Aggressiveness

An aggressive sweep algorithm will disturb the normal operations a lot. In Lego, there 4 main factors that define the aggressiveness:

- Time interval between each run
- Number of sets to look at during each run
	- Skip if it is not full
	- Skip if it is under eviction
- Number of lines to look at for each set
	- Smaller or equal to associativity
- Number of lines to adjust for each set
	- Smaller or equal to lines to look at

--  
Yizhou Shan  
Created: Mar 18, 2018  
Last Updated: Mar 18, 2018

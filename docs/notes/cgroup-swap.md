# How cgroup Trigger SwAp

Notes on how cgroup mm triggers swap on a user-defined `limit_in_bytes`.
This notes assume you have adequate knowledge on overall linux mm code.
For more information about cgroup in general, please check the [document from RedHat](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/resource_management_guide/ch01).

There are several cgroup callbacks at `mm/memory.c`. Those functions are called to check if cgroup can honor this page allocation.
All of these functions are located in `mm/memcontrol.c`

- `mem_cgroup_try_charge()`
- `mem_cgroup_commit_charge()`
- `mem_cgroup_cancel_charge()`

Some *facts* about the implementation (up to linux 5.2)

- Each memory cgroup has its own LRU list vector
- All memory cgroup's LRU lists and even the global LRU lists, they share a global LRU lock on a per-node basis. (Weird! Why?).

Take a closer look of `mem_cgroup_try_charge()`, whose behavior is actually
quite similar to the case of a real OOM: check if we still available
memory (here means memory usage is smaller than `limit_in_bytes`),
if unfortunately we run out of memory, it will then try to reclaim
form the memory cgroup's LRU lists. If that did not work either,
final step would be do OOM actions.

- `mem_cgroup_try_charge()`
    - `try_charge()`
        - page_counter_try_charge():
            - Check if we hit `limit_in_bytes` counter.
            - Hierarchically charge pages, costly.
        - try_to_free_mem_cgroup_pages()
            - Callback to `mm/vmscan.c` to shrink the list (*Bingo!*)
	    - Also, reclaimer will establish swap pte entries
        - mem_cgroup_oom()

- `mem_cgroup_lruvec()`
	- Other than the global zone-wide LRU lists vector, each cgroup has its own LRU lists vector.
	Choose the vector that will be passed down to do `shrink_page_list()` etc.

## LRU Lists Maintainence

Insertion to LRU lists is performed as follows: first, it will be inserted into a
per-cpu array (`lru_add_pvec`). Once the array is full (default 15 entries),
it will do a batch insertion into proper LRU lists (depends on `mem_cgroup_lruvec` we mentioned above).

Why Linux is doing this way? To scale.

--  
Yizhou Shan  
Created: Dec 3, 2018  
Last Updated: Jul 30, 2019

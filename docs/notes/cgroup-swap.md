# swap with cgroup

Notes on how cgroup mm triggers swap on a user-defined `limit_in_bytes`.
This notes assume you have adequate knowledge on overall linux mm code.

There are several cgroup callbacks at `mm/memory.c`. Those functions are called to check if cgroup can honor this page allocation.

- `mem_cgroup_try_charge()`
- `mem_cgroup_commit_charge()`
- `mem_cgroup_cancel_charge()`

Okay, now at `mm/memcontrol.c`, the checking and swap code path:

- `mem_cgroup_try_charge()`
	- `try_charge()`
		- `page_counter_try_charge()`: check if we hit `limit_in_bytes` counter
		- `try_to_free_mem_cgroup_pages()`: callback to `mm/vmscan.c` to shrink the list (Bingo!)


- `mem_cgroup_lruvec()`
	- Other than the global zone-wide LRU lists vector, each cgroup has its own LRU lists vector.
	- This function determines which LRU lists vector should be used. The
	chosed one will be passed down to do `shrink_page_list()` etc.
	- That being said, it's all about algorithm, and data structures!
  

--  
Yizhou Shan  
Created: Dec 3, 2018  
Last Updated: Jun 4, 2019

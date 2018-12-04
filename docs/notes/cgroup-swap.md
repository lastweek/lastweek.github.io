# swap with cgroup

Notes on how cgroup mm triggers swap on a user-defined `limit_in_bytes`.

There are several cgroup callbacks at `mm/memory.c`. Those functions are called to check if cgroup can honor this page allocation.

- `mem_cgroup_try_charge()`
- `mem_cgroup_commit_charge()`
- `mem_cgroup_cancel_charge()`

Okay, now at `mm/memcontrol.c`, the checking and swap code path:

- `mem_cgroup_try_charge()`
	- `try_charge()`
		- `page_counter_try_charge()`: check if we hit `limit_in_bytes` counter
		- `try_to_free_mem_cgroup_pages()`: callback to `mm/vmscan.c` to shrink the list (Bingo!)

Of course there are still tons of LRU related code at `mm/memcontrol.c` that I don't understand yet. But I think they are mostly hooks/helpers for vmscan.c. Be careful about shirnk node code now, it has many hooks for cgroup, and I hope you can understand why they are there by now. It's super complex. Although I've implemented swap twice, there are still many tricks I don't get yet.
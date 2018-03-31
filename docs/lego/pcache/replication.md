# Memory Replication

- Keep a single copy of each page in DRAM, with redundant copies on secondary storage such as disk or flash. This makes replication nearly free in terms of cost, and energy usage. But we should consider the extra network cost.

- RAMCloud has two components running on a single machine: `master`, and `backup`. In lego, `master` is the handler running on `Memory`, `backup` is the handler running on `Storage`.

- Because of `dual-Memory solution`, we don't need a hash table from `<pid, user_vaddr>` to objects in log: M1 has its own `<VA-PA>` mapping table, and it will not be updated on replication. M2 does not need to look up.

- RAMCloud use 8MB segment. Logs are first appended within each segment. Each log has different size, depends on the objects being written. Lego is different. Replication is triggered by pcache/victim flush, which means the data is always the size of a pcache line (4KB now). This make things somehow simpler. But other general rules still apply.

--  
Yizhou Shan  
Created: Mar 31, 2018  
Last Updated: Mar 31, 2018

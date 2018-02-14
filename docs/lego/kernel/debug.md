# Debug Facility in Lego

Lego provides several handy debug helpers to ease our coding pain. We category them by layers, namely __1)__ `Core Kernel`, the lowest level of Lego, which is shared by all managers. __2)__ `Processor Manager`, which controls processor components. __3)__ `Memory Manager`, which controls memory components.

## Core Kernel

```C
void dump_pte(pte_t *ptep, const char *reason);
void dump_page(struct page *page, const char *reason);
```
These two helpers will dump a given pte entry or a page. Use this function if you are developing core related to physical memory allocation or pcache.

---

```C
void ptdump_walk_pgd_level(pgd_t *pgd);
```
This debug helper will dump the whole pgtable ranges. Contiguous page table entries that share the same property will be merged together and will be printed once. Use this function if you are developing code related to user page tables.

---

```C
void show_state_filter(unsigned long state_filter, bool print_rq);
void sched_show_task(struct task_struct *p);
void sysrq_sched_debug_show(void);
```
This set of functions are debug helpers for local scheduler. They will print all the tasks running in the system, and detailed information about percpu `runqueue`. Use this set of functions if you are developing code related to scheduler.


## Processor Manager
```C
void dump_pcache_meta(struct pcache_meta *pcm, const char *reason);
void dump_pcache_victim(struct pcache_victim_meta *victim, const char *reason);
void dump_pcache_rmap(struct pcache_rmap *rmap, const char *reason);
void dump_pcache_line(struct pcache_meta *pcm, const char *reason);
```
These functions dump a given pcache line, a victim line, or a given reserve mapping. The last one will print the pcache line content, which generates a lot messages, you are warned. Use these functions if you are developing pcache or victim cache code.


## Memory Manager
```C
void dump_lego_mm(const struct lego_mm_struct *mm);
void dump_vma(const struct vm_area_struct *vma);
```
These two functions are used to dump the virtual address space of a process. Use these functions if you developing process VM related things.

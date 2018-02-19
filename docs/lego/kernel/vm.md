# Process Virtual Memory

## Limits
### Max Number of VMAs
By default, the maximum number of VMAs is: `65530`. It is defined by the following variable:
```c
#define MAPCOUNT_ELF_CORE_MARGIN        (5)
#define DEFAULT_MAX_MAP_COUNT   (USHRT_MAX - MAPCOUNT_ELF_CORE_MARGIN)

int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
```

## Facts

### `munmap` can split vma
`munmap` can create a hole with an existing vma, thus divide one existing vma to two new vmas. Do note that, `munmap` can create hole for both anonymous vma *__and__* file-backed vma.


### `msync()` is not atomic
During `msync()`, pages are being written back to disk one by one (or batched). Consider the case where few pages have been flushed back, while some other few pages are still in the memory. This premature writeback is not atomic and will be affected by failure.

### `msync()` need concurrency control
With a multi-threaded application, does msync() provide the synchronization semantic? The answer is NO. Other threads within the same process are able to write to pages currently under `msync()`. This implies that application need to handle concurrency by themselves, e.g., rwlocks.

# Pcache Configuration

This doc explains what configuration options pcache has, and how to config them properly. Pcache is only enabled in Lego's processor manager and currently it uses DRAM to emulate the last-level cache (or, L4).

# Kconfig
#### CONFIG_MEMMAP_MEMBLOCK_RESERVED
__DEFAULT: Y__

By default, boot command line option `memmap $` will reserve a range of physical memory.
This reserved memory will be marked reserved in e820 table, which
means this range will not be registered into `memblock`. Only memory that has been
registered into `memblock` will be assigned `struct page` with it (both `memblock.memory` and `memblock.reserve` will have). And do note that this part of reserved memory can be mapped as 1GB page at boot time.

In other words, by default (the linux semantic), users need to `ioremap`
the `memmap $` reserved physical memory, and use the returned kernel virtual address afterwards.
And do note that the `ioremap()` only support 4KB mapping.

In Lego, if this option is enabled, the memory marked by `memmap $` will _NOT_ be marked
reserved into e820 table, instead, it will be pushed into `memblock`, which means
it is mapped into kernel direct mapping and has `struct page`.

For those who have done DAX, or NVM related stuff, you must have struggled with
`memmap $`, and complained why it does not have `struct page`, I guess? So here is
the simple code to do so:
```C
if (*p == '@') {
        start_at = memparse(p+1, &p);
        e820_add_region(start_at, mem_size, E820_RAM);
} else if (*p == '#') {
        start_at = memparse(p+1, &p);
        e820_add_region(start_at, mem_size, E820_ACPI);
} else if (*p == '$') {
        start_at = memparse(p+1, &p);

#ifdef CONFIG_MEMMAP_MEMBLOCK_RESERVED
        memblock_reserve(start_at, mem_size);
#else
        e820_add_region(start_at, mem_size, E820_RESERVED);
#endif
```

But why we are having this? Because I think the `direct 1GB mapping` may have
better performance: huge page mapping can truly save us a lot TLB misses. However, the real performance number is unknown.

If unsure, say `Y`.

--  
Yizhou Shan :four_leaf_clover:  
Created: Feb 01, 2018  
Last Updated: Feb 01, 2018

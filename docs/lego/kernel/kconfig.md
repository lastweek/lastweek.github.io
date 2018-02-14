# Lego Kconfig

## Network
- Enable `CONFIG_INFINIBAND`
- Enable `CONFIG_FIT`
- Set `CONFIG_FIT_INITIAL_SLEEP_TIMEOUT`: boot time connection timeout
- Set `CONFIG_FIT_NR_NODES`: number of Lego nodes in this run
- Set `CONFIG_FIT_LOCAL_ID`: current node id
- In `net/lego/fit_machine.c`, modify the `lego_cluster_hostnames` array to match the machines you are using.

- Set `CONFIG_DEFAULT_MEM_NODE` in processor manager
- Set `CONFIG_DEFAULT_STORAGE_NODE` if you are running with storage component.

Network configuration is crucial, please make sure all Lego nodes have consistent configurations. Otherwise the system may panic or fail to connect.

## Processor
- Enable `CONFIG_COMP_PROCESSOR`
     - open `.config`
     - remove line `# CONFIG_COMP_PROCESSOR is not set`
     - close `.config`
     - do `make`, you will see `Configure Lego as processor component (COMP_PROCESSOR) [N/y/?] (NEW)`, select Y
     - Choose default configuration for all new config options
- Enable `CONFIG_USE_RAMFS` if you are not using storage components

## Memory
- Enable `CONFIG_COMP_MEMORY`
    - open `.config`
    - remove line `# CONFIG_COMP_MEMORY is not set`
    - close `.config`
    - do `make`, you will see `Configure Lego as memory component manager (COMP_MEMORY) [N/y/?] (NEW)`, select Y
    - Choose default configuration for all new config options
- Enable `CONFIG_USE_RAMFS` if you are not using storage components
    - Set `CONFIG_RAMFS_OBJECT_FILE`: points to __static-linked__ ELF file that you want to execute.
    - tips: you can put your test code under `usr/` directory, and a simple `make` will compile everything under.

## Run without Storage Component
To run Lego just with one processor component and one memory component, you need to:

- Enable `CONFIG_USE_RAMFS` at both sides. And in memory side, you need to set the `CONFIG_RAMFS_OBJECT_FILE`, which points to the ELF binary you want to test.
- make sure `CONFIG_DEFAULT_MEM_NODE` at processor component is pointing to memory component's node id.

A typical code snippet and configuration would be:
```c
static const char *lego_cluster_hostnames[CONFIG_FIT_NR_NODES] = {
        [0]     =       "wuklab00",
        [1]     =       "wuklab01",
};
```

```
wuklab00 Processor

#
# Lego Processor Component Configurations
#
CONFIG_COMP_PROCESSOR=y
CONFIG_CHECKPOINT=y
CONFIG_MEMMAP_MEMBLOCK_RESERVED=y
# CONFIG_PCACHE_EVICT_RANDOM is not set
# CONFIG_PCACHE_EVICT_FIFO is not set
CONFIG_PCACHE_EVICT_LRU=y
CONFIG_PCACHE_EVICT_GENERIC_SWEEP=y
# CONFIG_PCACHE_EVICTION_WRITE_PROTECT is not set
# CONFIG_PCACHE_EVICTION_PERSET_LIST is not set
CONFIG_PCACHE_EVICTION_VICTIM=y
CONFIG_PCACHE_EVICTION_VICTIM_NR_ENTRIES=8
CONFIG_PCACHE_PREFETCH=y

#
# Processor DEBUG Options
#

#
# Lego Memory Component Configurations
#
# CONFIG_COMP_MEMORY is not set

#
# DRAM Cache Options
#
CONFIG_PCACHE_LINE_SIZE_SHIFT=12
CONFIG_PCACHE_ASSOCIATIVITY_SHIFT=3

#
# General Manager Config/Debug Options
#
CONFIG_DEFAULT_MEM_NODE=1
CONFIG_DEFAULT_STORAGE_NODE=2
CONFIG_USE_RAMFS=y

#
# Networking
#
# CONFIG_LWIP is not set
CONFIG_FIT=y
# CONFIG_FIT_DEBUG is not set
CONFIG_FIT_INITIAL_SLEEP_TIMEOUT=30
CONFIG_FIT_NR_NODES=2
CONFIG_FIT_LOCAL_ID=0
```


```
wuklab01 Memory

#
# Lego Memory Component Configurations
#
CONFIG_COMP_MEMORY=y

#
# Memory DEBUG Options
#
# CONFIG_MEM_PREFETCH is not set

#
# DRAM Cache Options
#
CONFIG_PCACHE_LINE_SIZE_SHIFT=12
CONFIG_PCACHE_ASSOCIATIVITY_SHIFT=3

#
# General Manager Config/Debug Options
#
CONFIG_DEFAULT_MEM_NODE=1
CONFIG_DEFAULT_STORAGE_NODE=2
CONFIG_USE_RAMFS=y
CONFIG_RAMFS_OBJECT_FILE="usr/pcache_conflict.o"

#
# Networking
#
# CONFIG_LWIP is not set
CONFIG_FIT=y
# CONFIG_FIT_DEBUG is not set
CONFIG_FIT_INITIAL_SLEEP_TIMEOUT=30
CONFIG_FIT_NR_NODES=2
CONFIG_FIT_LOCAL_ID=1
```

# Papers about persistency, NVRAM ordering

## Whole-system persistence, ASPLOS 2012
- 3.5

## Kiln, MICRO 2013
- 4
- Use NV caches and NV memory to give a storage transaction interface.
- Support in-place updates instead of any WAL or COW. (Suggestion: Read
NV-heaps and Mnemosyne with this paper)

## Memory Persistency, ISCA 2014
- 5
- **A store**: the cache coherence actions required to make a write (including a
NVRAM write) visible to other processors.
- **A persist**: the action of writing durably to NVRAM.
- Strict Persistency: where the persists ordering is the same as the consistency
order.
- Relaxed Persistency: where the persists ordering can be different from what
consistency model exposes.

## Delegated Persist Ordering, MICRO 2016
- 5
- **Key idea**: A mode that allow volatile execution to proceed ahead of persists.
- E.g. the `pcommit` instruction will block all following memory operations even
if they point volatile memory, therefore stall the CPU. Ideally, the `pcommit`
should only block operations point to non-volatile memory.
- Delegated ordering, wherein ordering requirements are communicated explicitly
to the PM controller, fully **decoupling** PM write ordering from volatile
execution and cache management.
- On the opposite, the Intel's `clwb` and `pcommit`
(`store A; clwb; sfence; pcommit; sfence; store B`) approach, tightly couples
volatile execution and persistent writes, fully expose the latency of the
`clwb` and `pcommit` to the critical path. And most of the time, this latency
can not be overlapped by the OoO processor.

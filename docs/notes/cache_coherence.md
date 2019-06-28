# Cache Coherence

## References

- [The Architecture of the Nehalem Processor and Nehalem-EP SMP Platforms](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.455.4198&rep=rep1&type=pdf), chapter 5.2 Cache-Coherence Protocol for Multi-Processors.
    - This serves an entry-level description about how x86 MESIF works.
- [Appendix I: Large-Scale Multiprocessors and Scientific Applications](https://www.elsevier.com/books-and-journals/book-companion/9780128119051),
  chapter 7 Implementing Cache Coherence.
    - This is probably some most insightful discussion about real implementation of cache coherence.
      With the distributed nature and Network-on-Chip, implementing cache coherence in modern
      processors is no different than implementing a distributed transaction protocol.
    - Cache activities like read miss or write miss have multi-step operations, but they
      need to appear as "atomic" to users. Put in another way, misses are like transactions,
      they have multiple steps but they must be atomic. They can be retried.
    - Having directory for cache coherence will make implementation easier. Because
      the place (e.g., L3) where directory resides can serve as the serialization point.
      They can solve write races.
    - `Home directory controller` and `cache controller` will exchange messages like a set of distributed machines.
      In fact, with NoC, they are actually distributed system.

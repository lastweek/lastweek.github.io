# Cache Coherence

A general collection of resources on cache coherence.
A good understanding of cache coherence is key to implementing locks,
communication channels, and scalable softwares.
I started this when I was having a hard time optimizing lock delegation.

## References

- [NUMA Deep Dive Part 3: Cache Coherency](https://frankdenneman.nl/2016/07/11/numa-deep-dive-part-3-cache-coherency/)
    - By far the BEST blog I've seen on the topic of Intel snoop models! Frank's other articles are also amazing.
    - Intel is using MESIF cache coherence protocl, but it has multiple cache coherence implementations.
      The first one is `Source Snoop` (or `Early Snoop`), which is more like a traditional snoop-based
      cache coherence implementation. Upon miss, the caching agent will broadcast to other agents.
      The second one is `Home Snoop`, which is more like a directory-based cache coherence implementation.
      Upon miss, the caching agent will contact home agent, and then the home agent will send requests
      to other caching agents who have the requested cache line.
      There are other implementations like Cluster-on-Die.
      Intel UPI rid of all this complexity, it is only using directory-based, in the hope to reduce
      cache coherence traffic, which make sense.
- [MESIF: A Two-Hop Cache Coherency Protocol for Point-to-Point Interconnects (2009)](https://researchspace.auckland.ac.nz/bitstream/handle/2292/11594/MESIF-2009.pdf?sequence=6)
    - TODO
- [The Architecture of the Nehalem Processor and Nehalem-EP SMP Platforms](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.455.4198&rep=rep1&type=pdf), chapter 5.2 Cache-Coherence Protocol for Multi-Processors.
    - This serves an entry-level description about how x86 MESIF works.
    - Also this is a very good paper about general x86 microarchitectures.
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

- [An Introduction to the Intel® QuickPath Interconnect](https://www.intel.ca/content/dam/doc/white-paper/quick-path-interconnect-introduction-paper.pdf),
  page 15 MESIF.
      - It explains `Home Snoop` and `Source Snoop` used by Intel.
      - Based on their explanation, it seems both `Home Snoop` and `Source Snoop` are using a combination of
        snoop and directory. The Processor#4 (pg 17 and 18) maintains the directory.
      - And this is a perfect demonstration of the details described in [Appendix I: Large-Scale Multiprocessors and Scientific Applications](https://www.elsevier.com/books-and-journals/book-companion/9780128119051).
      - Related patent: [Extending a cache coherency snoop broadcast protocol with directory information](https://patents.google.com/patent/US20150081977)

## Misc Small Facts

- Intel Caching Agent (Cbox) is per core (or per LLC slice). Intel Home Agent is per memory controller.
    - Starting from Intel UPI, Caching Agent and Home Agent are combined as CHA.
- A good [discussion](https://www.realworldtech.com/qpi-evolved/3/) about why QPI gradually drop `Source Snoop` and solely use `Home Snoop`.
    - The motivation is scalability. It turns out the new UPI only supports directory-based protocol.
    - This makes sense because 1) inter socket bandwidth is precious, 2) snoop will consume a lot bandwidth.
- Intel UPI is using directory-based home snoop coherency protocol
    - [Intel® Xeon® Processor Scalable Family Technical Overview](https://software.intel.com/en-us/articles/intel-xeon-processor-scalable-family-technical-overview)


--  
Yizhou Shan  
Created: Jun 28, 2019  
Last Updated: Jun 28, 2019

# SSD 101

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Nov 20, 2022 | polish a bit, just a bit.  |
	|Nov 15, 2022 | Initial |

**Grab-and-go SSD 101 bullet points for newbies**.

## Basics

### Cell Bits (SLC, MLC, TLC)

- A cell can have 1-bit, 2-bit, 3-bit, or 4-bit saved. [There is a trade-off among these](https://flashdba.com/2014/07/03/understanding-flash-slc-mlc-and-tlc/). SLC has lower-latency and longer lifespan, but is more expensive. Enterprise & Datacenter may prefer SLC for its longer lifespan cena better perf. Consumers may prefer MLC/TLC/QLC.
- A flash cell is a floating gate or a charge trap transistor to represent data by storing certain amount of charges, which determines the threshold voltage (Vth) of the cell.
- Reads
    * [How Flash Memory Works | HowStuffWorks](https://computer.howstuffworks.com/flash-memory.htm)
    * [Understanding Flash: SLC, MLC and TLC | flashdba](https://flashdba.com/2014/07/03/understanding-flash-slc-mlc-and-tlc/) 
    * [Sentinel Cells Enabled Fast Read for NAND Flash](https://www.usenix.org/system/files/hotstorage19-paper-li.pdf) HotStorage’19 

### Parallelism and Packaging

- A NAND package is organized into a hierarchy of **dies**,  **planes**,  **blocks**, and **pages**.
- There may be one or several dies within a single physical package.
- A die allows a single I/O command to be executed at a time.
- A plane allows similar flash commands to be executed in parallel within a die.
- A page is usally 2K, 4K, etc. A block has thousands of pages, could be couple MBs.

### NAND has 3 programming constraints

1. A write command must always contain enough data to program one (or several) full flash page(s)
2. Writes must be sequential within a block
3. An erase must be performed before a page within a block can be (re)written. The number of program/erase (PE) cycles is limited

### FTL Flash Translation Layer

- For historical reasons, the SSDs first appeared with block interfaces.
- But this block interface conflicts with the underlying NAND flash addressing model.
- Hence, a FTL layer is introduced to bridge this gap.
- This abstraction stays.
- But this abstraction has many downsides, especially considering NAND flash's 3 fundamental programming constaints. Many background tasks are needed such as GC. It turns out those activities are the main culprit of SSD performance degradation under intensive workload.
* Why does SSD only support block-level erase rather than page-level erase?
    * Per-page FTL costs more memory than per-block FTL.
    * The electricity/wires required are also less, I guess.
* Reads
    * The ZNS ATC paper has an excellent historical pespective.
    * [Design Tradeoffs for SSD Performance, ATC'08](https://www.usenix.org/legacy/event/usenix08/tech/full_papers/agrawal/agrawal.pdf)
    * [http://www.csc.lsu.edu/~fchen/publications/papers/hpca11.pdf](http://www.csc.lsu.edu/~fchen/publications/papers/hpca11.pdf) 

### Garbage Collection (GC)

* Why GC? Because SSD cells cannot be overwritten once programmed, it must be erased before it can be written again. Every SSD write would write into another block’s page other than the one you originally read data from. The original page is marked as “Stale” subsequently. It is apparent that many pages/blocks become stale gradually, and if no action is taken, the SSD will run out of space. GC mostly runs in the background to recycle such blocks (NOTE: erase happens in block-level granularity). If GC fails to catch up, foreground performance will be bottlenecked by Erase.

### Write Amplification Factor

* The amount of data written by the SSD controller into the NAND flash compared the amount of data written from the host OS.
* The larger the WA, the faster the SSD ages and the worse performance.

### TRIM

* Once you write something into an SSD block, SSD has no way to know whether a block is freed from FS/OS’s perspective. During GC, SSD would still move such “invalid” blocks around to make space. This is wasted effort.
* The **TRIM** command allows OS/FS to notify SSD that certain blocks are freed, hence SSD can erase them and no longer need to maintain them. It is a simple co-design.

### Over-Provisioning (OP)

* I saw: OP 10-15% for normal light workload. OP 25% for write-intensive workloads. Not confirmed
* OP basically allows you to absorb more transient traffic and allows FTL to balance writes across more blocks hence prolong the overall lifespan

### Wear  Leveling

* Wear = Last 持久
* Leveling = 水平
* FTL controller tries to balance the number of P/E cycles made to all SSD blocks, so that most of them age at the same pace. 

### Queue Depth

* TODO

**[NVMe Namespaces](https://nvmexpress.org/resources/nvm-express-technology-features/nvme-namespaces/#:~:text=What%20is%20a%20Namespace%3F,provide%20access%20to%20a%20namespace.)**

* a namespace is a collection of logical block addresses (LBA) accessible to host software. A namespace ID (NSID) is an identifier used by a controller to provide access to a namespace.
* There are many reasons why host software would want to break up an NVMe SSD into multiple namespaces: for logical isolation, multi-tenancy, security isolation (encryption per namespace), write protecting a namespace for recovery purposes, overprovisioning to improve write performance and endurance and so on.
* Namespaces => Zoned Namespaces. Its not a huge leap. The ZNS SSD is much simplified.

### Seq v.s. Random SSD Writes

- From the FTL’s point of view, seq/random NVMe accesses both translate to random blocks accesses.
  As you know, it’s an append-only program in SSD with no write-in-place.
- Whether it is random or sequential, it usually shows during the background operations (i.e. GC).
  When more blocks within the Superblock get trimmed simultaneously
  (which means the host file size is relatively big or you have an SW to arrange a similar type of data as a group),
  this is considered sequential.
  If a few blocks are being trimmed sporadically in the Superblock (which means the host is dealing with small files), then it is considered a random behavior, which brings up the WAF since more LBAs need to get rotated during GC or WL. The performance difference between random and sequential is pretty much coming from these background activities. In addition, if the OP size is small, it gets worse.  

### Open Channel SSD

* Open-Channel SSDs allow host and SSD to collaborate through a set of contiguous LBA chunks
* This eliminates in-device garbage collection overhead and reduces the cost of media over-provisioning and DRAM.
* With OCSSDs, the host is responsible for data placement. This includes underlying media reliability management such as wear-leveling, and specific media failure characteristics.
* This has the potential to improve SSD performance and media lifetime over_ Stream SSDs_, but the host must manage differences across SSD implementations to guarantee durability, making the interface hard to adopt and requiring continual software upkeep.
* Reads
    * [ZNS: Avoiding the Block Interface Tax for Flash-based SSDs, ATC'21](https://www.usenix.org/system/files/atc21-bjorling.pdf)
    * [https://openchannelssd.readthedocs.io/en/latest/](https://openchannelssd.readthedocs.io/en/latest/) 

### Zoned Namespace (ZNS)

* [ZNS: Avoiding the Block Interface Tax for Flash-based SSDs, ATC'21](https://www.usenix.org/system/files/atc21-bjorling.pdf) & [slide](https://www.usenix.org/system/files/atc21_slides_bjorling.pdf)
* The SSD is partitioned into a set of zones.
* Each zone represents a region of the logical address space of the SSD that can be read arbitrarily but must be written sequentially, and to enable new writes, must be explicitly reset.
* Compared to OpenChannel: OC is shifting all management responsibilities to the host, which is burdensome to software. ZNS is different, ZNS disallows random writes but the SSD controller still needs to expose the Zone abstraction and manages the Zone to underlying block/page mapping. The benefit is that SSD can now do coarse-grained mapping. The host does fine-grained mapping and GC. 
* The SSD controller is simpler in response to ZNS. Check The ZNS paper for the HW&SW changes
* This implies that write amplification on the device is eliminated, which eliminates the need for capacity over-provisioning

### Flexible Data Placement (FDP) v.s. ZNS

* [https://nvmexpress.org/wp-content/uploads/Hyperscale-Innovation-Flexible-Data-Placement-Mode-FDP.pdf](https://nvmexpress.org/wp-content/uploads/Hyperscale-Innovation-Flexible-Data-Placement-Mode-FDP.pdf) 
* [https://www.youtube.com/watch?v=R0GHuKwi3Fc](https://www.youtube.com/watch?v=R0GHuKwi3Fc) 
* [https://www.youtube.com/watch?v=ZEISXHcNmSk](https://www.youtube.com/watch?v=ZEISXHcNmSk) 

### AWS Nitro SSD

AWS re:Invent 2021 introduced their AWS Nitro SSD.
There is only limited information about it.

- They onload part of the traditional SSD FTL to a Nitro chip. Which parts are onloaded? I think it should be modules related to GC, wear-leveling etc. 
- Their approach is different from the ZNS/FDP approach although they are doing some sort of data placement in the onloaded FTL.
- They’ve been boasting about their SW upgrades (instead of HW) with nearly zero downtime.
- End to End control requires us to break the strict abstraction/protocol boundaries. And in the SSD world, the FTL is the layer *guarding* the underlying flash. E2E opt should break this boundary, but the question is how much and to what extent. Following this principle, t does not make sense for them to onload the entire FTL to the Nitro SSD - some part of it for E2E opt should be sufficient (the parts like GC, like wear-leveling, i presume). This approach is similar to one taken by Google Aquila. They break the strict protocol boundaries among the network's physical/link/net/transport, allowing the transport to directly instruct link layer packets. And by breaking the protocol boundaries, Google Aquila achieves stable tail latency

### CXL SSD and Smart SSD

- Samsung released their [CXL SSD](https://www.servethehome.com/samsung-memory-semantic-cxl-ssd-at-fms-2022-powered-by-amd-xilinx/) on Aug 2022. From the architecture diagram, we can see that the SSD supports both CXL.io for LBA access and CXL.mem for load/store.
- [Samsung also partered with Xilinx to produce SmartSSD](https://www.servethehome.com/samsung-and-amd-xilinx-launch-2nd-gen-smartssd/), bringing an FPGA into their SSD. The news show the FPGA is used for NDP, encryption etc. Makes sense for them to produce such a combined technology. But noted, this still exposes an traditional NVMe interface, no deep co-design with cloud workloads. 

## Readings

- This is my starting point. This is a 6-blog series and contains almost every detail we’d care about. I recommend reading this. [Coding for SSDs – Part 6: A Summary – What every programmer should know about solid-state drives](https://codecapsule.com/2014/02/12/coding-for-ssds-part-6-a-summary-what-every-programmer-should-know-about-solid-state-drives/) 
- Many recommend this paper as the one which proposed the log-based remapping mechanism. [A Reconfigurable FTL (Flash Translation Layer) Architecture for NAND Flash-Based Applications](https://people.eecs.berkeley.edu/~kubitron/cs262/handouts/papers/a38-park.pdf) 
- Classical reads recommended by everyone
	- [Design Tradeoffs for SSD Performance, ATC'08](https://www.usenix.org/legacy/event/usenix08/tech/full_papers/agrawal/agrawal.pdf)
	- [http://www.csc.lsu.edu/~fchen/publications/papers/hpca11.pdf](http://www.csc.lsu.edu/~fchen/publications/papers/hpca11.pdf) 
	- [WiscKey: Separating Keys from Values in SSD-conscious Storage, FAST'16](https://www.usenix.org/system/files/conference/fast16/fast16-papers-lu.pdf) 
- Jian Huang’s paper [1](https://platformxlab.github.io/papers/flashmap-isca15.pdf) & [2](https://platformxlab.github.io/papers/flashblox-fast17.pdf) 


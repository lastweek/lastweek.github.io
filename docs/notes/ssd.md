# SSD 101

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Nov 15, 2022 | Initial |

Grab-and-go SSD 101 for newbies.

**Cell Bits (SLC, MLC, TLC)**

* A cell can have 1-bit, 2-bit, 3-bit, or 4-bit saved. [There is a trade-off among these](https://flashdba.com/2014/07/03/understanding-flash-slc-mlc-and-tlc/). SLC has lower-latency and longer lifespan, but is more expensive. Enterprise & Datacenter may prefer SLC for its longer lifespan cena better perf. Consumers may prefer MLC/TLC/QLC.
* A flash cell is a floating gate or a charge trap transistor to represent data by storing certain amount of charges, which determines the threshold voltage (Vth) of the cell.
* I like the following diagram & blog. It clearly shows the difference.
* Reads
    * [How Flash Memory Works | HowStuffWorks](https://computer.howstuffworks.com/flash-memory.htm)
    * [Understanding Flash: SLC, MLC and TLC | flashdba](https://flashdba.com/2014/07/03/understanding-flash-slc-mlc-and-tlc/) 
    * [Sentinel Cells Enabled Fast Read for NAND Flash](https://www.usenix.org/system/files/hotstorage19-paper-li.pdf) HotStorage’19 

**Parallelism and Packaging**

* A NAND package is organized into a hierarchy of **dies**,  **planes**,  **blocks **, and **pages**.
* There may be one or several dies within a single physical package.
* A die allows a single I/O command to be executed at a time.
* A plane allows similar flash commands to be executed in parallel within a die.


**There are three fundamental programming constraints that apply to NAND**:

* a write command must always contain enough data to program one (or several) full flash page(s)
*  writes must be sequential within a block
* an erase must be performed before a page within a block can be (re)written. The number of program/erase (PE) cycles is limited

**FTL**

* A cell can have 1-bit, 2-bit, 3-bit, or 4-bit saved. [There is a trade-off among these](https://flashdba.com/2014/07/03/understanding-flash-slc-mlc-and-tlc/). SLC has lower-latency and longer lifespan, but is more expensive.
* A page has many cells.
* A page is usually a couple KBs, like 2KB, 4KB, 8KB, etc.
* A block has hundreds or thousands of pages, like 2MB, 4MB, etc
* Pages cannot be erased individually, only whole blocks can be erased.
* Why does SSD only support block-level erase rather than page-level erase?
    * Per-page FTL costs more memory than per-block FTL.
    * The electricity/wires required are also less, I guess.
* Reads
    * [Design Tradeoffs for SSD Performance, ATC'08](https://www.usenix.org/legacy/event/usenix08/tech/full_papers/agrawal/agrawal.pdf)
    * [http://www.csc.lsu.edu/~fchen/publications/papers/hpca11.pdf](http://www.csc.lsu.edu/~fchen/publications/papers/hpca11.pdf) 

**Garbage Collection (GC)**

* Why GC? Because SSD cells cannot be overwritten once programmed, it must be erased before it can be written again. Every SSD write would write into another block’s page other than the one you originally read data from. The original page is marked as “Stale” subsequently. It is apparent that many pages/blocks become stale gradually, and if no action is taken, the SSD will run out of space. GC mostly runs in the background to recycle such blocks (NOTE: erase happens in block-level granularity). If GC fails to catch up, foreground performance will be bottlenecked by Erase.

**Write Amplification Factor**

* The amount of data written by the SSD controller into the NAND flash compared the amount of data written from the host OS.
* The larger the WA, the faster the SSD ages and the worse performance.

**TRIM**

* Once you write something into an SSD block, SSD has no way to know whether a block is freed from FS/OS’s perspective. During GC, SSD would still move such “invalid” blocks around to make space. This is wasted effort.
* The **TRIM** command allows OS/FS to notify SSD that certain blocks are freed, hence SSD can erase them and no longer need to maintain them. It is a simple co-design.

**Over-Provisioning (OP)**

* I saw: OP 10-15% for normal light workload. OP 25% for write-intensive workloads. Not confirmed
* OP basically allows you to absorb more transient traffic and allows FTL to balance writes across more blocks hence prolong the overall lifespan

**Wear  Leveling**

* Wear = Last 持久
* Leveling = 水平
* FTL controller tries to balance the number of P/E cycles made to all SSD blocks, so that most of them age at the same pace. 

**Queue Depth**

* TODO

**[NVMe Namespaces](https://nvmexpress.org/resources/nvm-express-technology-features/nvme-namespaces/#:~:text=What%20is%20a%20Namespace%3F,provide%20access%20to%20a%20namespace.)**

* a namespace is a collection of logical block addresses (LBA) accessible to host software. A namespace ID (NSID) is an identifier used by a controller to provide access to a namespace.
* There are many reasons why host software would want to break up an NVMe SSD into multiple namespaces: for logical isolation, multi-tenancy, security isolation (encryption per namespace), write protecting a namespace for recovery purposes, overprovisioning to improve write performance and endurance and so on.
* Namespaces => Zoned Namespaces. Its not a huge leap. The ZNS SSD is much simplified.

**Open Channel SSD**

* Open-Channel SSDs allow host and SSD to collaborate through a set of contiguous LBA chunks
* This eliminates in-device garbage collection overhead and reduces the cost of media over-provisioning and DRAM.
* With OCSSDs, the host is responsible for data placement. This includes underlying media reliability management such as wear-leveling, and specific media failure characteristics.
* This has the potential to improve SSD performance and media lifetime over_ Stream SSDs_, but the host must manage differences across SSD implementations to guarantee durability, making the interface hard to adopt and requiring continual software upkeep.
* Reads
    * [ZNS: Avoiding the Block Interface Tax for Flash-based SSDs, ATC'21](https://www.usenix.org/system/files/atc21-bjorling.pdf)
    * [https://openchannelssd.readthedocs.io/en/latest/](https://openchannelssd.readthedocs.io/en/latest/) 

**Zoned Namespace (ZNS)**

* [ZNS: Avoiding the Block Interface Tax for Flash-based SSDs, ATC'21](https://www.usenix.org/system/files/atc21-bjorling.pdf) & [slide](https://www.usenix.org/system/files/atc21_slides_bjorling.pdf)
* The SSD is partitioned into a set of zones.
* Each zone represents a region of the logical address space of the SSD that can be read arbitrarily but must be written sequentially, and to enable new writes, must be explicitly reset.
* Compared to OpenChannel: OC is shifting all management responsibilities to the host, which is burdensome to software. ZNS is different, ZNS disallows random writes but the SSD controller still needs to expose the Zone abstraction and manages the Zone to underlying block/page mapping. The benefit is that SSD can now do coarse-grained mapping. The host does fine-grained mapping and GC. 
* The SSD controller is simpler in response to ZNS. Check The ZNS paper for the HW&SW changes
* This implies that write amplification on the device is eliminated, which eliminates the need for capacity over-provisioning

**Flexible Data Placement (FDP) v.s. ZNS**

* [https://nvmexpress.org/wp-content/uploads/Hyperscale-Innovation-Flexible-Data-Placement-Mode-FDP.pdf](https://nvmexpress.org/wp-content/uploads/Hyperscale-Innovation-Flexible-Data-Placement-Mode-FDP.pdf) 
* [https://www.youtube.com/watch?v=R0GHuKwi3Fc](https://www.youtube.com/watch?v=R0GHuKwi3Fc) 
* [https://www.youtube.com/watch?v=ZEISXHcNmSk](https://www.youtube.com/watch?v=ZEISXHcNmSk) 

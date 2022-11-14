# What is up with CXL?

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Nov 15, 2022 | Small fixes|
	|Jul 17, 2022 | Initial|

## Intro

:sailboat:

Is CXL just another NUMA?

You probably have heared about CXL many times.
And you've probably wondered, what is it, exactly?
And why folks are so excited about it?
This (short) note explains CXL from my own pespective.
In particular, what is it, how to use it, 
what's the current status, and what's next.

DISCLAIMER: I'm no expert in the CXL protocol itself.
I'm just a systems researcher
who may need to compare my systems against CXL-enabled ones.
Hence my thoughts and views could be biased and wrong.
If you are looking for serious CXL specification stuff,
please check out the [official CXL site](https://www.computeexpresslink.org/).

Without further ado, let's get started.

## What is CXL?

CXL is short for Compute Express Link. It has 3 types.
I will focus on *CXL type 3* device, the one used for **memory expansion**.
The CXL hereafter refers to type 3.

Originally CXL was proposed to tame DRAM/PM heterogeneity
and has a framework to maintain cache coherence among accelerators.
CXL is now mainly used in the disaggregated memory scenario.
But was CXL originally designed with the disaggregated memory setting in mind?
I doubt that.

Hence it is interesting to think why CXL has such a successful spin-off.
My take: because CXL was designed for heterogeenous DRAM technologies,
one of its core design principle is to work with different kinds of memory.
Using memory usually requires extremely low latency.
As such, CXL requires a low latency interconnection between
a processing unit (e.g., CPU) and a CXL controller (the one right before memory chips).
This pursuit eventually brings a CPU closer to a device (CXL controller) that is capable of
accessing external resources. It calls for something better/faster than the long-standing PCIe.
And this subsequently enables the disaggregated memory usage.

## How to use CXL?

I think there are two ways to look at CXL,
one from the traditional server angel, and the other from resource disaggregation.
Either way, CXL enables disaggregated memory with extrmely low latency.

**From the traditional server angle**:
CXL allows the CPUs to access remote memory (i.e., memory resides outside the server box)
at extremely low-latency, very much like accessing a NUMA node (could be ~100ns, see the MS arXiv paper).
Since the remote memory is provisioned separately from the servers,
you basically enjoys memory expansive "free". Of course not exactly free, but it is
relatable to NUMA system tuning.

**From the disaggregated memory angle**:
CXL enables another design spectrum in disaggregated memory (DM) systems.
Usually, DM systems access remote memory over RDMA with a few software tricks
at the client side. The tricks include explicit APIs (AIFM, OSDI'20), runtime (Semeru, OSDI'20),
kernel paging (InfiniSwap, NSDI'17). No matter what software is used, the overhead
of accessing disaggregated memory is usually larger than 2-4 us.
The overhead comes from software cost, DMA to RDMA NIC cost, RDMA NIC cost, etc.
CXL brings something new to the table.
At its core, CXL claims a PCIe bus address and allows CPUs to access remote memory
using LD/ST, bypassing all the software and NIC overheads.
The DirectCXL, ATC'22 paper has a nice breakdown.

## What's the status of CXL?

CXL is taking off.

Cloud vendors are pushing it.
Microsoft and Meta have released papers on their in-houst CXL platforms.
Though no hardware is actually evaluated, they are building it.
I remember Meta has CXL FPGAs long time ago.

The whole industry is pushing it.
There are numerous summits hosting CXL tutorials.
The latest being [OCP Global Summit 2022](https://www.opencompute.org/blog/2022-ocp-global-summit-key-takeaways-cxls-implications-for-server-architecture).

## What's next for CXL?

I think there are A LOT to explore. Research wise.
Like concurrency.

## Readings

- First-Gen CXL, arXiv'22.
	- Two contributions. Azure memory standing analysis, and a CXL prototype description.
	- Works for opaque VM. The system is intergrated with cluster-side VM scheduler.
	- No page migration, but VM migration.
	- Has ML-based VM memory usage prediction
	- And runtime QoS monitoring based on PMU countes
	- The paper is accepted to ASPLOS'23 and renamed to Pond.
- TPP, arXiv'22.
	- Two contribtions. Workloads analysis and an enhanced paging system.
	- Works within a normal linux kernel (has user space parts), various improvements on LRU lists etc.
	- Both the MS and TPP paper assume accessing to remote CXL memory is like accessing NUMA nodes, latency runs at around 100ns. Crazy numbers.
- DirectCXL, ATC'22
	- First FPGA prototype.
	- Since they don't have CXL-enabled x86, they use RISC-V.
	- The latency is around 300ns?

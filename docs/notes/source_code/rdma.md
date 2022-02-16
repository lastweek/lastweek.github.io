# On DPDK and RDMA Related Software

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Feb 16, 2021| Some updates on Mellanox RDMA NICs|
	|Dec 14, 2020| More on DPDK|
	|May 28, 2020| Copied from summary|

This note mainly talks about how DPDK interacts with RDMA (libibverbs),
and how libibverbs communicates with the kernel.
I document some misc things about RDMA as well.

## DPDK and RDMA

DPDK leverages [**VFIO**](https://www.kernel.org/doc/Documentation/vfio.txt) to
be able to directly access physical devices in the user space.
Note that QEMU/Firecracker also use VFIO to directly assign devices to guest OSes (i.e., device passthrough mode).

Although both DPDK and RDMA's data path bypass kernel, their *control path* are very different from each other.
For most NIC drivers in DPDK, there are completely self-contained device drivers in the user space,
and these drivers can directly communicate with the hardware device via MMIO (all possible thanks to VFIO).
Specifically, once DPDK has done some VFIO ioctls, all data and control path can bypass kernel. Nice, right？

However, for the `rdma-core`, a lot of the control-path IB verbs (e.g., `create_pd`, `create_cq`)
still communicate with the kernel via ioctl calls on Infiniband related device files.
On the kernel side, the in-kernel uverb hanlders are located in `drivers/infiniband/core/uverbs.c`.
Do note that this is a quite complicated way to build communicatation channels between user and kernel space,
although it is quite efficient. This simple framework is used by several other kernel subsystems, such as `io_uring`.
In details, the control verbs **mmap** some pages between user and kernel,
then all the following data path IB verbs (e.g., `post_send`) could just bypass kernel
and talk to the device via MMIO directly.
Though `rdma-core` also has some vendor-specific
"drivers", this is really different from the above DPDK's userspace PCIe driver.
Userspace "rdma-core" vendor-driver deals with the kernel devel vendor-level driver details (same for the ones inside DPDK).

FWIW, if you are using a Mellanox VPI card in Ethernet mode (e.g. CX3-5),
  DPDK will use its built-in mlx driver, which further use libibverbs,
  which further relies on kernel IB stack. It's not a complete user solution somehow.
  Note that DPDK built-in mlx driver uses RAW_PACKET QPs.

- ![image](../../images/dpdk_ibverbs.png)

### DPDK Internal

Top-down:

- The user-facing part is called [Envionmemt Abstraction Layer (EAL)](https://doc.dpdk.org/guides/prog_guide/env_abstraction_layer.html), which provides a set of portable interfaces among many OSes. We can think it of as a "POSIX" interface. This EAL has quite a lot useful and handy APIs, e.g., multicore support where you can call a function on arbitray cores (like the linux `on_each_cpu` core), timers, atomic operations, memory management APIs. I have built all these components myself, still very pleased to see this.
- Poll Mode Driver - we cover the mlx ones above
- Various other drivers

## RDMA

Below is a list of RDMA-based systems I have used or the ones I think are useful.

For RDMA programming tricks, see this seminal work:
[Design Guidelines for High Performance RDMA Systems, ATC'16](https://www.usenix.org/conference/atc16/technical-sessions/presentation/kalia)

- [Mellanox libvma](https://github.com/lastweek/source-libvma)
	- An userspace IB verbs based layer providing POSIX socket APIs.
	  (The SocketDirect, SIGCOMM'19 paper was building a similar thing).
- [verbs perftest](https://github.com/lastweek/source-verbs-perftest)
	- The collection contains a set of bandwidth and latency benchmark such as:
	- Send        - `ib_send_bw` and `ib_send_lat`
	- RDMA Read   - `ib_read_bw` and `ib_read_lat`
	- RDMA Write  - `ib_write_bw` and `ib_wriet_lat`
	- RDMA Atomic - `ib_atomic_bw` and `ib_atomic_lat`
	- Native Ethernet (when working with MOFED2) - `raw_ethernet_bw`, `raw_ethernet_lat`
- [rdma-core](https://github.com/lastweek/source-rdma-core)
	- This is the core userspace IB verbs library (e.g., libibverbs). Whenever you are writing userspace RDMA applications, you are using this library.
	- It is interesting to learn how userspace IB layer communicates with kernel.
	  It is using `ioctl()` and `mmap()` to do the trick, quite standard.
          Not sure how io_uring would help here.
	  The ABI interface (i.e., data structures) are quite complex and has several versions.
	- `libibverbs/example`
		- asyncwatch.c
		- device_list.c
		- devinfo.c
		- pingpong.c
		- rc_pingpong.c
		- srq_pingpong.c
		- uc_pingpong.c
		- ud_pingpong.c
		- xsrq_pingpong.c
	- `infiniband-diags`
		- ibv_devinfo    
		- iblinkinfo    
		- ibping    
		- ibaddr
	- [Kernel Infiniband stack](https://github.com/torvalds/linux/tree/master/drivers/infiniband)
- RPC
	- [gRPC](https://github.com/lastweek/source-grpc)
	- [eRPC, NSDI'19]()


## RDMA NIC Latest Updates

1. [Mellanox Zero Touch RoCE](https://docs.nvidia.com/networking/display/winof2v220/Ethernet+Network#EthernetNetwork-RoLN).
	-  Came across a thing called Zero Touch RoCE, looks like it essentially is RoCE w/o PFC.
	- Based on the description, ConnectX-6 is actually using Selective Transmission to handle lossy RoCE.
	- This means the IRN, SIGCOOM'19 proposal actually made into production line?!
2. Device Memory.
	- TODO

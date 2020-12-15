# On-RDMA-and-DPDK-Software-Landscape

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Dec 14, 2020| More on DPDK|
	|May 28, 2020| Copied from summary|

## RDMA

Below is a list of RDMA-based systems I have used or the ones I think are useful.

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

## DPDK

### Personal Notes

- [DPDK](https://github.com/lastweek/source-dpdk)
- DPDK uses VFIO to directly access physical device. Just like how we directly assign device to guest OS in QEMU (AFAIK, it is different for Mellanox NICs).
- Even though both DPDK and RDMA bypass kernel, their control
path is very different. For DPDK, there is a complete device
driver in the user space, and this driver communicate with the device via MMIO.
After VFIO ioctls, all data and control path bypass kernel.
For rdma-core, a lot control-path IB verbs (e.g., create_pd, create_cq) communicate with kernel via Infiniband device file ioctl.
And you can see all those uverb hanlders in `drivers/infiniband/core/uverbs.c`
Those control verbs will mmap some pages between user and kernel,
so all following datapath IB verbs (e.g., post_send) will just bypass kernel
and talk to device MMIO directly. Although rdma-core also has some vendor-specific
"drivers", but this is really different from the above DPDK's userspace PCIe driver, per se.
Userspace "rdma-core" vendor-driver deals with the kernel devel vendor-level driver details.
- FWIW, if you are using a Mellanox VPI card in Ethernet mode (e.g. CX3-5),
  DPDK will use its built-in mlx driver, which further use libibverbs,
  which further relies on kernel IB stack. It's not a complete user solution somehow.
  Note that DPDK built-in mlx driver uses RAW_PACKET QPs.
- ![image](../../images/dpdk_ibverbs.png)

### Internal

Top-down:

- The user-facing part is called [Envionmemt Abstraction Layer (EAL)](https://doc.dpdk.org/guides/prog_guide/env_abstraction_layer.html), which provides a set of portable interfaces among many OSes. We can think it of as a "POSIX" interface. This EAL has quite a lot useful and handy APIs, e.g., multicore support where you can call a function on arbitray cores (like the linux `on_each_cpu` core), timers, atomic operations, memory management APIs. I have built all these components myself, still very pleased to see this.
- Poll Mode Driver - we cover the mlx ones above
- Various other drivers
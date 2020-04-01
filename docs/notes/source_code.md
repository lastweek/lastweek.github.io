# Source code study

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Mar 3, 2020| add FreeBSD, some fpga stuff |
	|Feb 4, 2020| add io_uring, firecracker|
	|Jan 31, 2020| Add some good stuff |
	|Jan 18, 2020| Initial|

:whale2:

Beautiful code is art.
Recently I started forking good open source code
into my own Github account and started casual reading and taking notes.
In general, GNU projects are very hard to read, they have
their own coding style which isn't for everyone.
My personal favorite is linux kernel coding style,
and many linux-related projects follow this, e.g., CRIU, rdma-core.

Either way, happy hacking!

## Misc

Projects supporting our day-to-day work without us realizing it.

- [glibc: libc, elf, and dynamic linker](https://github.com/lastweek/source-glibc)
	- Some juicy information about GOT/PLT
	- and explains what has happend before main() is called
- [binutils: gas, static linker, and more](https://github.com/lastweek/source-binutils)
	- assembler is amazing
	- static linker.. the magic thing is its linker script!
- [strace](https://github.com/lastweek/source-strace)
	- System call tracer at userspace
	- I've designed [one](http://lastweek.io/lego/kernel/profile_strace/) for LegoOS in kernel space
- [vim](https://github.com/lastweek/source-vim)
- [tmux](https://github.com/lastweek/source-tmux)
- [git](https://github.com/lastweek/source-git)
- Network
	- [iperf3](https://github.com/lastweek/source-iperf)
		- iperf3: A TCP, UDP, and SCTP network bandwidth measurement tool
	- [tcpdump](https://github.com/lastweek/source-tcpdump)
		- the TCPdump network dissector
	- [OpenSSH](https://github.com/lastweek/source-openssh-portable)
		- ssh it is.
	- [scapy](https://github.com/lastweek/source-scapy)
		- Python-based interactive packet manipulation program & library
- C for life
	- [cJSON](https://github.com/lastweek/source-cJSON)
		- A lightweight JSON parser in C.
		- I think iperf3 is using it.
- Outliers
	- [CRIU: Checkpoint and Restore in Userspace](https://github.com/lastweek/source-criu)
		- The reason I love this repo is because it has so many interesting pieces
		  on how to interact with kernel, save states, and restore them. In addition,
		  it shows how to properly use many less well known syscalls.
	- [GRUB2: bootloader](https://github.com/lastweek/source-grub2)
		- Learn how modern bootloader works.
		- Detailed analysis of Linux booting sequence (how it transit from
		  real-mode to protected mode, and finally to 64-bit mode,
		  how to navigate Linux source code etc.)
	- [`io_uring`](https://kernel.dk/io_uring.pdf)
		- [user liburing](https://github.com/axboe/liburing)
		- [kernel io_uring.c](https://github.com/torvalds/linux/blob/master/fs/io_uring.c)

## Operating Systems

- [Linux 0.0.1](https://github.com/lastweek/linux-0.01)
- [Plan 9 OS](https://github.com/lastweek/source-plan9)
- [MSR Singularity.](https://github.com/lastweek/source-singularity)
- [OSv. A lightweight unikernel.](https://github.com/lastweek/source-osv)
- [illumos](https://github.com/lastweek/source-illumos-gate)
        - This is a fork of Oracle Solaris OS.
- [seL4 Microkernel](https://github.com/lastweek/source-seL4)
- [MacOS Darwin](https://github.com/lastweek/source-darwin-xnu)
- BSD: these repos have everything you can think of
	- [FreeBSD](https://github.com/lastweek/source-freebsd)
	- [OpenBSD](https://github.com/openbsd/src)
	- [NetBSD](https://github.com/NetBSD/src)
	- [TrueOS](https://github.com/trueos/trueos)

![image_unix_timeline](../images/unix_timeline.png)
(Image source: https://commons.wikimedia.org/wiki/File:Unix_timeline.en.svg)

## Virtualization

- [libvirt: virsh and more](https://github.com/lastweek/source-libvirt)
- [QEMU](https://github.com/lastweek/source-qemu)
	- Check my [notes](http://lastweek.io/notes/virt/)
- [Firecracker](https://github.com/lastweek/source-firecracker)
- [rust-vmm](https://github.com/rust-vmm/community)
- [cloud-hypervisor](https://github.com/cloud-hypervisor/cloud-hypervisor)

## Compilers

- [Rustc, in Rust](https://github.com/lastweek/source-rust)
- [PHP, in C](https://github.com/lastweek/source-php-src)
- [Python, in C](https://github.com/lastweek/source-cpython)
- [Google V8, in C++](https://github.com/lastweek/v8)
- [Apple Swift, in C++](https://github.com/lastweek/source-swift)
- [GNU GCC](https://github.com/gcc-mirror/gcc)

## Firmware

I'm obsessed with firmware projects, maybe because that's where I got started.
First it's SeaBIOS, the default one used by QEMU. Then UEFI, something I have never used (!).

- [SeaBIOS: the default BIOS used by QEMU](https://github.com/lastweek/source-firmware-seabios)
- [qboot: an alternative and lightweight BIOS for QEMU](https://github.com/lastweek/source-firmware-qboot)
    - Those are massive hackers, respect.
    - My experience about BIOS is calling them while the kernel (LegoOS) is running at 16-bit.
      BIOS *is* the OS for a just-booted kernel. I remember the lower 1MB is never cleared,
      maybe we could invoke the BIOS at 32 or 64-bit mode?
- [UEFI EDK II ](https://github.com/lastweek/source-uefi-edk2)
	-  "EDK II is a firmware development environment for the UEFI and UEFI Platform Initialization (PI) specifications"
	- Part of the [TianoCore](https://www.tianocore.org/) project, an open-source UEFI platform
	- The Unified Extensible Firmware Interface (UEFI) is a specification that
	  defines a software interface between an operating system and platform firmware.
	  UEFI is designed to replace the Basic Input/Output System (BIOS) firmware interface.
	- [OVMF](https://github.com/tianocore/tianocore.github.io/wiki/OVMF): OVMF is an EDK II based project to enable UEFI support for Virtual Machines. OVMF contains sample UEFI firmware for QEMU and KVM.
- [Microsoft Project Mu, a separate fork of EDK II](https://microsoft.github.io/mu/)
	- "Project Mu is a modular adaptation of TianoCore's edk2 tuned for building
	modern devices using a scalable, maintainable, and reusable pattern"
	- It's homepage explains the motivation behind it.
- A book: `Beyond BIOS Developing with the Unified Extensible Firmware Interface`.

## FPGA

- [Collection](https://github.com/lastweek/fpga_vivado_scripts)
- [Readings](https://github.com/lastweek/fpga_readings)
- Partial Reconfiguration
    - [Partial Reconfiguration Building Framework](https://github.com/lastweek/fpga_pr_scripts)
    - [Intepret Xilinx Bitstream](https://github.com/lastweek/fpga_interpret_bitstream)
    - [HLS-based **ICAP** Controller](https://github.com/lastweek/fpga_icap_hls/)
- Network
    - [Verilog-Ethernet](https://github.com/lastweek/source-verilog-ethernet)
            - Self-made PHY, MAC IPs
            - ARP, IP, UDP stack
            - [Alex Forencich](https://github.com/alexforencich) is a phenomenon Verilog hacker
    - [Corundum: an FPGA-based NIC](https://github.com/ucsdsysnet/corundum)
    - [Limago, HLS-based 100 GbE TCP/IP](https://github.com/lastweek/source-Limago)
- Simulation, Synthesis, and P&R
    - [Icarus iverilog](https://github.com/lastweek/source-iverilog).
      iverilog is a compiler that translates Verilog source code into
      executable programs for simulation, or other netlist formats for further processing [man page](https://linux.die.net/man/1/iverilog).
    - [VMware Cascade](https://github.com/lastweek/source-cascade).
      Just-in-time compilation for Verilog, what a brilliant idea.
    - [Verilog-to-routing](https://github.com/lastweek/source-vtr-verilog-to-routing).
        - Synthesis (`ODIN II`)
        - Logic Optimization & Technology Mapping (`ABC`)
        - Placement and Route (`VPR`)

## Web Servers

- [Apache httpd](https://github.com/lastweek/source-httpd)
- [nginx](https://github.com/lastweek/source-nginx)

## Key Value Stores

Point of interests:
1) in-memory, and can it extend to use disk/ssd?
2) persistence support
3) network support

- [RocksDB: A persistent KVS for Flash and RAM Storage. C++](https://github.com/lastweek/source-rocksdb)
- [LevelDB. C++](https://github.com/lastweek/source-leveldb)
- [Memcached. C](https://github.com/lastweek/source-memcached)
- [Redis. C](https://github.com/lastweek/source-redis)
- [etcd: Distributed reliable KVS. Go](https://github.com/lastweek/source-etcd)

## RDMA and More

- [rdma-core](https://github.com/lastweek/source-rdma-core)
	- Userspace IB verbs library (e.g., libibverbs)
	- Commands such as `ibv_devinfo`, `rc_pingpong`
	- Learn how userspace IB layer communicate with kernel, but also bypass kernel.
	  The technique replies on `ioctl()` and `mmap()`, standard.
	  But the ABI interface (i.e., data structures) are quite complex.
	- This is beautiful code
	- [Kernel Infiniband stack](https://github.com/torvalds/linux/tree/master/drivers/infiniband)
- [DPDK](https://github.com/lastweek/source-dpdk)
	- DPDK uses VFIO to directly access physical device.
	Just like how we directly assign device to guest OS in QEMU.
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
	- ![image](../images/dpdk_ibverbs.png)
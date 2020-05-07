# Source Code Study

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Apr 26, 2020| Add wayland, X, gnome, gtk etc |
	|Apr 10, 2020| add graphics section|
	|Apr 6, 2020| add verbs perftes|
	|Mar 3, 2020| add FreeBSD, some fpga stuff |
	|Feb 4, 2020| add io_uring, firecracker|
	|Jan 31, 2020| Add some good stuff |
	|Jan 18, 2020| Initial|

Beautiful code is art.
Recently I started forking good open source code
into my own Github account and started casual reading and taking notes.
This page links to all of them.

Happy hacking!

## Misc

Projects supporting our day-to-day work.

- [GNU glibc: libc, elf, and dynamic linker](https://github.com/lastweek/source-glibc)
	- It is the default C library used by almost everyone
	- It includes `ld.so`, the dynamic linker
	- I wrote some notes about GOT/PLT and explains what has happend before main() is called.
- [GNU binutils: gas, static linker, and more](https://github.com/lastweek/source-binutils)
	- This repo has a lot commands like `as`, `ld`, `objdump`, `nm` and so on
	- `ld` is static linker and I like the magic of its linker script
	- I guess another useful repo is `elfutils`
- [strace](https://github.com/lastweek/source-strace)
	- System call tracer at userspace
	- I've designed [one](http://lastweek.io/lego/kernel/profile_strace/) for LegoOS in kernel space
- Unix Commands
	- Of course almost all other listed repos in this section have some sort of commands.
	  But they are not essential. The following repos have the essential UNIX commands like ls, cat.
	  It's not possible to go through all of them. But rather, I think they serve as references
	  when we want to know how certain things are implemented (e.g., how dmesg get kernel log).
	- [BusyBox](https://github.com/lastweek/source-busybox)
	- [GNU Coreutils](https://github.com/lastweek/source-coreutils)
	- [util-linux](https://github.com/lastweek/source-util-linux)
	- FreeBSD and its friends
- Tools
	- [tmux](https://github.com/lastweek/source-tmux)
	- [git](https://github.com/lastweek/source-git)
- Editors
	- [vim](https://github.com/lastweek/source-vim)
	- [neovim](https://github.com/lastweek/source-neovim)
- Network
	- [iperf3](https://github.com/lastweek/source-iperf) is a TCP, UDP, and SCTP network bandwidth measurement tool
	- [tcpdump](https://github.com/lastweek/source-tcpdump)
	- [OpenSSH](https://github.com/lastweek/source-openssh-portable) is our ssh!
	- [scapy](https://github.com/lastweek/source-scapy): Python-based interactive packet manipulation program & library. Very neat
	- Also checkout [FreeBSD](https://github.com/lastweek/source-freebsd) as it has tools like `ifconfig`, `if`. 
- C for life
	- Some small and useful C projects
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
	- [FFmpeg](https://github.com/lastweek/source-FFmpeg)
		- FFmpeg project is famous for its clean and neat C code.
		- Besides, this project is used by a lot online video service companies
	- [`io_uring`](https://kernel.dk/io_uring.pdf)
		- [user liburing](https://github.com/axboe/liburing)
		- [kernel io_uring.c](https://github.com/torvalds/linux/blob/master/fs/io_uring.c)

## Operating Systems

- [Linux 0.0.1](https://github.com/lastweek/linux-0.01)
- [Plan 9 OS](https://github.com/lastweek/source-plan9)
- [MSR Singularity.](https://github.com/lastweek/source-singularity)
- [illumos](https://github.com/lastweek/source-illumos-gate)
        - This is a fork of Oracle Solaris OS.
- [seL4 Microkernel](https://github.com/lastweek/source-seL4)
- [MacOS Darwin](https://github.com/lastweek/source-darwin-xnu)
- BSD: these repos have everything you can think of
	- If you ever wondered how X is done, how to get Y from OS, this is where you look into.
	- [FreeBSD](https://github.com/lastweek/source-freebsd)
	- [OpenBSD](https://github.com/openbsd/src)
	- [NetBSD](https://github.com/NetBSD/src)
	- [TrueOS](https://github.com/trueos/trueos)
- [Unikernel](http://unikernel.org/)
	- [OSv. A lightweight unikernel.](https://github.com/lastweek/source-osv)
	- [IncludeOS](https://github.com/lastweek/source-IncludeOS)
	- [Rumprun](https://github.com/lastweek/source-rumprun)
	- [Solo5. Unikernel as processes!](https://github.com/lastweek/source-solo5)

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

- [GNU GCC](https://github.com/gcc-mirror/gcc)
- [Clang, LLVM, in C++](https://github.com/llvm/llvm-project)
	- This is a collection of projects. Clang is the frontend,
	compiles C/C++ code into LLVM's own IR format.
	The the backend LLVM will take multiple Passes to optimize
	the IR and the finally generate the assembly.
	- The beauty of Clang and LLVM is that they can be used
	as libraries, and we could invoke them to manipulate the
	compilation results, to do source-to-source transforms,
	modify Pass's IR etc. I found this super interesting!
- [Rustc, in Rust](https://github.com/lastweek/source-rust)
- [PHP, in C](https://github.com/lastweek/source-php-src)
- [Python, in C](https://github.com/lastweek/source-cpython)
- [Google V8, in C++](https://github.com/lastweek/v8)
- [Apple Swift, in C++](https://github.com/lastweek/source-swift)
- [TCL, in C](https://github.com/lastweek/source-tcl)
- [Perl 5, in C](https://github.com/lastweek/source-perl5)

## Firmware

I'm obsessed with firmware projects, maybe because that's where I got started.
First it's SeaBIOS, the default one used by QEMU. Then UEFI, something I have never used (!).

- Coreboot and Libreboot
- [SeaBIOS: the default BIOS used by QEMU](https://github.com/lastweek/source-firmware-seabios)
- [qboot: an alternative and lightweight BIOS for QEMU](https://github.com/lastweek/source-firmware-qboot)
    - Those are massive hackers, respect.
    - My experience about BIOS is calling them while the kernel (LegoOS) is running at 16-bit.
      BIOS *is* the OS for a just-booted kernel. I remember the lower 1MB is never cleared,
      maybe we could invoke the BIOS at 32 or 64-bit mode?
- UEFI
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
- Then boot loaders such as GRUB and U-Boot

The open-source firmware landscape:
![20200506-on-firmware-landscape.png](20200506-on-firmware-landscape.png)

## FPGA

- [My own Collection](https://github.com/lastweek/fpga_vivado_scripts)
- [My own Paper Readings](https://github.com/lastweek/fpga_readings)
- Partial Reconfiguration
    - [Partial Reconfiguration Building Framework](https://github.com/lastweek/fpga_pr_scripts)
    - [Intepret Xilinx Bitstream](https://github.com/lastweek/fpga_interpret_bitstream)
    - [HLS-based **ICAP** Controller](https://github.com/lastweek/fpga_icap_hls/)
- Network
	- [Corundum: an FPGA-based NIC](https://github.com/ucsdsysnet/corundum)
		- This is THE BEST network stack out there.
		- This is not simply a network stack, it is a NIC.
		- So what makes a NIC? First, PHY and MAC are basic.
		Second, PCIe connection between host and board.
		Third, DMA using PCIe, for TX and RX packets between host and board.
		Fourth, a host NIC driver;
		Fifth, some opt modules at NIC.
		- This project has it all. Most amazingly, it works on so many boards.
		- They have an FCCM'20 paper (finally!) describing the small modules inside.
	- [Verilog-Ethernet](https://github.com/lastweek/source-verilog-ethernet)
		- Self-made PHY, MAC IPs, ARP, IP, UDP stack
		- This is also used by the Corundum project.
	- [Limago, HLS-based 100 GbE TCP/IP](https://github.com/lastweek/source-Limago)
	- [FPGA Network Stack](https://github.com/fpgasystems/fpga-network-stack)
		- This one came from ETH as well.
		- This one is used by many papers, as far as i know, StRoM, EuroSys'20.
		- It's mostly HLS-based. And has ETH/IP/UDP/TCP, RoCE v2 stack.
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


## Graphics

As of today Apr 26, 2020, I sort of understand how evdev, X/Wayland, GTK/QT, and GNOME/KDE
layers on top of each other, and how they interact with each other.
But I still don't know how VNC comes into the picture. Let's figure out sometime!
And draw a picture like I did for DPDK/libibverbs.
As of today May 1, 2020, I now know how VNC fits into the big picture.

- [X Server](https://github.com/lastweek/source-xserver) and [Wayland](https://github.com/lastweek/source-wayland)
	- X is being replaced by Wayland now..
	- Wayland code seems clean
- [xvnc]()
	- xvnc and its friends, are sitting on top of display manager (i.e., X/Wayland).
	  They are clients of X/Wayland, but they act as X/Wayland servers for upper layer
	  application such as GTK/Qt.
	- It's a middleman, bringing network between X and GTK.
	- TigerVNC, TurboVNC and so on.
- [GNOME Shell and GTK](https://github.com/GNOME/gtk)
	- GTK's default backend is X.
	- GNOME shell is a layer on top of GTK+. Similar for KDE/Qt.
- [xRDP, an RDP server. In C](https://github.com/neutrinolabs/xrdp)
- [FreeRDP, client and server. In C](https://github.com/FreeRDP/FreeRDP)
	- Took a brief read of the code, it's super neat. Should take a serious look sometime.

This figure shows the software landscape:
![20200501-on-graphic-softwares-img3.png](20200501-on-graphic-softwares-img3.png)

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

## Databases

- [MySQL](https://github.com/lastweek/source-mysql-server)
- [PostgresSQL](https://github.com/lastweek/source-postgres)
- [Yugabyte, distributed SQL](https://github.com/lastweek/yugabyte-db)

## RDMA and More

- RPC
	- [gRPC](https://github.com/lastweek/source-grpc)
	- [eRPC, NSDI'19]()
- [Mellanox libvma](https://github.com/lastweek/source-libvma)
	- An userspace IB verbs based layer providing POSIX socket APIs.
	  In other words, a library like SocketDirect, SIGCOMM'19.
- [verbs perftest](https://github.com/lastweek/source-verbs-perftest)
	-  The collection contains a set of bandwidth and latency benchmark such as:
	- Send        - `ib_send_bw` and `ib_send_lat`
	- RDMA Read   - `ib_read_bw` and `ib_read_lat`
	- RDMA Write  - `ib_write_bw` and `ib_wriet_lat`
	- RDMA Atomic - `ib_atomic_bw` and `ib_atomic_lat`
	- Native Ethernet (when working with MOFED2) - `raw_ethernet_bw`, `raw_ethernet_lat`
- [rdma-core](https://github.com/lastweek/source-rdma-core)
	- Userspace IB verbs library (e.g., libibverbs)
	- Learn how userspace IB layer communicate with kernel, but also bypass kernel.
	  The technique replies on `ioctl()` and `mmap()`, standard.
	  But the ABI interface (i.e., data structures) are quite complex.
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
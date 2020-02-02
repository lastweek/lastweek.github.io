# Source code study

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Jan 31, 2020| Add some good stuff |
	|Jan 18, 2020| Initial|

:whale2:

Beautiful code is art.
Recently I started forking good open source code
into my own Github account and started casual reading and taking notes.

One of the major motivation is to take notes, honestly.
For some low-level projects (e.g., GRUB2, rdma-core),
I've already managed to understand them before,
but I reget I didn't take any notes or anything.

In general, GNU projects are very hard to read, they have
their own coding style which isn't for everyone.
My personal favorite is linux kernel coding style,
and many linux-related projects follow this, e.g., CRIU, rdma-core.

Either way, happy hacking!

*Open-Source Code*:

- [glibc: libc, elf, and dynamic linker](https://github.com/lastweek/source-glibc)
	- Some juicy information about GOT/PLT
	- and explains what has happend before main() is called
- [binutils: gas, static linker, and more](https://github.com/lastweek/source-binutils)
	- assembler is amazing
	- static linker.. the magic thing is its linker script!
- [CRIU: Checkpoint and Restore in Userspace](https://github.com/lastweek/source-criu)
- [GRUB2: bootloader](https://github.com/lastweek/source-grub2)
	- Learn how modern bootloader works.
	- Detailed analysis of Linux booting sequence (how it transit from
	  real-mode to protected mode, and finally to 64-bit mode,
	  how to navigate Linux source code etc.)
- Virtualization
	- [libvirt: virsh and more](https://github.com/lastweek/source-libvirt)
	- [QEMU](https://github.com/lastweek/source-qemu)
        	- Check my [notes](http://lastweek.io/notes/virt/)
- Network
	- [rdma-core](https://github.com/lastweek/source-rdma-core)
		- Userspace IB verbs library (e.g., libibverbs)
		- Commands such as `ibv_devinfo`, `rc_pingpong`
		- Learn how userspace IB layer communicate with kernel, but also bypass kernel.
		  The technique replies on `ioctl()` and `mmap()`, standard.
		  But the ABI interface (i.e., data structures) are quite complex.
		- This is beautiful code
	- [Linux kernel Infiniband stack]()
	- [DPDK](https://github.com/lastweek/source-dpdk)

*Operating Systems*:

- [Linux 0.0.1](https://github.com/lastweek/linux-0.01)
- [Plan 9 OS](https://github.com/lastweek/source-plan9)
- [MSR Singularity.](https://github.com/lastweek/source-singularity)

*FPGA Related*:

- [Collection](https://github.com/lastweek/fpga_vivado_scripts)
- [Readings](https://github.com/lastweek/fpga_readings)
- [Partial Reconfiguration Building Framework](https://github.com/lastweek/fpga_pr_scripts)
- [Intepret Xilinx Bitstream](https://github.com/lastweek/fpga_interpret_bitstream)
- [HLS-based ICAP Controller](https://github.com/lastweek/fpga_icap_hls/)

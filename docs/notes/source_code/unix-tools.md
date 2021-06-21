# Unix Tools

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Jun 21, 2021| Update|
	|Dec 23, 2020| extracted from the summary doc|

## Alternative UNIX commands

Old wine in new bottles. Those are moden rewrite of common commands.

- https://github.com/ibraheemdev/modern-unix

## Essential Commands

The following repos have the essential UNIX commands like ls, cat, demsg.
I don't think it is a good idea to blindly read the source code.
Rather, I think they should be used as references whenever we need to check how something is implemented.

Large Collections

- [BusyBox](https://github.com/lastweek/source-busybox)
    - This is a software suite that provides several Unix utilities in a **single executable file**.
    - It has a large collection of commands. It probably has everything that GNU coreutils has.
      BuysBox is targeting embedded environment.
- [GNU Coreutils](https://github.com/coreutils/coreutils)
    - This repo has the most used commands such as `cp`, `dd`, `cat`.
    - See the full list [here](https://en.wikipedia.org/wiki/List_of_GNU_Core_Utilities_commands).
- [GNU binutils: gas, static linker, and more](https://github.com/lastweek/source-binutils)
    - This one has a set of programming tools for creating and
      managing binary programs, object files, libraries, profile data, and assembly source code.
    - See the full list [here](https://en.wikipedia.org/wiki/GNU_Binutils)
- [util-linux](https://github.com/karelzak/util-linux)
    - This is a standard package distributed by the Linux Kernel Organization
      for use as part of the Linux operating system.
    - See the full list [here](https://en.wikipedia.org/wiki/Util-linux).
- [FreeBSD](https://github.com/lastweek/source-freebsd)

### Network Commands

- [iperf3](https://github.com/lastweek/source-iperf) is a TCP, UDP, and SCTP network bandwidth measurement tool
- [arping](https://github.com/ThomasHabets/arping)
- [tcpdump](https://github.com/lastweek/source-tcpdump)
- [OpenSSH](https://github.com/lastweek/source-openssh-portable) is our ssh!
- [scapy](https://scapy.readthedocs.io/en/latest/): Python-based interactive packet manipulation program & library. Very neat
- [tcpstat](https://github.com/lastweek/source-tcpstat): C-based simple tool that could dump network traffic. Seems using pcap interface, the one used by tcpdump?
- Also checkout [FreeBSD](https://github.com/lastweek/source-freebsd) as it has tools like `ifconfig`, `if` and many more

## Misc

- Tools
	- [tmux](https://github.com/lastweek/source-tmux)
	- [git](htgps://github.com/lastweek/source-git)
	- [FFmpeg](https://github.com/lastweek/source-FFmpeg)
		- FFmpeg project is famous for its clean and neat C code.
		- This project is used by a lot online video service companies
	- [CRIU: Checkpoint and Restore in Userspace](https://github.com/lastweek/source-criu)
		- The reason I love this repo is because it has so many interesting pieces
		  on how to interact with kernel, save states, and restore them. In addition,
		  it shows how to properly use many less well known syscalls.
	- [GRUB2: bootloader](https://github.com/lastweek/source-grub2)
		- Learn how modern bootloader works.
		- Detailed analysis of Linux booting sequence (how it transit from
		  real-mode to protected mode, and finally to 64-bit mode,
		  how to navigate Linux source code etc.)
	- [strace](https://github.com/lastweek/source-strace)
		- System call tracer at userspace
		- I've designed [one](http://lastweek.io/lego/kernel/profile_strace/) for LegoOS in kernel space

- Editors
	- [vim](https://github.com/lastweek/source-vim)
	- [neovim](https://github.com/lastweek/source-neovim)

## Libraries

- [GNU glibc: libc, elf, and dynamic linker](https://github.com/lastweek/source-glibc)
	- It is the default C library used by almost everyone
	- It includes `ld.so`, the dynamic linker
	- I wrote some notes about GOT/PLT and explains what has happend before main() is called.
- [GNU binutils: gas, static linker, and more](https://github.com/lastweek/source-binutils)
	- This repo has a lot commands like `as`, `ld`, `objdump`, `nm` and so on
	- `ld` is static linker and I like the magic of its linker script
	- I guess another useful repo is `elfutils`
- [C Library](https://en.wikipedia.org/wiki/C_standard_library)
	- [GNU glibc](https://github.com/lastweek/source-glibc) used by major Linux distributions
	- [musl libc](https://musl.libc.org/about.html) is a small libc impl used by Alpine Linux. Clean code.
	- [uClibc](https://www.uclibc.org/about.html) is a small libc targeting embedded cases
	- [bionic](https://android.googlesource.com/platform/bionic/) is Android's C library, math library, and dynamic linker
- [C++ Library]()
	- [NVIDIA libcu++](https://github.com/NVIDIA/libcudacxx) 

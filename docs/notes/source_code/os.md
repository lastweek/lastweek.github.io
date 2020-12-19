# Awesome Operating System

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Dec 18, 2020| extracted from the summary doc|

You know what, this page is AWESOME: https://github.com/jubalh/awesome-os.

## Mainstream
- [Linux 0.0.1](https://github.com/lastweek/linux-0.01)
	- This is the first linux source code released by Linus.
	  Despite several designs are static
	  or obsolete from today's point of view, it showcases a simple and elegant solution.
- [Plan 9 OS](https://github.com/lastweek/source-plan9)
	- Legendary OS.
	- So many systems are influended by Plan 9 (e.g., Go, gVisor)
- [illumos](https://github.com/lastweek/source-illumos-gate), a fork of the Oracle Solaris OS.
- [seL4 Microkernel](https://github.com/lastweek/source-seL4)
- [MacOS Darwin](https://github.com/lastweek/source-darwin-xnu)
- BSD
	- BSD releases all the companion software packages along with the kernel.
	  So there is a tighter relation between them.
	  If you ever wondered how XXX is done, or how to get YYY from OS, this is where you can look into.
	- [FreeBSD](https://github.com/lastweek/source-freebsd)
	- [OpenBSD](https://github.com/openbsd/src)
	- [NetBSD](https://github.com/NetBSD/src)
	- [TrueOS](https://github.com/trueos/trueos)
- [Unikernel](http://unikernel.org/)
	- [OSv. A lightweight unikernel.](https://github.com/lastweek/source-osv)
	- [IncludeOS](https://github.com/lastweek/source-IncludeOS)
	- [Rumprun](https://github.com/lastweek/source-rumprun)
	- [Solo5. Unikernel as processes!](https://github.com/lastweek/source-solo5)
- [Google Fuchsia](https://fuchsia.dev/)
	- TODO.

![image_unix_timeline](../../images/unix_timeline.png)
(Image source: https://commons.wikimedia.org/wiki/File:Unix_timeline.en.svg)

## Hobby

- [Visopsys](https://visopsys.org/)
	- "It features a simple but functional graphical interface, pre-emptive multitasking, and virtual memory"
- [BootOS](https://github.com/nanochess/bootOS)

## Academic

- [Singularity.](https://github.com/lastweek/source-singularity)
	- A research OS from MSR. Very interesting one.
	  It leverages certain PL features to write secure and dependable OS.
	  It also allows verification. It never landed as a commercial one,
	  but it does inspire certain follow-up works.
	- Several old research OSes have also used certain language features
	to carry out security measures (e.g., V++).

## Linux Distribution

Ever thought about how to go from Linux Kernel to a full Linux Distribution?

- Read: [Linux From Scratch](http://www.linuxfromscratch.org/lfs/view/10.0/)
- [systemd](https://systemd.io/)

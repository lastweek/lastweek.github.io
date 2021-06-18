# Open-source Firmware and Bootloaders

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Jun 17, 2021| some reorg|
	|Dec 7, 2020| add iPXE |
	|May 6, 2020| Initial Version|

In this blog post, I will review the current firmware and bootloader ecosystem.
Note that this is very x86-centric.

## Landscape

![20200506-on-firmware-landscape.png](20200506-on-firmware-landscape.png)
(Arrow from A to B means A can run after B. The combination and flow is very flexible.)

There are a lot open-source firmware projects.
I was trying to understand their relationship.
After some research, I drew the above figure.
This figure is very x86-centric. Other architecture have other firmwares.

Bottom-up:

1. Coreboot/Libreboot/UEFI: for motherboard init, e.g., init memory controller.
2. UEFI/BIOS
3. GRUB2/u-boot/iPXE: Bootloader
	- u-boot implements some UEFI spec as well.
4. OS

## Stages

Stage 0:

- For some boards, some ROM code gets run first no matter what.

Stage 1:

- coreboot/libreboot/UEFI.
- One of their major job is to initialize DRAM, processor, and other low level things,
  prepare HW so that later software can run.
  Their early stage code must ran from on-chip SRAM/Cache! They will init DRAM so that
  later firmware/bootloader/OS can use it.
- Once that is done, they will pass control to later stage software.

Stage 2:

- UEFI/SeaBIOS for x86/OpenSBI for risc-v
- Those are the firmware in general sense. They will discover hardware, prepare
  the memory map, prepare device tree, and so on. Essentially, they gather info.
- Note that, some of them live even after they pass control to OS.
- E.g., UEFI is also a service that OS can use.

Stage 3:

- U-boot/GRUB/iPXE
- This is the normal bootloader. Their responsibility is to load the OS kernel.
- They understand filesystem, network, and other stuff. They are a small OS in some sense.

Stage 4:

- OS

You can generally test all these firmware and bootloaders using QEMU.
Different distro may choose different bootloaders.

## Project Details

- [Coreboot](https://github.com/lastweek/source-firmware-coreboot) and Libreboot
	- Coreboot seems very interesting. It's only doing one job, which is initialize
	the very low-level memory controller and on-board resources. It uses cache as memory.
	- We don't need it on QEMU.
- [SeaBIOS: the default BIOS used by QEMU](https://github.com/lastweek/source-firmware-seabios)
	- This is good code to learn from.
	- SeaBIOS also works on physical machines.
- [qboot: an alternative and lightweight BIOS for QEMU](https://github.com/lastweek/source-firmware-qboot)
    - Those are massive hackers, respect.
    - My experience about BIOS is calling them while the kernel (LegoOS) is running at 16-bit.
      BIOS *is* the OS for a just-booted kernel. I remember the lower 1MB is never cleared,
      maybe we could invoke the BIOS at 32 or 64-bit mode?
- [u-boot]()
	- Generally u-boot is used as the primary bootloader after BIOS.
	- But u-boot is much more. Based on its description, it can init HW just like coreboot.
	  Besides, it also provides some UEFI interfaces. So a mix of different things.
	- u-boot is used by Chromebook.
- [UEFI](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface)
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
		- It's homepage explains the motivation behind it. Microsoft Surface is using it.
	- A book: `Beyond BIOS Developing with the Unified Extensible Firmware Interface`.
- Then boot loaders such as [GRUB](https://github.com/lastweek/source-grub2) and [U-Boot](https://github.com/u-boot/u-boot)
- [iPXE](https://github.com/ipxe/ipxe), network bootloader, this is an open-source version. As their website says, iPXE allows you to:
    ```
	boot from a web server via HTTP
	boot from an iSCSI SAN
	boot from a Fibre Channel SAN via FCoE
	boot from an AoE SAN
	boot from a wireless network
	boot from a wide-area network
	boot from an Infiniband network
	control the boot process with a script
    ```
- [LinuxBoot](https://www.linuxboot.org/)
	- Use Linux as the firmware, directly runs after HW is initialized (e.g., after coreboot).

If you are using a normal laptop or desktop, chances are, none of those firmware is used.
Normally machines are shipped with commercial firmwares.

To me, I like SeaBIOS project the most. It's simple and can boot everything we need.
(For example, Linux, LegoOS as well).


### Thoughts

I've read most of the project source code.
I do find a lot redundant code/steps.
A lot of them will do some initial setup, do hardware probe etc.

## Device Tree

There is a [device tree specification](https://devicetree-specification.readthedocs.io/en/v0.3/introduction.html).

!!! quote
    A DTSpec-compliant devicetree describes device information in a system that cannot necessarily be dynamically detected by a client program. For example, the architecture of PCI enables a client to probe and detect attached devices, and thus devicetree nodes describing PCI devices might not be required. However, a device node is required to describe a PCI host bridge device in the system if it cannot be detected by probing.

==> So it is intended for devices that cannot be dynamically probed.
    Devices like PCIe that could be probed shouldn't be included in a device tree.

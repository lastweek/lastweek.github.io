# Open-source Firmware and Bootloaders

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Dec 7, 2020| add iPXE |
	|May 6, 2020| Initial Version|

In this blog post, I will review the current firmware and bootloader ecosystem.

## Landscape

I admire those firmware projects, maybe because that's where I started.
At first I used SeaBIOS (the default one used by QEMU) to build OS.
Then I came across UEFI, though I have never used it.

There are a lot open-source firmware projects.
I was trying to understand their relationship.
After some research, I drew the following landscape figure.

![20200506-on-firmware-landscape.png](20200506-on-firmware-landscape.png)

Bottom-up:

- Coreboot/Libreboot/UEFI: for motherboard init, e.g., init memory controller.
- UEFI/BIOS
- iPXE
- GRUB2/U-Boto: Bootloader
- OS

## Projects

- [Coreboot](https://github.com/lastweek/source-firmware-coreboot) and Libreboot
	- Coreboot seems very interesting. It's only doing one job, which is initialize
	the very low-level memory controller and on-board resources. It uses cache as memory.
- [SeaBIOS: the default BIOS used by QEMU](https://github.com/lastweek/source-firmware-seabios)
- [qboot: an alternative and lightweight BIOS for QEMU](https://github.com/lastweek/source-firmware-qboot)
    - Those are massive hackers, respect.
    - My experience about BIOS is calling them while the kernel (LegoOS) is running at 16-bit.
      BIOS *is* the OS for a just-booted kernel. I remember the lower 1MB is never cleared,
      maybe we could invoke the BIOS at 32 or 64-bit mode?
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

If you are using a normal laptop or desktop, chances are, none of those firmware is used.
Normally machines are shipped with commercial firmwares.

To me, I like SeaBIOS project the most. It's simple and can boot everything we need.
(For example, Linux, LegoOS as well).

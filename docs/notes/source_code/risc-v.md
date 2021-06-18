# Explore RISC-V

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Jun 17, 2021 | Initial|

:sailboat:

This is work-in-progress.

## Architecture

- ISA
- VM
- Virtualization
- I/O, I/O MMU

## Firmware/Bootloader

[OpenSBI](https://riscv.org/wp-content/uploads/2019/06/13.30-RISCV_OpenSBI_Deep_Dive_v5.pdf).
This is the default firmware in QEMU for RISC-V. It replaces the old BBL.
This one runs after ROM and coreboot (if any).
This one will discover/probe hardware (i suppose).
After that, it passes control to normal bootloaders like u-boot or GRUB.

## Kernel

## Toolchain


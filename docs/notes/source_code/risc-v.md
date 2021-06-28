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

### OpenSBI

[OpenSBI](https://riscv.org/wp-content/uploads/2019/06/13.30-RISCV_OpenSBI_Deep_Dive_v5.pdf).
This is the default firmware in QEMU for RISC-V. It replaces the old BBL.
This one runs after ROM and coreboot (if any).
This one will discover/probe hardware (I suppose).
After that, it passes control to normal bootloaders like u-boot or GRUB, or just to linux kernel.

#### Code Study

- `firmware/fw_base.S` is the entry point.
  - mostly doing the usual, setting up envionment for C functions. It will save some critical information into a struct passed to C.
  - In the end, it will call into C `sbi_init(struct sbi_scratch *)`. Note the `sbi_scratch` structure is filled with crutial info by fw_base.S.
  - It seems every hart will do the same?
- `lib/sbi/sbi_init.c`.
  - 

#### Scripts

```bash
make V=1 CROSS_COMPILE=riscv64-linux-gnu- PLATFORM=generic FW_PAYLOAD_PATH=../linux/arch/riscv/boot/Image
```

## QEMU

Code in `hw/riscv/`, `hw/intc/*_clint_*`.

## Kernel

## Toolchain


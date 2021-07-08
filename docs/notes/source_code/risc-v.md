# Explore RISC-V

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Jun 17, 2021 | Initial|

:sailboat:

## Architecture

First of all, explore its architecture designs, such as ISA, virtual memory, virtualization support, devices, and so on.
At the time of writing, RISC-V's hypervisor extension has not been defined yet (hence not IOMMU as well).

- ISA
- VM
- Virtualization
- I/O, I/O MMU

## Firmware/Bootloader

This section discuss the boot flow and the firmware status.
RISC-V has been ported to most of the major firmware and bootloaders,
e.g., coreboot (first-stage-bootloader, prepare RAM), UEFI, U-Boot.

RISC-V has a cleaner design compared to X86.
Rather than relying on messed up ACPI interfaces,
it relys on a layer defined by SBI (an open-source implementation called OpenSBI).
The OpenSBI layer sits in Machine-Mode, i.e., the most priviledged mode.
It directly manages hardware and exposes standard APIs to upperlayer OS.
For example, it exposed `send_IPI`, `reset` APIs. Hence, in Linux,
it could simply call SBI to send IPI rather than implementing on its own and concerns about hardware details.
I like this separation of concerns. 

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
- `lib/sbi/sbi_init.c` is the C entry point after assembly.

Reset:
- See `sbi_system.c` and `sbi_ipi.c`. It looks like the reset is: send an IPI to target HART, which will then ran a sbi_ipi_process_halt handler to halt.
- Is this warm or cold reboot? Or neither?


#### Scripts

```bash
make V=1 CROSS_COMPILE=riscv64-linux-gnu- PLATFORM=generic FW_PAYLOAD_PATH=../linux/arch/riscv/boot/Image
```

## QEMU

Code in `hw/riscv/`, `hw/intc/*_clint_*`.

## Kernel

## Toolchain


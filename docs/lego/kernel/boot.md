# Notes on GRUB2 and Boot Sequence

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Mar 31, 2020| Copied from https://github.com/lastweek/source-grub2. |

## About GRUB2

GRUB2: https://www.gnu.org/software/grub/manual/grub/grub.html#Introduction

Source code: https://github.com/lastweek/source-grub2

### linux v.s. linux16

An interesting thing is that there are two ways to
load an kernel image in `grub.cfg`, either
`linux vmlinuz-3.10.0` or `linux16 vmlinuz-3.10.0`.
They have different effects, but not sure what are those differences.
I remember only the linux16 one works for me,
but not remembering why either. At least on CentOS 7, it's all linux16.

The `linux16` and `initrd16` in `grub-core/loader/i386/pc/linux.c`:
```c
GRUB_MOD_INIT(linux16)
{
  cmd_linux =
    grub_register_command ("linux16", grub_cmd_linux,
			   0, N_("Load Linux."));
  cmd_initrd =
    grub_register_command ("initrd16", grub_cmd_initrd,
			   0, N_("Load initrd."));
  my_mod = mod;
}

```

The `linux` and `initrd` in `grub-core/loader/i386/linux.c`:
```c
static grub_command_t cmd_linux, cmd_initrd;

GRUB_MOD_INIT(linux)
{
  cmd_linux = grub_register_command ("linux", grub_cmd_linux,
				     0, N_("Load Linux."));
  cmd_initrd = grub_register_command ("initrd", grub_cmd_initrd,
				      0, N_("Load initrd."));
  my_mod = mod;
}
```

## Boot Protocol and Sequence

This was written for https://github.com/lastweek/source-grub2. I just copied it here.

Linux (x86) has a boot protocol, described by https://www.kernel.org/doc/html/latest/x86/boot.html.
Essentially, it is a contiguous memory region, just like a big C `struct`:
some fields are filled by kernel duing compile time (`arch/x86/boot/tools/build.c` and some in code),
some fields are filled by GRUB2 during boot time to tell kernel some
important addresses, e.g., kernel parameters, ramdisk locations etc.

GRUB2 code follows the protocol, and you can partially tell from the `grub_cmd_linux()` function.

Last time I working on this was late 2016, I truly spent a lot investigating
how GRUB and linux boot works. I will try to document a bit, if my memory serves:

1. In the Linux kernel, file `arch/x86/boot/header.S` is the first file got run after GRUB2.
This file is a bit complicated but not hard to understand!
It has 3 parts.
For the first part, it detects if it was loaded by a bootloader, if not, just by printing an error message and reboot.
It the kernel was loaded by a bootloader like GRUB2, the first part will never execute.
The bootload will directly jump to the second part. This is part of the boot protocol.
For the second part, it lists all the fields described by the boot protocol.
And finally the third part is real-mode instructions that got run after the GRUB2 jumo.
The starting function is called `start_of_setup`, which will do some stack checking,
and then jump to C code in `arch/x86/boot/main.c`.

2. `arch/x86/boot/main.c` runs on real-mode, it will do some setup and jump to protected-mode (32-bit).
It is running after BIOS but before the actual Linux kernel.
Thus this piece of code must rely on BIOS to do stuff, which makes it very unique.
The major task of the setup code is to prepare the `struct boot_params`, which has all the boot information, some of them were extracted from the `header.S`. The `struct boot_params` will be passed down and used by many kernel subsystems later on.
The final jump happens in `arch/x86/boot/pmjump.S`
```c
        #
        # Jump to protected-mode kernel, 0x100000
        # which is the compressed/head_$(BITS).o
        #
        jmp     *%eax
```

3. Then, we are in `arch/x86/boot/compressed/head_64.S`.
Above pmjump jumps to `startup_32`, it will enable paging, tweak GDT table etc, setup pagetable, and transition to 64-bit entry point `startup_64`. 
And finally, we are in 64-bit. The final jump will go to `arch/x86/kernel/head_64.S`. We are close!

4. Now we are in `arch/x86/kernel/head_64.S`. We are in 64-bit. But some further setup is needed. This part is really low-level and engaging. I would never know I how managed to understand and port all this shit. It setup a lot GDT, IDT stuff, and some pgfault handlers. It turns out those early pgfault handlers are NECESSARY and I remember they played an very interesting role! Finally, this assembly will jump to `arch/x86/kernel/head64.c`, the C code!
    - I guess an interesting part is `secondary_startup_64`. This code is actually run by non-booting CPUs, or secondary CPUs.
      After the major boot CPU is up and running (already within `start_kernel()`), I believe its the `smp_init()` that will send IPI wakeup interrupts to all present secondary CPUs.
      The secondary CPUs will start from real-mode, obviously. Then they will transition from 16bit to 32bit, from 32bit to 64bit. That code is in [`arch/x86/realmode/rm/trampoline.S`](https://github.com/WukLab/LegoOS/blob/master/arch/x86/realmode/rm/trampoline.S)!
    - `arch/x86/realmode` is interesting. It uses piggyback technique. All the real-mode and 32bit code are in `arch/x86/realmode/rm/*`, a special [linker script](https://github.com/WukLab/LegoOS/blob/master/arch/x86/realmode/rm/ld.lds.S) is used to construct the code in a specific way! Think about mix 16bit, 32bit, 64bit code together, nasty!

5. Hooray, C world. We are in `arch/x86/kernel/head64.c`. The starting function is `x86_64_start_kernel`! And the end is the `start_kernel`, the one in `init/main.c`.

In all, there are a lot jumps after GRUB2 load the kernel, and its a long road before we can reach `start_kernel()`. It probably should not be this complex, but the x86 architecture really makes it worse. Happy hacking!

# How trampoline works in Lego

## What is trampoline code?
Trampoline code is used by `BSP` to boot other secondary CPUs.
At startup, `BSP` wakeup secondary CPUs by sending a `APIC INIT`
command, which carry the `[start_ip]` where the secondary CPUs should
start to run.

The trampoline code is the code starting from `[start_ip]`. Used
by the secondary CPU to jump from `16-bit realmode` to `64-bit` code
(the first instruction of 64-bit code will be in `arch/x86/kernel/head_64.S`).

## Where is the trampoline source code?
The source files are all in `arch/x86/realmode/`. There are two parts: __1)__ `arch/x86/realmode/rm/trampoline.S`: which is the code that will run. And it is a mix of 16-bit, 32-bit, 64-bit code (ugh..). __2)__ `arch/x86/realmode/piggy.S`: Since the trampoline code can not to linked
into kernel image directly. So we have to piggyback the trampoline.bin binary
code into a section, which is described by `trampoline_start` and `trampoline_end`. So the kernel can address the trampoline code via these two symbols.

The compile flow is:
```
	arch/x86/realmode/rm/trmapoline.S
	-> CC__ arch/x86/realmode/rm/trmapoline.o
	   -> LD arch/x86/realmode/rm/trampoline
	      -> OBJCOPY arch/x86/realmode/rm/trampoline.bin
	         -> This bin goes into piggy.o
		    -> piggy.o goes into vmImage
```

## What happened at runtime?
The setup code was loaded by GRUB below 1MB. Inside `arch/x86/boot/main.c`, we
will save the `cs()` into the `boot_params` and pass it to kernel. In `setup_arch()`, we will copy the trampoline.bin code to the `cs()` address reported by `boot_param`. This means we will override setup code, which is okay.

At last, we wake up the secondary CPUs inside `smp_init()`.

## Compare with Linux
I vaguely remember how Linux implement this. The only thing I remember is that Linux use some sort of structure, which is filled by BSP and then passed, or used by secondary CPUs. The mechanism has no difference, though. Linux just has more robust debugging facilities.

--  
Yizhou Shan  
Mar 3, 2017

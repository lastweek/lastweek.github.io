# Linux Linker Script Framework

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Oct 30, 2021| Initial|

Has nothing better to do, so to write some random note on linker script.

## Intro

The kernel is complied in a very controlled way.
It has a linker script to control exactly what sections are
generated and where they are.
The linker script is architecture specific.
I will examine `arch/x86/kernel/vmliniux.ld.S`.
Yes, it is an assembly file. The build framework will compile it into `vmlinux.ld`. 
The reason that it is in assembly format is simple.
We need to use a lot of macros, that are shared with C code.
Assembly files allow us to do that, linker script does not.

When I wrote LegoOS, I used the exact framework.
The whole thing was very confusing to me in the beginning.
The kernel code interacts with the linker script quite a lot, actually.
The most common use, is to annnotate C code (say put into a special section),
and then the linker script will aggregate them. Let me summarize the common flow:

1. Create a new section name. And use it to annotate your function and data. For example, I can create `__section("test")`, and mark `int foo __section("test")`. 
2. Then look into `vmlinux.lds.S`, add a new section. Also, add begin and end marcos before and after the section. You can use these macros in your C code.
```c
	. = ALIGN(8);
	.test_section : AT(ADDR(.test_section) - LOAD_OFFSET) {
		__test_section_start = .;
		*(.test);
		__test_section_end = .;
	}
```
3. And in your C code, you can declare `__test_section_start` and `__test_section_end`,
and use them. Kernel uses this trick a lot. If everything in this section is the same
type of data structures, you can simply walk through it as if it is an array.

Let's look at an example, say the x86 apicdrivers.

They defined a macro to annotate apic drivers.
```c
#define apic_driver(sym)                                        \    
        static const struct apic *__apicdrivers_##sym __used            \    
        __aligned(sizeof(struct apic *))                        \    
        __section(".apicdrivers") = { &sym }


static const struct apic testAPICdriver = { ... };
apic_driver(testAPICdriver)
```

And inside linker script, they define:
```c
	. = ALIGN(8);
	.apicdrivers : AT(ADDR(.apicdrivers) - LOAD_OFFSET) {
		__apicdrivers = .;
		*(.apicdrivers);
		__apicdrivers_end = .;
	}
```

Finally, define them in C and use it.
```c
extern struct apic *__apicdrivers[], *__apicdrivers_end[];

struct apic **drv;
for (drv = __apicdrivers; drv < __apicdrivers_end; drv++) {
...
}

```

The kernel scheduler code the trick to define various scheduler drivers too.

## Kernel

Various things that use linker script to organize their data and functions.

1. per-cpu data
2. ftrace
3. init and exit functions
4. ACPI, APIC
5. IRQCHIP
6. Exception handlers
7. cacheline aligned

## Boring Details

In the `vmlinux.lds.S`, those header files are included.
The most important one is `vmlinux.lds.h`.
```c
#include <asm-generic/vmlinux.lds.h>
#include <asm/asm-offsets.h>
#include <asm/thread_info.h>
#include <asm/page_types.h>
#include <asm/orc_lookup.h>
#include <asm/cache.h>
#include <asm/boot.h>
```

And be sure to checkout the [`vmlinux.lds.h`](https://github.com/torvalds/linux/blob/master/include/asm-generic/vmlinux.lds.h).
The top comments. It lays out the basic structrue of a linker script in linux.
And it defines all the macros used in the assembly linker file.
```c
/*
 * Helper macros to support writing architecture specific
 * linker scripts.
 *
 * A minimal linker scripts has following content:
 * [This is a sample, architectures may have special requiriements]
 *
 * OUTPUT_FORMAT(...)
 * OUTPUT_ARCH(...)
 * ENTRY(...)
 * SECTIONS
 * {
 *	. = START;
 *	__init_begin = .;
 *	HEAD_TEXT_SECTION
 *	INIT_TEXT_SECTION(PAGE_SIZE)
 *	INIT_DATA_SECTION(...)
 *	PERCPU_SECTION(CACHELINE_SIZE)
 *	__init_end = .;
 *
 *	_stext = .;
 *	TEXT_SECTION = 0
 *	_etext = .;
 *
 *      _sdata = .;
 *	RO_DATA(PAGE_SIZE)
 *	RW_DATA(...)
 *	_edata = .;
 *
 *	EXCEPTION_TABLE(...)
 *
 *	BSS_SECTION(0, 0, 0)
 *	_end = .;
 *
 *	STABS_DEBUG
 *	DWARF_DEBUG
 *	ELF_DETAILS
 *
 *	DISCARDS		// must be the last
 * }
 *
 * [__init_begin, __init_end] is the init section that may be freed after init
 * 	// __init_begin and __init_end should be page aligned, so that we can
 *	// free the whole .init memory
 * [_stext, _etext] is the text section
 * [_sdata, _edata] is the data section
 *
 * Some of the included output section have their own set of constants.
 * Examples are: [__initramfs_start, __initramfs_end] for initramfs and
 *               [__nosave_begin, __nosave_end] for the nosave data
 */
```

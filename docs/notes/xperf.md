# Page Fault Ring Switch Overhead

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Feb 2, 2020| Move github content to here |
	|Aug 7, 2019| Initial draft|

:children_crossing:

This page describes the mechanisms to measure the pure
x86 ring switch overhead, i.e., from ring 3 to ring 0 and back.

It is not straightforward to measure this in Linux kernel.
Because when a user program traps from user space to kernel space,
kernel will first run some assembly instructions
to save the registers and load some new ones for kernel usage
(i.e., [syscall](https://github.com/torvalds/linux/blob/master/arch/x86/entry/entry_64.S#L145),
 [common IDT](https://github.com/torvalds/linux/blob/master/arch/x86/entry/entry_64.S#L603),
 and some [directly registered](https://github.com/torvalds/linux/blob/master/arch/x86/entry/entry_64.S#L1193)).
And only then, the kernel will run the C code.
Thus if we place the measurement code
in the first C function that will run (e.g., [`do_syscall_64`](https://github.com/torvalds/linux/blob/master/arch/x86/entry/common.c#L282)), it will be much larger than the actual ring switch overhead.

My proposed solutions hacks the `entry_64.S` and tries to save a timestamp as soon as possible.
The first version centers around page fault handler,
whose trapping mechanism is different from syscalls.
However, I think it could be easily ported.
The code is [here](https://github.com/lastweek/linux-xperf-4.19.44).

Takeaways:

- It ain't cheap! It usually take ~400 cycles to trap from user to kernel space.
- User-to-kernel crossing is more expansive than kernel-to-user crossing!
- Virtilization adds more overhead

The following content is adopted from the Github repo.

## Purpose

This repo is a slighly hacked linux kernel that can be used to measure
user and kernel space crossing latency in CPU cycles. Crossing meant
ring level change within CPU, e.g., SYSCALL, interrupt, or exceptions.

This repo only measure the crossing overhead of page fault, which should
be similar to all other exceptions within x86 IDT tables. Syscall crossing
overhead is not measured, but can be measured in a similar fashion.

But do note, the numbers reported by this repo are slightly larger than the
real crossing overhead because some instructions are needed in between
to do bookkeeping. Check below for details.

## Numbers

Some preliminary numbers measured on top of Intel Xeon E5-v3 2.4GHz

|Platform| User to Kernel (Cycles)| Kernel to User (Cycles)|
|---| ---|---|
| VM| ~600 | ~370 |
|Bare-metal| ~440| ~270|


## Mechanism

### Files changed

The whole patch is [`xperf.patch`](https://github.com/lastweek/linux-xperf-4.19.44/blob/master/xperf.patch)

- `arch/x86/entry/entry_64.S`
- `arch/x86/mm/fault.c`: save u2k_k to user stack
- `xperf/xperf.c`: userspace test code

### User to kernel (u2k)

At a high-level, the flow is:

  - User save TSC into stack
  - User pgfault
  - Cross to kernel, get TSC, and save to user stack

But devil is in the details, especially this low-level assembly code.
There are several difficulties:

  - Once in kernel, we need to save TSC without corrupting any other
	  registers and memory content. Any corruption leads to panic etc.
	  The challenge is to find somewhere to save stuff.
	  Options are: kernel stack, user stack, per-cpu. Using user stack
	  is dangerous, because we can't use safe probe in this assembly (i.e., copy_from/to_user()).
	  Using kernel stack is not flexible because we need to manually
	  find a spot above pt_regs, and this subject to number of `call` invoked.
  - We need to ensure the measuring only applied to measure program,
	  but not all user program. We let user save a MAGIC on user stack.

The approach:

  - `entry_64.S`: Save rax/rdx into kernel stack, because they are known to be good
	  if the exceptions came from user space.
  - `entry_64.S`: Save TSC into a per-cpu area. With swapgs surrounded.
  - `entry_64.S`: Restore rax/rdx
  - `fault.c`: use `copy_to_user` to save `u2k_k` in user stack.

Enable/Disable:

  - `entry_64.S`: Change `xperf_idtentry` back to `idtentry` for both `page_fault` and `async_page_fault`.

Note: u2k hack is safe because we don't probe user virtual address directly in assembly.
Userspace accessing is done via `copy_from_user()`.

### Kernel to user (k2u)

At a high-level, the flow is:

  - Kernel save TSC into user stack
  - Kernel IRET
  - Cross to user, get TSC, and calculate latency

This is relatively simpiler than measuring u2k because we can safely use kernel stack.
The approach:

  - Save scratch %rax, %rdx, %rcx into kernel stack
  - Check if MAGIC match
  - rdtsc
  - save to user stack
  - restore scratch registers

Enable/Disable:

  - `entry_64.S:` There is a `xperf_return_kernel_tsc` code block.

Note: k2u hack is __NOT SAFE__ because we probe user virtual address directly in assembly,
i.e., `movq    %rax, (%rcx)` in our hack. During my experiments, sometimes it will crash,
but not always.

### xperf/xperf.c

This user program will report both u2k and k2u crossing numbers.
After compilation, use `objdump xperf.o -d` to check assembly,
```c
  mfence 
  rdtsc  				<- u2k_u

  shl    $0x20,%rdx
  or     %rdx,%rax
  mov    %rax,(%rdi)			<- save to user stack

  movl   $0x12345678,(%rsi)		<- pgfault

  rdtsc  				<- k2u_u
  mfence 
```

The user stack layout upon pgfault is:
```c
  | ..       |
  | 8B magic | (filled by user)   +24
  | 8B u2k_u | (filled by user)   +16
  | 8B u2k_k | (filled by kernel) +8
  | 8B k2u_k | (filled by kernel) <-- %rsp
```

### TSC Measurement

TSC will be reodered if no actions are taken. We use `mfence` to mimize runtime errors.

Ideally, we want a test sequence like this:
```c
/*
 * User to Kernel 
 *
 *          mfence
 *          rdtsc	<- u2k_u
 * (user)
 * -------  pgfault  --------
 * (kernel)
 *          rdtsc	<- u2k_k
 *          mfence
 */

/*
 * Kernel to User
 *
 *          mfence
 *          rdtsc	<- k2u_k
 * (kernel)
 * -------  IRET --------
 * (user)
 *          rdtsc	<- k2u_k
 *          mfence
 */
```

But we need some instructions in between to do essential setup.
So the real instruction flow is:

U2K
```
(User)
	mfence 
	rdtsc  					<- u2k_u

	shl    $0x20,%rdx
	or     %rdx,%rax
	mov    %rax,(%rdi)

	movl   $0x12345678,(%rsi)
       --------------------------------         Crossing
(Kernel)
	testb	$3, CS-ORIG_RAX(%rsp)
	jz	1f

	movq	%rax, -8(%rsp)
	movq	%rdx, -16(%rsp)

	rdtsc					<- u2k_k
	mfence
```

K2U
```
(Kernel)
	mfence
	rdtsc					<- k2u_k

	shl	$32, %rdx
	or	%rdx, %rax

	movq	%rax, (%rcx)
	popq	%rcx
	popq	%rdx
	popq	%rax

	INTERRUPT_RETURN
       --------------------------------         Crossing
(User)
	rdtsc					<- k2u_u
	mfence
```

## Misc

- For VM scenario, the page fault entry point is `async_page_fault`, not the `page_fault`.

## HOWTO Run

FAT NOTE:

- Enabling k2u code might bring crash
- It's not safe to disable KPTI
- Switch back to normal kernel after testing
- Make sure if you have a way to reboot your machine!

Steps:

- Copy your current kernel's .config into this repo
- make oldconfig
- Disable `CONFIG_PAGE_TABLE_ISOLATION`
- Compile kernel and install.
- Reboot into new kernel
- Disable hugepage
  - `echo never > /sys/kernel/mm/transparent_hugepage/enabled`
- Run `xperf/xperf.c`, you will get a report.

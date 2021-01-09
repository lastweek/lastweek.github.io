# Linux/LegoOS x86 Floating Point Unit

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Feb 22, 2018 | Initial Version|

FPU is heavily used by user level code.
You may not use it directly, but glibc library is using it a lot, e.g. the `strcmp`, `memcpy`.
x86 FPU is really a super complex technology designed by Intel.
Of course its performance is good and also widely used, but the legacy compatible feature? Hmm, not so yummy.

I would say that without Ingo Molnar's [x86 FPU code rewrite](https://lwn.net/Articles/643235/),
there is no way for me to easily understand it.
The current [x86 FPU code](https://elixir.bootlin.com/linux/v5.10.5/source/arch/x86/kernel/fpu) is well-written.
Even though I don't understand most of the low-level code, I do enjoy reading it.
The naming convention, the code organization, the file organization, the header files, it is a nice piece of art.

Below I will briefly list kernel subsystems that use FPU.

## Boot

FPU detection and init happen during early boot.
The `struct fpu` is a dynamically-sized structure.
Its size depends on what features the underlying CPU support.
Since `struct fpu` is part of `struct task_struct`,
that implies `task_struct` is dynamically-sized as well
(`task_struct -> thread_struct -> fpu`).
Apparently, `cpu_init()` will also callback to init its local FPU.

## Context Switch

FPU consists of a huge amount of registers.
Each thread will have its own FPU context.
However, the CPU itself will not save or restore any FPU registers automatically,
it is software's duty to save and restore FPU context properly.
And alla FPU context/registers saved saved into `struct fpu`.

Thus whenever we switch task, we also need to switch FPU context
(note: not always, it is optional, kernel is using a lazy switching trick).
[Code](https://elixir.bootlin.com/linux/v5.10.5/source/arch/x86/kernel/process_64.c#L546):
```c
__visible struct task_struct *
__switch_to(struct task_struct *prev_p, struct task_struct *next_p)
{
        ..
        fpu_switch = switch_fpu_prepare(prev_fpu, next_fpu, cpu);
        ..
        switch_fpu_finish(next_fpu, fpu_switch);
        ..
}
```

## SYSCALL

- fork() and clone(): When a new thread or process is created, the FPU context is copied from the calling thread.
- execve(): during this syscall, the FPU context will be cleared.
- exit(): When a thread exit, FPU will do cleanup based on whether `eagerfpu` or `lazyfpu` is used.

## Exceptions
Like the `device not available` exception, which may be triggered if **lazyfpu** is used.
The `do_simd_exception()` and `do_coprocessor_error()` are some math related exceptions.

## Signal

Kernel needs to setup a `sigframe` for user level signal handlers.
`sigframe` is a contiguous stack memory consists of the general purpose registers AND FPU registers.
So signal handling part has to call back to FPU code to setup and copy the FPU registers to the in stack `sigframe`.

Signal handling is another beast.

## Thoughts

Compatibility is a heavy thing to carry.
But it is also a nice thing for marketing.
No one can deny the success of Intel on its backward compatibility.
Bad for low-level system developers.

## References

1. https://unix.stackexchange.com/questions/475956/why-can-the-kernel-not-use-sse-avx-registers-and-instructions

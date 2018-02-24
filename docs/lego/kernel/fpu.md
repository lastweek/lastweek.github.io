# x86 Floating Point Unit

This is not a document about the FPU technology, this is just a simple note on FPU code and my debugging lesson.

FPU is heavily used by user level code. You may not use it directly, but glibc library is using it a lot, e.g. the `strcmp` function. x86 FPU is really another complex thing designed by Intel. Of course its performance is good and widely used, but the legacy compatible feature? Hmm.

I would say, without Ingo Molnar's [x86 FPU code rewrite](https://lwn.net/Articles/643235/), there is no way for me to easily understand it. The current x86 FPU code is well-written. Even though I don't quite understand what and why the code is, but I enjoy reading it. The naming convention, the code organization, the file organization, the header files, it is a nice piece of art.

Anyway, Lego ported this low-level FPU code from Linux without any change. The porting is painful because it requires a lot other related features. And it also deals with compatible syscalls a little bit. Below I will just briefly list other subsystems that are using FPU, and talk about my thoughts.

## Boot
FPU detection and init happen during early boot. You should know the `struct fpu` is a dynamically-sized structure. The size of it depends on what features the underlying CPU support. Since `struct fpu` is part of `task_struct`, that implies `task_struct` is dynamically-sized too. Apparently, `cpu_init()` will also callback to init its local FPU.

## Context Switch
FPU consists a lot registers, and each thread has its own FPU context. However, CPU will not save the FPU registers for us, it is software's duty to save and restore FPU context properly. FPU context is saved in `struct fpu`.

Thus whenever we switch task, we also need to switch FPU context:
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

- execve(): When `execve()` is called, the FPU context will be cleared.

- exit(): When a thread exit,, FPU will do cleanup based on if `eagerfpu` or `lazyfpu` is used.

## Exceptions
Like the `device not available` exception, which may be triggered if lazyfpu is used. Also, `do_simd_exception` and `do_coprocessor_error`, which are some math related exceptions.

## Signal
Kernel needs to setup a `sigframe` for user level signal handlers. `sigframe` is a contiguous stack memory consists the general purpose registers and FPU registers. So signal handling part will also call back to FPU to setup and copy the FPU registers to `sigframe` in stack.

## Thoughts
I've been debugging this FPU introduced bugs for over a month. And during this month, I'm always not sure if it is FPU's bug, or some other code that corrupts memory. So I'm lazy to re-port FPU again. But after rule out every other possibilities, I turned back to FPU. At first I did not port all FPU code, cause I don't think I need all of it.

One stupid thing is I forgot to turn on DEBUG_FPU, which should help me in the first place. I kind of lost myself in various engineering work during this debugging. I really need some big context switch in the middle to fresh my mind. Anyway, glad it is all done today (Feb 23), and I'm able to move to next stage.

Compatibility is a heavy thing to carry. But it is also a nice thing for marketing. No one can deny the success of Intel on its backward compatibility. Bad for programmers.

--  
Yizhou Shan  
Created: Feb 22, 2018  
Last Updated: Feb 23, 2018

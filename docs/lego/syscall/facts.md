# Lego SYSCALL Facts

This document is about the general concepts of Lego syscall implementation. If you are developing syscall, please read this document first.

## Interrupts Enabled
Each syscall is invoked with interrupts enabled. Also, it must return with interrupts enabled as well. Any buggy syscall implementation will be catched by `syscall_return_slowpath()`:
```c
void syscall_return_slowpath(struct pt_regs *regs)
{
        if (WARN(irqs_disabled(), "syscall %ld left IRQs disabled", regs->orig_ax))
                local_irq_enable();

        local_irq_disable();
        prepare_exit_to_usermode(regs);
}

void do_syscall_64(struct pt_regs *regs)
{
        ..
        local_irq_enable();

        if (likely(nr < NR_syscalls)) {
                regs->ax = sys_call_table[nr](
                        regs->di, regs->si, regs->dx,
                        regs->r10, regs->r8, regs->r9);
        }   

        syscall_return_slowpath(regs);
        ..
}
```

## Get User Entry pt_regs

The macro `task_pt_regs()` always return the `pt_regs`, that saves the user context when it issued the syscall, no matter how many levels interrupts are nested when you call `task_pt_regs()`. This is based on the fact that kernel stack is empty at syscall entry, thus this user `pt_regs` was saved at the `top` of kernel stack:
```c
#define task_pt_regs(tsk)       ((struct pt_regs *)(tsk)->thread.sp0 - 1)
```
```asm
ENTRY(entry_SYSCALL_64)
        SWAPGS

        /*
         * SYSCALL does not change rsp for us!
         * Save the previous rsp and load the top of kernel stack.
         * It must be the top of kernel stack, since we came here
         * from *userspace*.
         */
        movq    %rsp, PER_CPU_VAR(rsp_scratch)
        movq    PER_CPU_VAR(cpu_current_top_of_stack), %rsp

        /*
         * Construct struct pt_regs on stack
         *
         * In any syscall handler, you can use
         *      current_pt_regs()
         * to get these registers.
         */
        pushq   $__USER_DS                      /* pt_regs->ss */
        pushq   PER_CPU_VAR(rsp_scratch)        /* pt_regs->sp */
        pushq   %r11                            /* pt_regs->flags */
        pushq   $__USER_CS                      /* pt_regs->cs */
        pushq   %rcx                            /* pt_regs->ip */
        pushq   %rax                            /* pt_regs->orig_ax */
        pushq   %rdi                            /* pt_regs->di */
        pushq   %rsi                            /* pt_regs->si */
        pushq   %rdx                            /* pt_regs->dx */
        pushq   %rcx                            /* pt_regs->cx */
        pushq   $-ENOSYS                        /* pt_regs->ax */
        pushq   %r8                             /* pt_regs->r8 */
        pushq   %r9                             /* pt_regs->r9 */
        pushq   %r10                            /* pt_regs->r10 */
        pushq   %r11                            /* pt_regs->r11 */
        sub     $(6*8), %rsp                    /* pt_regs->bp, bx, r12-15 */
        ....
```

--  
Yizhou Shan  
Created: Feb 22, 2018  
Last Updated: Feb 22, 2018

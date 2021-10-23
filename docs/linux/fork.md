# About Linux fork()

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Oct 23, 2021| Initial|

So I had some whiskey and chips last night.
Sitting there watching TV, browsing random blogs.
Then I came across a blog I saved long time ago about linux switch_to history.
Then I recalled the moment I reliazed how switch_to/fork etc works, it was amazing.
So I decide to read the source code again and do some documentation.
I'm mostly reading my LegoOS code. This note is quite uncomplete though.
I won't have time going through the obvious.

copy_process() -> copy_thread().

## Prepare Kernel Stack and Function Pointers

This is the stack layout after copy_thread().
Also the rough layout when the newly created thread is enqueued into runqueue.
![stack_layout_fork](./stack_layout_fork.png)

The `copy_thread()` is architecture specific, I'm using x86 as an example.
This is a magic function as it plays with the stack, which is implicitly used by simply returning.
And this is confusing to a lot people, including myself when I got started.

Some facts about the kernel stack.
The kernel stack is allocated during fork() before we run into `copy_thread()`.
We can reference it by calling `task_stack_page(p)`.
The stack has a fixed size (maybe the latest version has changed this?), a configurable value called `THREAD_SIZE`, default is 2 pages I remember.
So the end (top) of the stack is simply `task_stack_page(p) + THREAD_SIZE`. Stack grows from top to bottom.
Hence, kernel uses a simple trick. It leverages the bottom of the kernel stack to save a struct called `thread_info`.
Quite an important data structure. The assumption is that kernel will not actually grow to the bottom. 
They do have a method to detect kernel stack corruption, I will not cover it here.

Alright, during `copy_thread()`, we basically have a "fresh" stack. We have copied everything from
the old stack to the new stack (done before calling into `copy_thread`).
The core job here is to setup the top of the stack, so that when this newly created thread can run
into certain predefined functions.

Top of the kernel stack is the `struct pt_regs`, this is true across the whole kernel.
So it is fairly easy to grab the pointer to it by using a simple macro called `task_pt_regs(p)`,
which just has simple pointer calculation.
Here, `copy_thread()` used a structure called `struct fork_frame`, which contains
a `struct inactive_task_frame` and a `struct pt_regs`. Again, leveraging the memory layout,
we can easily calculate the pointers to either structures.
Note, the `struct fork_frame` layout is crucial to understanding how fork'ed process gets running and how kernel thread runs into passed functions.

The bottom of the `struct fork_frame` is a field called `ret_addr`.
This is essentially the first function gets run when this newly created thread gets running (scheduled by runqueue). Here it is assigned to a function called `ret_from_fork()`, which
should be straightforward to understand. We will look into that later.
Alright, if this fork() is actually creating a kernel thread, we will save the kernel function
pointer and argument pointer to the `struct fork_frame` as well! All these info saved here
will be used later on in the assembly (`entry_64.S`).
```c

        childregs = task_pt_regs(p);
        fork_frame = container_of(childregs, struct fork_frame, regs);
        frame->ret_addr = (unsigned long) ret_from_fork;
        ...
        ... 
        /*
         * Save the kernel function pointer
         * and argument pointer to the `struct fork_frame`
         */
        if (unlikely(p->flags & PF_KTHREAD)) {     
                p->thread.pkru = pkru_get_init_value();     
                memset(childregs, 0, sizeof(struct pt_regs));     
                kthread_frame_init(frame, sp, arg);     
                return 0;     
        }     
```

Then the newly created thread will be enqueued into the runqueue.
Eventually it will gets running.

## Running for the first time

When the scheduler decides to run a thread, it will at least call `context_switch()`,
which internally calls `switch_to()`, which is just a macro around `__switch_to_asm`.
```c
#define switch_to(prev, next, last)                                     \    
do {                                                                    \    
        ((last) = __switch_to_asm((prev), (next)));                     \    
} while (0) 
```

`__switch_to_asm` is simply playing around the `struct fork_frame` we discussed above.
It first the current thread's state, switch stack (to the newly created thread's stack),
then starts popping out regs, eventually, only the `ret_addr` field remains in the stack!!

This is very important: we `jump` to the `__switch_to()` function.
Hence no return address will be pushed into the stack.
Later on, when `__switch_to()` finishes and returns, the hardware
will use the last field in the stack, which is the `ret_addr` field we placed there during `copy_thread()`! Elegant, isn't it? 

So, for a newly created process, the control flow is as follows
```
context_switch (c)
__switch_to_asm (asm)
__switch_to (c)
ret_from_fork (asm)
   ==> return system call
   ==> run kernel function
```

So what about other normal threads, i.e., after the first run?
Well, then the stack layout is different.
`ret_field` is actually pointing to the `context_switch` itself.
So it will return back there.

```
/*
 * %rdi: prev task
 * %rsi: next task
 */
ENTRY(__switch_to_asm)
        pushq   %rbp    
        pushq   %rbx    
        pushq   %r12    
        pushq   %r13    
        pushq   %r14    
        pushq   %r15    
    
        /* Switch stack */    
        movq    %rsp, TASK_threadsp(%rdi)    
        movq    TASK_threadsp(%rsi), %rsp    
    
        /* restore callee-saved registers */    
        popq    %r15    
        popq    %r14    
        popq    %r13    
        popq    %r12    
        popq    %rbx    
        popq    %rbp    
    
        /*
         * Note:
         * After popping out the above fields, now we only have
         * the `ret_field` left in the stack, which was pushed
         * into the stack by `copy_thread()`!
         * This is a *JUMP* to __switch_to() function!
         */
        jmp     __switch_to
END(__switch_to_asm)
```
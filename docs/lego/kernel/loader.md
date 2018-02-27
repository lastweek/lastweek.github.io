# Lego Program Loader

This document explains the high-level workflow of Lego's program loader, and how we change the normal loader to fit the disaggregated operating system model. Background on linking and loading is recommended.

## Status
|Formats|Supported|
|-|-|
| ELF (static-linked) |:heavy_check_mark:|
| ELF (dynamic-linked)|:heavy_check_mark:|

## Overall
In order to support different executable formats, Lego has a `virtual loader layer` above all specific formats, which is quite similar to `virtual file system`. In Lego, `execve()` is divided into two parts: `1)` syscall hook at processor side, `2)` real loader at memory side. Combined together, they provide the same semantic of `execve()` as described in Linux man page. Also for the code, we divide the Linux implementation into parts. But our emulation model introduces several interesting workarounds.


## Lego's Loader

Lego basically divide the Linux loader into two parts, one in memory manager and other in processor manager. Most dirty work is done by memory manager. Processor manager only needs to make sure the new execution has a fresh environment to start.

### Entry Point
So the normal entry point is `do_execve()`. Above that, it can be invoked by syscall from user space, or from kernel space by calling `do_execve()` directly. There are not too many places that will call `do_execve` within kernel. One notable case is how kernel starts the `pid 1` user program. This happens after kernel finished all initialization. The code is:
```c
static int run_init_process(const char *init_filename)                                                    
{
        argv_init[0] = init_filename;
        return do_execve(init_filename, argv_init, envp_init);
}
```

### Memory Manager's Job
Memory manager side will do most of the dirty loading work. It will parse the ELF image, create new VMAs based on ELF information. After that, it only pass `start_ip` and `start_stack` back to processor manager. Once processor manager starts running this new execution, pages will be fetched from memory component on demand.

#### Load ld-linux
For dynamically-linked images, kernel ELF loader needs to load the `ld-linux.so` as well. It will first try to map the `ld-linux.so` into this process's virtual address space. Furthermore, the first user instruction that will run is no longer `__libc_main_start`, kernel will transfer the kernel to `ld-linux.so` instead. Thus, for a normal user program, `ld-linux.so` will load all the shared libraries before running glibc.

```c hl_lines="10 37"
static int load_elf_binary(struct lego_task_struct *tsk, struct lego_binprm *bprm,
                           u64 *new_ip, u64 *new_sp, unsigned long *argv_len, unsigned long *envp_len)
{

        ...
        /* Dynamically-linked */
        if (elf_interpreter) {
                unsigned long interp_map_addr = 0;

                elf_entry = load_elf_interp(tsk, &loc->interp_elf_ex,
                                            interpreter,
                                            &interp_map_addr,
                                            load_bias, interp_elf_phdata);
                if (!IS_ERR((void *)elf_entry)) {
                        /*
                         * load_elf_interp() returns relocation
                         * adjustment
                         */
                        interp_load_addr = elf_entry;
                        elf_entry += loc->interp_elf_ex.e_entry;
                }
                if (BAD_ADDR(elf_entry)) {
                        retval = IS_ERR((void *)elf_entry) ?
                                        (int)elf_entry : -EINVAL;
                        goto out_free_dentry;
                }
                reloc_func_desc = interp_load_addr;

                put_lego_file(interpreter);
                kfree(elf_interpreter);
        } else {
        /* Statically-linked */
                /*
                 * e_entry is the VA to which the system first transfers control
                 * Not the start_code! Normally, it is the <_start> function.
                 */
                elf_entry = loc->elf_ex.e_entry;
                if (BAD_ADDR(elf_entry)) {
                        retval = -EINVAL;
                        goto out_free_dentry;
                }
        }
        ...
}
```

### Processor Manager's Job
It needs to flush old execution environment, and setup the new execution environment, such as signal, FPU. Notably, processor manager need to run `flush_old_exec()`, and `setup_new_exec()`.

#### Destroy old context: flush_old_exec()

##### Zap other threads
`de_thread` is used to kill other threads within the same thread group, thus make sure this process has its own signal table. Furthermore, A `exec` starts a new thread group with the same TGID of the previous thread group, so we probably also need to switch PID if calling thread is not a leader.

##### Switch to new address space
We also need to release the old mm, and allocate a new mm. The new mm only has the high address kernel mapping established. Do note that in Lego, pgtable is used to emulate the processor cache:
```c
static int exec_mmap(void)
{
        struct mm_struct *new_mm;
        struct mm_struct *old_mm;
        struct task_struct *tsk;

        new_mm = mm_alloc();
        if (!new_mm)
                return -ENOMEM;

        tsk = current;
        old_mm = current->mm;
        mm_release(tsk, old_mm);

        task_lock(tsk);
        tsk->mm = new_mm;
        tsk->active_mm = new_mm;
        activate_mm(old_mm, new_mm);
        task_unlock(tsk);

        if (old_mm)
                mmput(old_mm);
        return 0;
}
```

##### Clear Architecture-Specific state
This is performed by `flush_thread()`, which is an architecture-specific callback. In x86, we need to clear FPU state, and reset TLS array:
```c
void flush_thread(void)
{
        struct task_struct *tsk = current;
        memset(tsk->thread.tls_array, 0, sizeof(tsk->thread.tls_array));

        fpu__clear(&tsk->thread.fpu);
}
```


#### Setup new context: setup_new_exec()
Lego's `setup_new_exec()` is quite different from Linux's default implementation. Lego moves several functions to memory component, like the `arch_pick_mmap_layout` stuff. Thus, Lego only flush the signal handlers and reset the signal stack stuff:
```c
static void setup_new_exec(const char *filename)
{
        /* This is the point of no return */
        current->sas_ss_sp = current->sas_ss_size = 0;

        set_task_comm(current, kbasename(filename));

        flush_signal_handlers(current, 0);
}
```

#### Change return frame in stack
We do not return to user mode here, we simply replace the return IP of the regs frame. While the kernel thread returns, it will simply merge to syscall return path (check ret_from_fork() in entry.S for detail).
```c
/**
 * start_thread - Starting a new user thread
 * @regs: pointer to pt_regs
 * @new_ip: the first instruction IP of user thread
 * @new_sp: the new stack pointer of user thread
 */
void start_thread(struct pt_regs *regs, unsigned long new_ip,
                  unsigned long new_sp)
{
        loadsegment(fs, 0);
        loadsegment(es, 0);
        loadsegment(ds, 0);
        load_gs_index(0);
        regs->ip                = new_ip;
        regs->sp                = new_sp;
        regs->cs                = __USER_CS;
        regs->ss                = __USER_DS;
        regs->flags             = X86_EFLAGS_IF;
}
```

If calling `execve()` from userspace, the return frame is saved in the stack, we can simply do `start_thread` above, and merge to syscall return path. However, if calling `execve()` from a kernel thread, things changed. As you can see, all forked threads will run from `ret_from_fork` when it wakes for the first time. If it is a kernel thread, it jumps to `line 23`, to execute the kernel function. Normally, the function should not return. If it does return, it normally has called an `execve()`, and return frame has been changed by `start_thread()`. So we jump to `line 16` to let it merge to syscall return path.

```asm hl_lines="16 23"
/*
 * A newly forked process directly context switches into this address.
 *
 * rax: prev task we switched from
 * rbx: kernel thread func (NULL for user thread)
 * r12: kernel thread arg
 */
ENTRY(ret_from_fork)
        movq    %rax, %rdi
        call    schedule_tail           /* rdi: 'prev' task parameter */

        testq   %rbx, %rbx              /* from kernel_thread? */
        jnz     1f                      /* kernel threads are uncommon */

2:
        movq    %rsp, %rdi
        call    syscall_return_slowpath /* return with IRQs disabled */
        SWAPGS                          /* switch to user gs.base */
        jmp     restore_regs_and_iret

1:
        /* kernel thread */
        movq    %r12, %rdi
        call    *%rbx
        /*  
         * A kernel thread is allowed to return here after successfully
         * calling do_execve().  Exit to userspace to complete the execve()
         * syscall:
         */
        movq    $0, RAX(%rsp)
        jmp     2b  
END(ret_from_fork)
```

This is such a typical control flow hijacking. :-)

### Features
This section lists various features, or behaviors and Lego's program loader.

---
#### Virtual Address Space Range

User's virtual address falls into this range:
```
[sysctl_mmap_min_addr, TASK_SIZE)
```

By default,
```C
unsigned long sysctl_mmap_min_addr = PAGE_SIZE;

/*
 * User space process size. 47bits minus one guard page.  The guard
 * page is necessary on Intel CPUs: if a SYSCALL instruction is at
 * the highest possible canonical userspace address, then that
 * syscall will enter the kernel with a non-canonical return
 * address, and SYSRET will explode dangerously.  We avoid this
 * particular problem by preventing anything from being mapped
 * at the maximum canonical address.
 */                                                                                                       
#define TASK_SIZE       ((1UL << 47) - PAGE_SIZE)
```

Essentially:
```
[0x1000, 0x7ffffffff000)
```

---
#### Pre-Populated `.bss` and `.brk`
The heap vma created at loading time is a combination of `.bss` and `.brk` segments. Since brk usage is 0 (will it be non-zero?) at this moment, so the heap vma is essentially just `.bss` pages. Normally, Linux kernel does not populate pages for this vma during loading, but Lego does. It can save several page allocation cost for heap pcache miss. It is controlled by `vm_brk()`.
```c
int vm_brk(struct lego_task_struct *tsk,
           unsigned long start, unsigned long len)
{
        int ret;
        struct lego_mm_struct *mm = tsk->mm;

        if (down_write_killable(&mm->mmap_sem))
                return -EINTR;

        ret = do_brk(tsk, start, len);
        up_write(&mm->mmap_sem);

        /* Prepopulate brk pages */
        if (!ret)
                lego_mm_populate(mm, start, len);

        return ret;
}
```

---
#### Un-Populated stack
Stack vma is manually expanded to `32 pages + pages for argv info` by loader to accommodate future usage. Only pages for argv are populated by default, the extra 32 pages are not. A typical program may need 1 page for saving argv info, plus the 32 extra, the layout will be:
```
7ffffffde000-7ffffffff000 rw-p 00000000 [stack]
```

The code to expand stack is done when ELF loader tries to finalize the stack vma, by calling `setup_arg_pages()`:
```c
int setup_arg_pages(struct lego_task_struct *tsk, struct lego_binprm *bprm,
                    unsigned long stack_top, int executable_stack)
{
        ...
        /*
         * 32*4k (or 2*64k) pages
         */
        stack_expand = 131072UL;
        stack_size = vma->vm_end - vma->vm_start;
        stack_base = vma->vm_start - stack_expand;

        mm->start_stack = bprm->p;
        ret = expand_stack(vma, stack_base);
        ...
}
```

---
#### Un-Populated `.text` and `.data`
In essence, all PT_LOAD segments of ELF image are not pre-populated. They will be fetched from storage on demand. This is the traditional on-demand paging way. If we want to reduce the overhead of code and data's on-demand paging, we can prefault them in the future.

---
#### Disabled Randomized Top of Stack
Lego currently does not randomize the stack top. The stack vma is allocated by `bprm_mm_init()` at early execve time. There is no randomization at the allocation time, and this applies to all exectuable formats. The end of vma is just `TASK_SIZE`:
```c
static int __bprm_mm_init(struct lego_binprm *bprm)
{
        ...
        vma->vm_end = TASK_SIZE;
        ...
}
(managers/memory/loader/elf.c)
```

Top of stack randomization happens within each specific format loader. They do this by calling back to virtual loader layer's `setup_arg_pages()` function, which is used to finalize the top of stack:
```C
int setup_arg_pages(struct lego_task_struct *tsk, struct lego_binprm *bprm,
                    unsigned long stack_top, int executable_stack);
```

So, to actually randomize the top of stack, you can simply do the following:
```C
static unsigned long randomize_stack_top(unsigned long stack_top)
{                                
        unsigned long random_variable = 0;

        if ((current->flags & PF_RANDOMIZE) &&
                !(current->personality & ADDR_NO_RANDOMIZE)) {
                random_variable = get_random_long();
                random_variable &= STACK_RND_MASK;
                random_variable <<= PAGE_SHIFT;
        }
#ifdef CONFIG_STACK_GROWSUP
        return PAGE_ALIGN(stack_top) + random_variable;
#else           
        return PAGE_ALIGN(stack_top) - random_variable;
#endif
}

static int load_elf_binary(struct lego_task_struct *tsk, struct lego_binprm *bprm,
                           u64 *new_ip, u64 *new_sp, unsigned long *argv_len, unsigned long *envp_len)
{
        ...
        retval = setup_arg_pages(bprm, randomize_stack_top(TASK_SIZE),
                                 executable_stack);
        ...
}
```

However, current Lego disables randomization by passing `TASK_SIZE`:
```C
static int load_elf_binary(struct lego_task_struct *tsk, struct lego_binprm *bprm,
                           u64 *new_ip, u64 *new_sp, unsigned long *argv_len, unsigned long *envp_len)
{
        ...
        retval = setup_arg_pages(tsk, bprm, TASK_SIZE, executable_stack);
        ...
}
(managers/memory/loader/elf.c)
```

---
#### No vDSO
Currently, Lego does not have `vDSO` support. There are not too many syscalls mapped in the vDSO, for [x86-64](http://man7.org/linux/man-pages/man7/vdso.7.html):

- clock_gettime
- getcpu
- gettimeofday
- time

The reason to add it back is simple: if those syscalls are used `a lot` and hurt overall performance. Do note that when we add it back, it will be different from the common design: vDSO `must` be mapped at processor side, mapped in our emulated pgtable.

Below is the original part where loader maps vDSO:
```c
static int load_elf_binary(struct lego_task_struct *tsk, struct lego_binprm *bprm,
                           u64 *new_ip, u64 *new_sp, unsigned long *argv_len, unsigned long *envp_len)
{
        ...
#ifdef ARCH_HAS_SETUP_ADDITIONAL_PAGES
        /*
         * TODO: vdso
         * x86 can map vdso vma here
         */
#endif
        ...
}
managers/memory/loader/elf.c
```

For lego, we should move it to processor right before `start_thread()`:
```c
int do_execve(const char *filename,
              const char * const *argv,
              const char * const *envp)
{
        ...
        /* Should be here */

        start_thread(regs, new_ip, new_sp);
        ...
}
```

Besides, don't forget to report the `vDSO` address in the aux vector:
```c
static int create_elf_tables(struct lego_task_struct *tsk, struct lego_binprm *bprm,
                struct elfhdr *exec, unsigned long load_addr, unsigned long interp_load_addr,
                unsigned long *argv_len, unsigned long *envp_len)
{
        ...
#ifdef ARCH_DLINFO
        /*
         * ARCH_DLINFO must come first so PPC can do its special alignment of
         * AUXV.
         * update AT_VECTOR_SIZE_ARCH if the number of NEW_AUX_ENT() in
         * ARCH_DLINFO changes
         */
        ARCH_DLINFO;
#endif
        ...
}
```

--  
Yizhou Shan  
Created: Feb 16, 2018  
Last Updated: Feb 27, 2018

# Lego Program Loader

This document explains the high-level workflow of Lego's program loader, and how we change the normal loader to fit the disaggregated operating system model. Background on linking and loading is recommended.

## Status
|Formats|Supported|
|-|-|
| ELF (static-linked) |:heavy_check_mark:|
| ELF (dynamic-linked)|:heavy_multiplication_x:|

## Overall
In order to support different executable formats, Lego has a `virtual loader layer` above all specific formats, which is quite similar to `virtual file system`. In Lego, `execve()` is divided into two parts: `1)` syscall hook at processor side, `2)` real loader at memory side. Combined together, they provide the same semantic of `execve()` as described in Linux man page. Also for the code, we divide the Linux implementation into parts. But our emulation model introduces several interesting workarounds, which we will talk later.

Therefore, before we dive into Lego's implementation, we first walk through Linux's code, describe the important steps, and then we will talk about how lego divide these functionalities to fit disaggregated operating system model.

## Linux's Loader
This section describes the overall code flow of `execve()` within Linux. From the entry point to the return assembly part.

### Entry Point
So the normal entry point is `do_execve()` that will do all dirty work. Above that, it can be invoked by syscall from user space, or from kernel space by calling `do_execve()` directly. There are not too many places that will call `do_execve` within kernel. One notable case is how kernel starts the `pid 1` user program. This happens after kernel finished all initialization. The code is:
```c
static int run_init_process(const char *init_filename)                                                    
{                                                                                                         
        argv_init[0] = init_filename;                                                                     
        return do_execve(getname_kernel(init_filename),                                                   
                (const char __user *const __user *)argv_init,                                             
                (const char __user *const __user *)envp_init);                                            
}      
```

### Main Routine
Linux is good at making things complex, the execve main routine is no different. To accommodate different usages, the final dirty work is done by:
```c
/*
 * sys_execve() executes a new program.
 */
static int do_execveat_common(int fd, struct filename *filename,
                              struct user_arg_ptr argv,
                              struct user_arg_ptr envp,
                              int flags);
```


## Lego's Loader

### Virtual Address Space Range

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

### Loaded ELF Segments
Only PT_LOAD segments are loaded into memory:
```c
if (elf_ppnt->p_type != PT_LOAD)
        continue;
```

### Disabled Dynamic-Linked Binary
The following code detects if an ELF executable is dynamic-linked:
```C
static int load_elf_binary(struct lego_task_struct *tsk, struct lego_binprm *bprm,
                           u64 *new_ip, u64 *new_sp, unsigned long *argv_len, unsigned long *envp_len)
{
        ...
        elf_ppnt = elf_phdata;
        for (i = 0; i < loc->elf_ex.e_phnum; i++, elf_ppnt++) {
                if (elf_ppnt->p_type == PT_INTERP) {
                        /*  
                         * This is the program interpreter used for
                         * dynamic linked elf - not supported for now
                         */
                        WARN(1, "Only static-linked elf is supported!\n");
                        retval = -ENOEXEC;
                        goto out_free_ph;
                }   
        ...
}
(managers/memory/loader/elf.c)
```

### Disabled Randomized Top of Stack
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

--  
Yizhou Shan  
Feb 16, 2018

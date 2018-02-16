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
asd

--  
Yizhou Shan  
Feb 16, 2018

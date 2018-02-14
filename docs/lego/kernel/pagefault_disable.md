# The story of pagefault_disable/enable

`pagefault_disable()` is not really disabling the whole pgfault handling code. It is used to disable only the handling of pgfault that landed from `user virtual address`. Please note the difference between `user virtual address` and `user mode fault`. The first means the faulting address belongs to user virtual address space, while it can come from either user mode (CPL3) or kernel mode (CPL0). The second is a fault come from user mode (CPL3).

If pgfault is disabled, then `do_page_fault()` function will __NOT__ try to solve the pgfault by calling into `pcache`, instead, it will go straight to `fixup` code (in no_context()).

This function is not intended to be used standalone. Normally, we do __1)__ `pagefault_disable()`, __2)__ then use some functions that have `fixup` code, __3)__ then `pagefault_enable()`. (The `fixup` code is another magic inside kernel. We will cover it in another document.)

Currently in Lego, this is only used by `futex`, which needs something like `atomic_cmpxchg()` with an user virtual address. If pgfault happens in the middle, then this will not be atomic since kernel need to do pcache operations, which further needs to through network.

However, do note the difference with `uaccess` family functions. Most `uaccess` functions will not disable pgfault handling, which means pcache will be invoked. If pcache returns a `SEGFAULT`, pgfault code will go into `fixup` code. And that, my friend, is where `uaccess` returns `-EFAULT` to caller.

--  
Yizhou Shan  
Feb 01, 2018

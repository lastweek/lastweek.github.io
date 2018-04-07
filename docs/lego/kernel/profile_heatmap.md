# Lego Profile Kernel Heatmap

To get a sense of what is the hottest function within kernel, Lego adds a  counter based heatmap. It is the same with Linux's `/proc/profile`.

## Mechanism
General idea: for each possible function/instruction byte in the kernel, we attach to a counter to it. Once we detect this function/instruction was executed, we increment its associated counter.

However, fine granularity counting will need a lot extra memory, and it is not necessary to track each single instruction byte. Besides, it is hard to track down every time the function was executed. Furthermore, we only need an approximate heatmap.

Thus, kernel's solutions are:

- __Coarse granularity__: maintain a counter for each `1<<prof_shift` bytes.
- __Update counter on timer interrupt tick__, which is a constant stable entry.

## Supported Features

Currently, we only support `CPU_PROFILING`, which profile on each timer interrupt tick. We could also add `SCHED_PROFILING`, or `SLEEP_PROFILING`. But we are fine with current setting.

Of course, we also have a simple dump function `void print_profile_heatmap_nr(int nr)`, which is similar to userspace tool `readprofile`.

## Example Output
Workload is: MT-Phoenix word count, with 1GB data. (We probably want to rule out `cpu_idle()`)
```c
[ 1017.309754] Kernel Heatmap (top #10)
[ 1017.313731]          Address              Function          NR          %
[ 1017.321294] ----------------  --------------------  ----------  ---------
[ 1017.328858] ffffffff8101a600              cpu_idle      112082      73.11
[ 1017.336421] ffffffff810666f0            __schedule       19192      12.95
[ 1017.343983] ffffffff8104f500       mlx4_ib_poll_cq        5551       3.99
[ 1017.351546] ffffffff8103bf50             delay_tsc        5393       3.83
[ 1017.359110] ffffffff81034a10    victim_flush_async        3766       2.72
[ 1017.366673] ffffffff8102b220   slob_alloc.constpro        1992       1.47
[ 1017.374235] ffffffff810668d0              schedule        1519       0.15
[ 1017.381800] ffffffff810648f0   fit_send_reply_with         956       0.95
[ 1017.389362] ffffffff81062370   ibapi_send_reply_ti         307       0.30
[ 1017.396925] ffffffff8105a0d0   ib_mad_completion_h         232       0.23
[ 1017.404487] ----------------  --------------------  ----------  ---------
[ 1017.412052]                                             151994     100.00
[ 1017.419613]
```

--  
Yizhou Shan  
Created: April 06, 2018  
Last Updated: April 06, 2018

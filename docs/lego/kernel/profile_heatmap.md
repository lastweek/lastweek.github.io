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
```
[  290.958137] Kernel Heatmap (top #10)
[  291.000777]          Address              Function          NR    Percent
[  291.081898] ----------------  --------------------  ----------  ---------
[  291.163018] ffffffff8101a5d0              cpu_idle      113746      74.23
[  291.244140] ffffffff81066410            __schedule       18379      11.15
[  291.325260] ffffffff8104f220       mlx4_ib_poll_cq        5696       3.10
[  291.406382] ffffffff8103bc70             delay_tsc        5337       3.73
[  291.487503] ffffffff81034730    victim_flush_async        4416       2.13
[  291.568623] ffffffff8102af70  slob_alloc.constprop.2        1876       1.34
[  291.651825] ffffffff810665f0              schedule        1450       0.14
[  291.732945] ffffffff81064610  fit_send_reply_with_rdma_write_with_imm         898       0.89
[  291.833826] ffffffff810124a0                printk         297       0.29
[  291.914948] ffffffff8103b3e0   check_pinned_status         252       0.25
[  291.996068] ----------------  --------------------  ----------  ---------
[  292.077189]                                             153393     100.00
```

--  
Yizhou Shan  
Created: April 06, 2018  
Last Updated: April 06, 2018

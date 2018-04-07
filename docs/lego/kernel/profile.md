# Lego Profile

Lego has three different profilers in kernel:

- [strace](https://lastweek.github.io/lego/kernel/profile_strace)
- [heatmap](https://lastweek.github.io/lego/kernel/profile_heatmap)
- [profile points](https://lastweek.github.io/lego/kernel/profile_points)


Combined together, they provide this information:
```c
[ 1017.047366] Kernel strace
[ 1017.050276] Task: 20:20 nr_accumulated_threads: 46
[ 1017.055837] % time        seconds  usecs/call     calls    errors syscall
[ 1017.063213] ------ -------------- ----------- --------- --------- ----------------
[ 1017.071648]  98.16   33.839597842     1879978        18         0 sys_futex
[ 1017.079406]   0.26    0.260143997      260144         1         0 sys_execve
[ 1017.087260]   0.18    0.185456860        7133        26         0 sys_write
[ 1017.095017]   0.50    0.050189546         913        55         0 sys_munmap
[ 1017.102870]   0.25    0.025223661         255        99         0 sys_mmap
[ 1017.110531]   0.50    0.000505134          12        45         0 sys_clone
[ 1017.118288]   0.20    0.000202327          26         8         0 sys_read
[ 1017.125947]   0.14    0.000144065          17         9         0 sys_open
[ 1017.133608]   0.67    0.000067251           7        11         0 sys_brk
[ 1017.141171]   0.30    0.000030361           7         5         0 sys_newfstat
[ 1017.149219]   0.64    0.000006410           1         9         0 sys_close
[ 1017.156976]   0.48    0.000004842           1        45         0 sys_madvise
[ 1017.164927]   0.34    0.000003443           1        47         0 sys_set_robust_list
[ 1017.173653]   0.21    0.000002137           1        52         0 sys_mprotect
[ 1017.181702]   0.71    0.000000717           1         4         0 sys_gettimeofday
[ 1017.190137]   0.60    0.000000608           1         3         0 sys_time
[ 1017.197797]   0.51    0.000000513           1         2         0 sys_getrlimit
[ 1017.205942]   0.49    0.000000498           1         2         0 sys_rt_sigprocmask
[ 1017.214572]   0.46    0.000000469           1         4         0 sys_rt_sigaction
[ 1017.223008]   0.45    0.000000453           1         2         0 sys_arch_prctl
[ 1017.231249]   0.27    0.000000272           1         2         0 sys_newuname
[ 1017.239298]   0.13    0.000000135           1         2         0 sys_set_tid_address
[ 1017.248025] ------ -------------- ----------- --------- --------- ----------------
[ 1017.256460] 100.00   34.361581541                   451         0 total
[ 1017.263830]
[ 1017.308295]
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
[ 1017.421267]
[ 1017.422911] Kernel Profile Points
[ 1017.426594]  status                  name             total                nr            avg.ns
[ 1017.436292] -------  --------------------  ----------------  ----------------  ----------------
[ 1017.445988]     off      flush_tlb_others       0.000153470                55              2791
[ 1017.455685]     off     pcache_cache_miss      16.147020152            274698             58781
[ 1017.465381] -------  --------------------  ----------------  ----------------  ----------------

```

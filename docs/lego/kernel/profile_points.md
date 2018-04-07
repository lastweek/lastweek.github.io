# Lego Profile Points

Lego profile points facility is added to trace specific functions, or even a small piece of code. It is added in the hope that it can help to find performance bottleneck. It is added in the hope that it can reduce the redundant coding chore.

## Example

To trace TLB shootdown cost.
```c hl_lines="1 7 15 17"
DEFINE_PROFILE_POINT(flush_tlb_others)

void flush_tlb_others(const struct cpumask *cpumask, struct mm_struct *mm,
                      unsigned long start, unsigned long end)
{       
        struct flush_tlb_info info;
        PROFILE_POINT_TIME(flush_tlb_others)

        if (end == 0)
                end = start + PAGE_SIZE;
        info.flush_mm = mm;
        info.flush_start = start;
        info.flush_end = end;

        profile_point_start(flush_tlb_others);
        smp_call_function_many(cpumask, flush_tlb_func, &info, 1);
        profile_point_leave(flush_tlb_others);
}
```

Explanation: `DEFINE_PROFILE_POINT()` will define a local structure, that contains the profile point name, number of invoked times, and total execution time. `PROFILE_POINT_TIME()` will define a stack local variable, to save the starting time. `profile_point_start()` will save the current time in nanosecond, while `profile_point_leave()` will calculate the execution of this run, and update the global counters defined by `DEFINE_PROFILE_POINT()`.

System-wide profile points will be printed together if you invoke `print_profile_points()`:
```c
[ 9956.404635] Kernel Profile Points
[ 9956.408319]  status              name             total                nr            avg.ns
[ 9956.417627] -------  ----------------   ----------------  ----------------  ----------------
[ 9956.426935]     off  flush_tlb_others        0.000154283                56              2756
[ 9956.436243]     off  pcache_cache_miss      16.981247886            274698             61818
[ 9956.445649] -------  ----------------   ----------------  ----------------  ----------------
[ 9956.454957]
```

## Mechanism
Once again, the profile points are aggregated by linker script. Each profile point will be in a special section `.profile.point`. The linker will merge them into one section, and export the starting and ending address of this section.

Part I. Annotate.
```c
#define __profile_point         __section(.profile.point)

#define DEFINE_PROFILE_POINT(name)                                                      \
        struct profile_point _PP_NAME(name) __profile_point = {
		...
		...
        };

```

Part II. Link script merge.
```c
. = ALIGN(L1_CACHE_BYTES);
.profile.point : AT(ADDR(.profile.point) - LOAD_OFFSET) {
	__sprofilepoint = .;
	*(.profile.point)
	__eprofilepoint = .;
}
```

Part III. Walk through.
```c
void print_profile_points(void)
{
        struct profile_point *pp;

        for (pp = __sprofilepoint; pp < __eprofilepoint; pp++) {
                print_profile_point(pp);
		...
	}  
```

I really love the linker script. ;-)

--  
Yizhou Shan  
Created: April 06, 2018  
Last Updated: April 06, 2018

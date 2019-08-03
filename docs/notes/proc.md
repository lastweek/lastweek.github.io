# Special Files


- `/sys/devices/system/<name>`
    - Creation: `subsys_system_register()`, @ [drivers/base/bus.c](https://github.com/torvalds/linux/blob/0ecfebd2b52404ae0c54a878c872bb93363ada36/drivers/base/bus.c#L1180)
    - Note that this subdirectory is a legacy. Newer stuffer are added into other folders inside `/sys`.
    - `/sys/devices/system/cpu/*`, @ [drivers/base/cpu.c](https://github.com/torvalds/linux/blob/0ecfebd2b52404ae0c54a878c872bb93363ada36/drivers/base/cpu.c)
        - Root Object is [cpu_root_attrs](https://github.com/torvalds/linux/blob/0ecfebd2b52404ae0c54a878c872bb93363ada36/drivers/base/cpu.c#L467). The `online` file belongs to another [sub-object](https://github.com/torvalds/linux/blob/0ecfebd2b52404ae0c54a878c872bb93363ada36/drivers/base/cpu.c#L222)
        - And this [register_cpu()](https://github.com/torvalds/linux/blob/0ecfebd2b52404ae0c54a878c872bb93363ada36/drivers/base/cpu.c#L366) function is used to setup the directories for each cpu.

Many applications use `/sys/devices/system/cpu/online` to get the number of available CPUs.
And it's hard to change this behavior because it's usually encoded inside glibc.
Thus, if you want to "hide" certain CPUs from applications for some reason,
you can write a kernel module that use `set_cpu_active(cpu, false)`,
and then use the following small patch. (Note that using `set_cpu_online(cpu, false)`
will confuse CPU idle routine and panic.)
```diff
diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
--- a/drivers/base/cpu.c
+++ b/drivers/base/cpu.c
@@ -220,7 +220,8 @@ static ssize_t show_cpus_attr(struct device *dev,

 /* Keep in sync with cpu_subsys_attrs */
 static struct cpu_attr cpu_attrs[] = {
-       _CPU_ATTR(online, &__cpu_online_mask),
+       _CPU_ATTR(online, &__cpu_active_mask),
        _CPU_ATTR(possible, &__cpu_possible_mask),
        _CPU_ATTR(present, &__cpu_present_mask),
 };
```

- `/proc/pressure`
    - https://lwn.net/Articles/759658/

--  
Yizhou Shan  
Created: Jul 26, 2019  
Last Updated: Aug 03, 2019

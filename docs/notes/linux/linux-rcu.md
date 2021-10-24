# Linux RCU

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Oct 23, 2021| Initial|

RCU is just brilliant but also painfully hard to understand in the first place.
I want to walk through how RCU is actually implemented in the kernel and take some notes.

The `synchronize_rcu()` is the most interesting function.
By definition, it will only return after making sure no other CPUs are still in the reader side critical section.
In a non-preemptive kernel, it can simply wait all other CPUs to have a context switch.
But in a preemptive kernel, it becomes more complicated.

Just a naive thought, one can use some sort of per-cpu variable to track whether
a CPU has a context switch during the  `synchronize_rcu()` call.

In the latest code (v5.9), this is the impl.
So it appears `synchronize_rcu_expedited()` will speedup the grace period by
forcefully send IPI to other CPUs to enforce context switch.
The normal wait is the `wait_rcu_gp()` function. Very complicated function.
It has several callback etc. But I guess it has to has a way to check
other CPUs' status, right? To know whether other CPUs have context switched or so on.
Anymore, I didn't expect to understand RCU impl in just few hours.
I should use this a bit more and read a bit more.
```c
void synchronize_rcu(void)
{
	RCU_LOCKDEP_WARN(lock_is_held(&rcu_bh_lock_map) ||
			 lock_is_held(&rcu_lock_map) ||
			 lock_is_held(&rcu_sched_lock_map),
			 "Illegal synchronize_rcu() in RCU read-side critical section");
	if (rcu_blocking_is_gp())
		return;  // Context allows vacuous grace periods.
	if (rcu_gp_is_expedited())
		synchronize_rcu_expedited();
	else
		wait_rcu_gp(call_rcu);
}
EXPORT_SYMBOL_GPL(synchronize_rcu);
```
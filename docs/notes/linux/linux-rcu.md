# Linux RCU

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Oct 23, 2021| Initial|

## References

0. [What is RCU, Fundamentally?](https://lwn.net/Articles/262464/)
	- This is a great article.
	- You should really understand the example cases in this article. It could give a better understanding on why RCU works and how to modify your code to use it.
1. [RCU Usage In the Linux Kernel: One Decade Later](https://pdos.csail.mit.edu/6.828/2017/readings/rcu-decade-later.pdf)
2. http://blog.foool.net/wp-content/uploads/linuxdocs/RCU.pdf

## Notes

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
	if (rcu_blocking_is_gp())
		return;  // Context allows vacuous grace periods.
	if (rcu_gp_is_expedited())
		synchronize_rcu_expedited();
	else
		wait_rcu_gp(call_rcu);
}
EXPORT_SYMBOL_GPL(synchronize_rcu);
```

Ah, I think the RCU usage paper gives a nice high-level summary on Linux's implementaiton:

- In practice Linux implements `synchronize_rcu` by waiting for all CPUs in the system to pass through a context switch, instead of scheduling a thread on each CPU. This design optimizes the Linux RCU implementation for low-cost RCU critical sections, but at the cost of delaying synchronize_rcu callers longer than necessary. In principle, a writer waiting for a particular reader need only wait for that reader to complete an RCU critical section. The reader, however, must communicate to the writer that the RCU critical section is complete. The Linux RCU implementation essentially batches reader-to-writer communication by waiting for context switches. When possible, writers can use an asynchronous version of `synchronize_rcu`, `call_rcu`, that will asynchronously invokes a specified callback after all CPUs have passed through at least one context switch.
- The Linux RCU implementation tries to amortize the cost of detecting context switches over many `synchronize_rcu` and `call_rcu` operations. **Detecting context switches requires maintaining state shared between CPUs**. A CPU must update state, which other CPUs read, that indicate it executed a context switch. Updating shared state can be costly, because it causes other CPUs to cache miss. **RCU reduces this cost by reporting per-CPU state roughly once per scheduling clock tick**. If the kernel calls `synchronize_rcu` and `call_rcu` many times in that period, RCU will have reduced the average cost of each call to `synchronize_rcu` and `call_rcu` at the cost of higher latency. Linux can satisfy more than 1,000 calls to `synchronize_rcu` and `call_rcu` in a single batch [22]. For latency sensitive kernel subsystems, RCU provides expedited synchronization functions that execute without waiting for all CPUs to execute multiple context switches.
```

## How to use RCU?

After reading several RCU code snippets, it is not hard to notice that they have a common theme.
Especicially for the List related operations, there is no final atomic modification in the updater thread.
This atomic update serves as a barrier. The reaeders rely on this pointer to grab info pointed by this pointer.
This is very important trick to leverage RCU. If you code is not like, you should add this level of indirection,
package your data behind a pointer and modify the reader to follow the pointer.

Also, the List RCU related operations may seem confusing in the start, because, naturally,
we'd think there are so many operations inside list walk, insert and removal, how come they are safe?
The catch is that, usually for readers who are doing list-walk, they only use the `next` pointer.
So for `insert` and `removal`, they only need to gurantee the of `next`, meaning, they need to make sure that
the list/data is correct (no NULL pointer) for both before and after updaing `next` pointer.
And this is sufficient for readers!

In all, changing to RCU requires a good understanding on your own logic.
If your data structrue is not packaged, package it behind some pointers.
And make sure the readers integrity can be ensured by relying on this single pointer.

One more thing is Reader Retry. It is obvious that the readers might see stale data.
So it is up to the designers to retry. The designer can rely on the Sequence Lock for this purpose for example.

You can read the RCU usage paper for more suggestions.

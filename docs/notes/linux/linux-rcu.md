# Linux RCU

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Oct 24, 2021| Add code reading section |
	|Oct 23, 2021| Initial|

## References

0. [What is RCU, Fundamentally?](https://lwn.net/Articles/262464/)
	- This is a great article.
	- You should really understand the example cases in this article. It could give a better understanding on why RCU works and how to modify your code to use it.
1. [RCU Usage In the Linux Kernel: One Decade Later](https://pdos.csail.mit.edu/6.828/2017/readings/rcu-decade-later.pdf)
2. http://blog.foool.net/wp-content/uploads/linuxdocs/RCU.pdf

I write this note as I read the related blog and the code.
So my understanding expressed in this note is sequential.
After reading various blogs and the kernel source code,
I did reach a good conclusion and have a good understanding in the end.

## Notes

RCU is just brilliant but also painfully hard to understand in the first place.
I want to walk through how RCU is actually implemented in the kernel and take some notes (Oct 23, 2021).

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

```C
void synchronize_rcu(void)
{
	if (rcu_blocking_is_gp())
		return;  // Context allows vacuous grace periods.
	if (rcu_gp_is_expedited())
		synchronize_rcu_expedited();
	else
		wait_rcu_gp(call_rcu);
}
```

Ah, I think the RCU usage paper gives a nice high-level summary on Linux's implementaiton:

- In practice Linux implements `synchronize_rcu` by waiting for all CPUs in the system to pass through a context switch, instead of scheduling a thread on each CPU. This design optimizes the Linux RCU implementation for low-cost RCU critical sections, but at the cost of delaying synchronize_rcu callers longer than necessary. In principle, a writer waiting for a particular reader need only wait for that reader to complete an RCU critical section. The reader, however, must communicate to the writer that the RCU critical section is complete. The Linux RCU implementation essentially batches reader-to-writer communication by waiting for context switches. When possible, writers can use an asynchronous version of `synchronize_rcu`, `call_rcu`, that will asynchronously invokes a specified callback after all CPUs have passed through at least one context switch.
- The Linux RCU implementation tries to amortize the cost of detecting context switches over many `synchronize_rcu` and `call_rcu` operations. **Detecting context switches requires maintaining state shared between CPUs**. A CPU must update state, which other CPUs read, that indicate it executed a context switch. Updating shared state can be costly, because it causes other CPUs to cache miss. **RCU reduces this cost by reporting per-CPU state roughly once per scheduling clock tick**. If the kernel calls `synchronize_rcu` and `call_rcu` many times in that period, RCU will have reduced the average cost of each call to `synchronize_rcu` and `call_rcu` at the cost of higher latency. Linux can satisfy more than 1,000 calls to `synchronize_rcu` and `call_rcu` in a single batch [22]. For latency sensitive kernel subsystems, RCU provides expedited synchronization functions that execute without waiting for all CPUs to execute multiple context switches.

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


## Code Reading

This section is my note on the actual codes.
There are two possible implementations: tiny and tree. Tiny is for UP system. Tree is the most standard one. So I will be looking into `kernel/rcu/tree.c` first

My general approach to new code: 1) look top and bottom of the file.
Top usually defines some importnat global variables.
Bottom usually has the init functions, which could tell us what's going on, what threads are created etc.
Then I scroll up from bottom.

- `gp` stands for Grace Period

**Important Data Structrues and Threads**

- One global `struct rcu_state`. Init by `rcu_init_one()`. See `include/linux/rcu/tree.h` for detailed comments.
- Per CPU `struct rcu_data`.
- `struct rcu_node`
- There is thread called `rcu_gp_kthread()`, comment says this is a kthread that handles grace period. Shouldn't there be one per CPU? Why there is just one though?

**Initialization**

- `rcu_init()`
- I saw `rcutree_online_cpu()` and `rcutree_offline_cpu()`. The core seems to be the `rnp->ffmask`, the `ffmask`.
  It appears this mask represent the cpu status in RCU subsystem. Pay attention to it later.
- `rcutree_prepare_cpu()`: init per-CPU RCU data (`rcu_data`). I have no idea what those fields in rcu_data are doing. And it is re-loading quite some info from the global `rcu_state`.

**Core**

It seems `rnp->gp_seq` != `rdp->gp_seq` means a grace period is started?
Based on various functions, it appears that if they need a grace period, they will invoke the `rcu_gp_kthread()`!

Inside `rcu_gp_kthread()` it is just a big loop. It constantly sleeps. Once waken up, it will use `rcu_gp_init()` to actuallt start a grace period! Quite heavy. The core seems to be `rcu_seq_start(&rcu_state.gp_seq);`: update the `gp_seq`, the VERY variable that others use to check grace period. Think this is it. Now I still need to figure out how grace period got integrated into `synchronize_rcu`.

So inside `synchronize_rcu()`, the main thing is `wait_rcu_gp()`, seems waiting for the grace period to finish. Ah we are getting close. The `wait_rcu_gp()` takes the `call_rcu()` function as a parameter. The `call_rcu()` queues an RCU callback for invocation AFTER a grace period (YES! Makes sense. So now, we know who is creating grace period - that above kthread and where we are waiting).

For `__wait_rcu_gp()`, I don't understand much other than this complicated function callback.
```c
(crcu_array[i])(&rs_array[i].head, wakeme_after_rcu);
```

Note, if we are calling from `synchronize_rcu`, this `crcu_array[i]` is essentially `call_rcu()` function. So the above callback essentially becomes:
```c
call_rcu(&rs_array[i].head, wakeme_after_rcu);
```

In `__call_rcu`, I think the core is the following couple lines. It packages the incoming function callback and enqueue into the rcu segcblist. Not only `synchronize_rcu()` calls `call_rcu()`, any kernel code can call this to register a function to, say, free an object! Nice. Since callbacks MUST be called after it is safe to do so, meaning all CPUs have context switched. So we should find the place where callbacks are run.
```c
__call_rcu()
	...
	head->func = func;
	head->next = NULL;
	...
	rcu_segcblist_enqueue(&rdp->cblist, head);
	..
```

Now try to find the place run callbacks.
First up, examine the enqueue function. ThenIn the following func, the `rsclp->tails` caught my eye. Follow this.
```c
void rcu_segcblist_enqueue(struct rcu_segcblist *rsclp,
			   struct rcu_head *rhp)
{
	rcu_segcblist_inc_len(rsclp);
	rcu_segcblist_inc_seglen(rsclp, RCU_NEXT_TAIL);
	rhp->next = NULL;
	WRITE_ONCE(*rsclp->tails[RCU_NEXT_TAIL], rhp);
	WRITE_ONCE(rsclp->tails[RCU_NEXT_TAIL], &rhp->next);
}
```

Since someone MUST call these callbacks after grace period.
If we found that place, we will know which code represent the end of grace period.
So I search for `func` and `tails`. Bang, we are in `rcu_do_batch()`.
As you can see, it will walk through the callback list and run one by one.
Note this callbacks come from either other kernel code or rcu itself.
This callback is short, usually free the object or complete sth.
```c
/*
 * Invoke any RCU callbacks that have made it to the end of their grace
 * period.  Throttle as specified by rdp->blimit.
 */
static void rcu_do_batch(struct rcu_data *rdp)
{
	...

	/* Invoke callbacks. */
	tick_dep_set_task(current, TICK_DEP_BIT_RCU);
	rhp = rcu_cblist_dequeue(&rcl);

	for (; rhp; rhp = rcu_cblist_dequeue(&rcl)) {
		...
		f = rhp->func;
		WRITE_ONCE(rhp->func, (rcu_callback_t)0L);
		f(rhp);
		...
	}
	...
}
```

Now we should find who calls `rcu_do_batch`.
It is called by `rcu_core()` only, which is called by `rcu_cpu_kthread()`.

This `rcu_cpu_kthread()` is different from the `rcu_gp_thread` (the one who START grace period).
This function is registered via the `smpboot_regsiter_percpu_thread()` framework.
This framework creates an internal thread repeatly calling the registered callbacks.
So `rcu_cpu_kthread()` is actually running in a loop! It is just that the Loop logic is within the smpbook framework.
It runs if `rcu_data.rcu_cpu_has_work` is 1, which is only set by `invoke_rcu_core_kthread()`.
```c
/*
 * Wake up this CPU's rcuc kthread to do RCU core processing.
 */
static void invoke_rcu_core(void)
{
	if (!cpu_online(smp_processor_id()))
		return;
	if (use_softirq)
		raise_softirq(RCU_SOFTIRQ);
	else
		invoke_rcu_core_kthread();
}
```

_So, WHOEVER calls `invoke_rcu_core()` should be the one checking whether a grace period has expired!!_

The cloest caller I found is this.
The description is inline with what the RCU usage paper said. They do batch processing
every scheduling-tick. Pay attention to  `rcu_pending()`.
So `rcu_pending()` checks if there is any RCU-related work to be done. If so, call `invoke_rcu_core()` to do all the callbacks. I mean, `rcu_pending()` should mean a grace period has ended, right?
```c
/*
 * This function is invoked from each scheduling-clock interrupt,
 * and checks to see if this CPU is in a non-context-switch quiescent
 * state, for example, user mode or idle loop.  It also schedules RCU
 * core processing.  If the current grace period has gone on too long,
 * it will ask the scheduler to manufacture a context switch for the sole
 * purpose of providing the needed quiescent state.
 */
void rcu_sched_clock_irq(int user)
{
	...
	if (rcu_pending(user))
		invoke_rcu_core();
	...
}
```

Go for `rcu_pending()`.
Though it checks grace period but it appears it does not check whether it ended or not.
Maybe my fundamental understanding about the grace period impl is not correct.
```c
/*
 * Check to see if there is any immediate RCU-related work to be done by
 * the current CPU, returning 1 if so and zero otherwise.  The checks are
 * in order of increasing expense: checks that can be carried out against
 * CPU-local state are performed first.  However, we must check for CPU
 * stalls first, else we might not get a chance.
 */
static int rcu_pending(int user)
{
	...
	gp_in_progress = rcu_gp_in_progress();
	..
}

/*
 * Return true if an RCU grace period is in progress.  The READ_ONCE()s
 * permit this function to be invoked without holding the root rcu_node
 * structure's ->lock, but of course results can be subject to change.
 */
static int rcu_gp_in_progress(void)
{
	return rcu_seq_state(rcu_seq_current(&rcu_state.gp_seq));
}
```

I must have missed a lot important connections, most importantly, 
how they ensure all CPUs have experienced a context switch 
and how exactly grace period is used here, meaning how it enforce things?
I do see a lot of callback registerd and those callbacks usually are very simple,
mostly do the `complete()` call.

And the whole RCU subsystem has several data structures, `rcu_data`, `rcu_node` etc.
And several threads, `rcu_gp_kthread()`, who advances grace period. `rcu_cpu_kthread()` 
who actually run the registered callbacks from call_rcu/synchronize_rcu.

Anyway this is conclusion for me, for now (Oct 24, 2021). I might look into the userspace impl later. Nonetheless the core of `synchronize_rcu()` is fairly simple: make sure a grace period has gone (e.g., all other CPUs have context switched). But a real efficient implementation is quite complicated, esp in Linux kernel.

## After Thought

Finished code reading.

So it appears that for normal kernel code, use `call_rcu()` to register a callback is better than `synchronize_rcu()`.
The former simply register the callback (e.g., free an object) and returns. The callback will be invoked once a grace period has expired.
On the other hand, `synchronize_rcu()` is synchronize, it waits a grace period has actually passed.
For most code, this is not necessary, as most code just want to do some cleanup code, as long as it is done.
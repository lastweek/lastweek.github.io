# wait, swait, completion

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Oct 28, 2021| created |

Completion, swait, and wait are kernel APIs. They provide barrier-like semantics.
They are easy to use and simple to understand as well.

The `swait` (simple waitqueue) was added to the kernel around 2016 by Peter Zijlstra.
As the email (`git log -p kernel/sched/swait.c`) and comments in the file point out, they just want to have a simpler version 
for this frequently used data structure. The `waitqueue` has unnecessary overhead for simple use cases.

- `waitqueue` can be found in `kernel/sched/wait.c`
- `swait` can be found in `kernel/sched/swait.c`.
- `completion` can be found in `kernel/sched/completion.c`

The `swait` and `waiqueue_t` are essentially the same: they are a queue of sleeping threads.
They provide APIs for you to insert (sleep) and delete (wakeup) threads within the queue. I recommend start from swait, it is simple enough as long as you are familiar with kernel list ops.

The `completion` API essentially builds itself on top of `swait`.
The `complete()` call directly call `swake_up_locked()`.
I guess the only interesting thing is `wait_for_completion()`.

```c
static long __sched
wait_for_common(struct completion *x, long timeout, int state)
{
	return __wait_for_common(x, schedule_timeout, timeout, state);
}
```

All different flavors of wait eventually fall into the following func.
It adds the current thread into the `swait` queue, change the thread state,
then simply calls `action()` function pointer, which, in normal cases, is `schedule_timeout()`.
So this is the place a thread goes to sleep and wait for the other thread to call `complete()`.
```c
static inline long __sched
do_wait_for_common(struct completion *x,
		   long (*action)(long), long timeout, int state)
{
	if (!x->done) {
		DECLARE_SWAITQUEUE(wait);

		do {
			if (signal_pending_state(state, current)) {
				timeout = -ERESTARTSYS;
				break;
			}
			__prepare_to_swait(&x->wait, &wait);
			__set_current_state(state);
			raw_spin_unlock_irq(&x->wait.lock);
			timeout = action(timeout);
			raw_spin_lock_irq(&x->wait.lock);
		} while (!x->done && timeout);
		__finish_swait(&x->wait, &wait);
		if (!x->done)
			return timeout;
	}
	if (x->done != UINT_MAX)
		x->done--;
	return timeout ?: 1;
}
```


## References

- Documentation/scheduler/completion.rst

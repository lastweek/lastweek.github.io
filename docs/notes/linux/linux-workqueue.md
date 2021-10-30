# Linux Work Queue

Work queue is a generic async execution with shared worker pool in linux kernel. It does what is designed to do, it runs "your function" across
a set of worker threads. The subsystem is huge. As of v5.9, the `workqueue.c` has more than 6K lines of code.

The internal documentation is at `Documentation/core-api/workqueue.rst`.

Think about how would you design the thread pool and interfaces to submit work to it.
I have designed one in LegoOS. The basic infrastructure is not hard, basically playing around various queues.
The tricky part is to get the concurrency right, and various corner cases.
Also, NUMA affinity, multiple thread pools etc features add more complexity.
But the important thing is to understand the core!

Public APIs

- `alloc_workqueue()`
- `queue_work()`

## Key Data Structures and Functions

Data Structures

- `struct work_struct`, the work item, including the func
- `struct worker`, the actual worker thread
	- has a `struct task_struct *task`
- `struct worker_pool`, multiple workers can form a pool

- So it looks like there 2 worker pools per cpu, and it is accessed by macro. But can we create more pools?
```c
NR_STD_WORKER_POOLS = 2
/* the per-cpu worker pools */
static DEFINE_PER_CPU_SHARED_ALIGNED(struct worker_pool [NR_STD_WORKER_POOLS], cpu_worker_pools);


#define for_each_cpu_worker_pool(pool, cpu)				\
	for ((pool) = &per_cpu(cpu_worker_pools, cpu)[0];		\
	     (pool) < &per_cpu(cpu_worker_pools, cpu)[NR_STD_WORKER_POOLS]; \
	     (pool)++)
```

- `workqueues` is a list of all workqueues
```c
static LIST_HEAD(workqueues);		/* PR: list of all workqueues */
```

### Create workers

The first is I want to understand is how workers are created,
and how many of them are created. I think I will do a bottom-up
fashion instead of top-down. So I started from the function
to create a single worker, then I check who calls it.

The `create_worker()` - creates a worker thread.
The steps are straightforward. Calling into `kthread_create`,
attach it to a `worker_pool`. So this is how worker and pool got connected.
```c
static struct worker *create_worker(struct worker_pool *pool)
{
...

	worker->task = kthread_create_on_node(worker_thread, worker, pool->node,
					      "kworker/%s", id_buf);


	/* successful, attach the worker to the pool */
	worker_attach_to_pool(worker, pool);


	/* start the newly created worker */
	raw_spin_lock_irq(&pool->lock);
	worker->pool->nr_workers++;
	worker_enter_idle(worker);
	wake_up_process(worker->task);
	raw_spin_unlock_irq(&pool->lock);
...
}
```

The `worker_attach_to_pool()` is quite simple, just some list op.
```c
	list_add_tail(&worker->node, &pool->workers);
	worker->pool = pool;
```


Okay, now I want to see who calls `create_worker()`.
It is a static function, so only called within this file. Cool.

First off, it is called by `workqueue_init()`, during startup.
So here looks like it is creating a worker for the per-cpu pools (2 pools per cpu).
What are those workers for though?
```c
void __init workqueue_init(void)
{
...
	/* create the initial workers */
	for_each_online_cpu(cpu) {
		for_each_cpu_worker_pool(pool, cpu) {
			pool->flags &= ~POOL_DISASSOCIATED;
			BUG_ON(!create_worker(pool));
		}
	}

	hash_for_each(unbound_pool_hash, bkt, pool, hash_node)
		BUG_ON(!create_worker(pool));
...
}
```

Anyways, it is also called within `workqueue_prepare_cpu()`, which is a callback
for cpu hotplug. Skip. Also called by `maybe_create_worker()`, which seems to be called
within worker thread itself to create another worker within a pool.
I'm not sure whether the initial workers we created in `workqueue_init()` will create those
during runtime..

Anyways, the final caller is `get_unbound_pool()`. Looks promising.
It does says `start the initial worker`. So follows the caller of `get_unbound_pool()`.
```c
/**
 * get_unbound_pool - get a worker_pool with the specified attributes
 * @attrs: the attributes of the worker_pool to get
 ..
 */
static struct worker_pool *get_unbound_pool(const struct workqueue_attrs *attrs)
{
	...
	/* create and start the initial worker */
	if (wq_online && !create_worker(pool))
		goto fail;
	...
}
```

The `get_unbound_pool()` is called by `alloc_unbound_pwq()` only.
It seems to be creating `struct pool_workqueue`.
This structure, seems a wrapper around `struct worker_pool`?

Okay, seem this is it. I'm going to do top-down.
Start from the public API.
`apply_workqueue_attrs()` is easy to understand.
It gots the workqueue entry and some attributes and then do some work based on that.

I just want to understand what will be created if one calls `alloc_workqueue`.
Well, it looks like inside `apply_wqattrs_prepare()`, it is looping over nodes.
So it appears end of the day, it is one create_worker per node?
I thought it is per cpu? Well, I could try it out and see.

```c
alloc_workqueue()				- Public API
  -> alloc_and_link_pwqs(struct workqueue_struct *wq)
	-> apply_workqueue_attrs(workqueue_struct, workqueue_attrs)
		-> apply_workqueue_attrs_locked(workqueue_struct, workqueue_attrs)
			-> apply_wqattrs_prepare() *****
				-> alloc_unbound_pwq()
					-> get_unbound_pool()
						-> create_worker()
```

## TODO
I need to try it out.

## References

- https://events.static.linuxfound.org/sites/events/files/slides/Async%20execution%20with%20wqs.pdf 

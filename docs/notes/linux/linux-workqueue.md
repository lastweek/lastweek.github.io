# Linux Work Queue

Work queue is a generic async execution with shared worker pool in linux kernel. It does what is designed to do, it runs "your function" across
a set of worker threads. The subsystem is huge. As of v5.9, the `workqueue.c` has more than 6K lines of code.

The internal documentation is at `Documentation/core-api/workqueue.rst`.

APIs

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

## Workflow


## References


- https://events.static.linuxfound.org/sites/events/files/slides/Async%20execution%20with%20wqs.pdf 

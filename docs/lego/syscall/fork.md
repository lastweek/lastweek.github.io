# fork()

## Entry Points
- `fork()`
- `vfork()`
- `clone()`
- `kernel_thread()`

All of them land on `do_fork()`, which is Lego's main fork function.

## do_fork()

There are mainly three parts within `do_fork()`: `1)` `copy_process()`, which duplicates a new task based on `current`, including allocate new kernel stack, new task_struct, increase mm reference counter, etc. `2)` If we are creating a new process, then tell global monitor or memory manager to let them update bookkeeping and create corresponding data structures. `3)` `wake_up_new_task()`, which gives away the newly created task to local scheduler.

### copy_process()
The routine is kind of boring. It do a lot dirty work to copy information from calling thread to new thread. The most important data structures of course are `task_struct`, `mm_sturct`, `sighand`, and so on. This section only talks about few of them, and leave others to readers who are interested.

#### Sanity Checking
Mainly check if `clone_flags` are passed properly. For example, if user is creating a new thread, that implies certain data structures are shared, cause new thread belongs to the same process with the calling thread. If `CLONE_THREAD` is passed, then `CLONE_SIGHAND`, `CLONE_VM`, and so on must be set as well.
```c
	/*
	 * Thread groups must share signals as well, and detached threads
	 * can only be started up within the thread group.
	 */
	if ((clone_flags & CLONE_THREAD) && !(clone_flags & CLONE_SIGHAND))
		return ERR_PTR(-EINVAL);

	/*
	 * Shared signal handlers imply shared VM. By way of the above,
	 * thread groups also imply shared VM. Blocking this case allows
	 * for various simplifications in other code.
	 */
	if ((clone_flags & CLONE_SIGHAND) && !(clone_flags & CLONE_VM))
		return ERR_PTR(-EINVAL);

```

#### dup_task_struct()
Two main things: 1) duplicate a new `task_struct`, 2) duplicate a new kernel stack. x86 is just a weird architecture, the size of `task_struct` depends on the size of fpu. So the allocation and duplication need to callback to x86-specific code to duplicate the task_struct and fpu info.
```c
int arch_dup_task_struct(struct task_struct *dst, struct task_struct *src)
{
	memcpy(dst, src, arch_task_struct_size);

	return fpu__copy(&dst->thread.fpu, &src->thread.fpu);
}
```
The stack duplication is fairly simple, just copy everything from the old stack to new stack. Of course, it needs to setup the `thread_info` to points to this new thread, so the `current` macro will work.
```c
static void setup_thread_stack(struct task_struct *p, struct task_struct *org)
{
        /* Duplicate whole stack! */
        *task_thread_info(p) = *task_thread_info(org);

        /* Make the `current' macro work */
        task_thread_info(p)->task = p;
}
```

#### copy_mm()
This is where threads within a process will share the virtual address space happens. If we are creating a new process, then this function will create a new `mm_struct`, and also a new `pgd`:
```c
/*
 * pgd_alloc() will duplicate the identity kernel mapping
 * but leaves other entries empty:
 */
mm->pgd = pgd_alloc(mm);
if (unlikely(!mm->pgd)) {
        kfree(mm);
        return NULL;
}
```

???+ danger "TODO: hook with pcache"
    We need to duplicate the pcache vm_range array, once Yutong finished the code.

#### setup_sched_fork()
Callback to scheduler to setup this new task. It may reset all scheduler related information. Here we also have a chance to change this task's scheduler class:

```c
int setup_sched_fork(unsigned long clone_flags, struct task_struct *p)
{
        int cpu = get_cpu();

        __sched_fork(clone_flags, p);

        p->state = TASK_NEW;
        ...
        if (unlikely(p->sched_reset_on_fork)) {
                if (task_has_rt_policy(p)) {
                        p->policy = SCHED_NORMAL;
                        p->static_prio = NICE_TO_PRIO(0);
                        p->rt_priority = 0;
                } else if (PRIO_TO_NICE(p->static_prio) < 0)
                        p->static_prio = NICE_TO_PRIO(0);

                p->prio = p->normal_prio = __normal_prio(p);
                set_load_weight(p);
                ...
        }    

        if (rt_prio(p->prio))
                p->sched_class = &rt_sched_class;
        else {
                p->sched_class = &fair_sched_class;
                set_load_weight(p);
        }    

        __set_task_cpu(p, cpu);
        if (p->sched_class->task_fork)
                p->sched_class->task_fork(p);

        ...
}
```

#### Allocate new pid
In both Lego and Linux, we don't allocate new pid for a new thread, if that thread is an `idle thread`. So callers of `do_fork` needs to pass something to let `do_fork` know. In Linux, they use `struct pid, init_struct_pid` to check. In Lego, we introduce an new clone_flag `CLONE_IDLE_THREAD`. If that flag is set, `do_fork()` will try to allocate a new pid for the new thread. Otherwise, it will be 0:
```c
/* clone idle thread, whose pid is 0 */
if (!(clone_flags & CLONE_IDLE_THREAD)) {
        pid = alloc_pid(p);
        if (!pid)
                goto out_cleanup_thread;
}
```

So, only the `init_idle()` function can pass this `CLONE_IDLE_THREAD` down. All other usages are wrong and should be reported.

In order to avoid conflict with Linux clone_flag, we define it as:
```c
#define CLONE_IDLE_THREAD       0x100000000
```

#### SETTID/CLEARTID
These are some futex related stuff. I will cover these stuff in futex document:
```c
p->set_child_tid = (clone_flags & CLONE_CHILD_SETTID) ? child_tidptr : NULL;
/*  
 * Clear TID on mm_release()?
 */
p->clear_child_tid = (clone_flags & CLONE_CHILD_CLEARTID) ? child_tidptr : NULL;

#ifdef CONFIG_FUTEX
p->robust_list = NULL;
#endif
```

#### copy_thread_tls()
This is the most interesting function. Cover later.

### p2m_fork()
In order to track user activities, we need to know when user are going to create new process. Fork is the best time and the only time we kernel know. So, Lego adds this special hook to tell remote global monitor or memory manager that there is a new process going to be created. Upon receiving this message, remote monitor will update its bookkeeping for this specific user/vNode.

```c
/* Tell remote memory component */
#ifdef CONFIG_COMP_PROCESSOR
if (clone_flags & CLONE_GLOBAL_THREAD) {
        ...
        p2m_fork(p, clone_flags);
        ...
}   
#endif
```

The `CLONE_GLOBAL_THREAD` should only be set, if the following cases happen:

- fork()
- vfork()
- clone(), without `CLONE_THREAD` being set

In order to avoid conflict with Linux clone_flag, we define it as:
```c
#define CLONE_GLOBAL_THREAD     0x200000000
```

### wake_up_new_task()
The last step of `do_fork` is waking up the new thread or process, which is performed by `wake_up_new_task()` function. The first question this function will ask is: `which cpu to land?` The answer comes from `select_task_rq()`:

```c
static inline
int select_task_rq(struct task_struct *p, int cpu, int sd_flags, int wake_flags)
{
        if (p->nr_cpus_allowed > 1)
                cpu = p->sched_class->select_task_rq(p, cpu, sd_flags, wake_flags);
        else
                cpu = cpumask_any(&p->cpus_allowed);
        ...
}
```

Clearly, this is determined by `cpus_allowed`, which is the same with its parent at this point. That being said, if the parent is only able to run on one specific CPU, then all its children will end up running on the same CPU when they wake up (they could change their affinity later). This is also the default on Linux: `A child created via fork(2) inherits its parent's CPU affinity mask. The affinity mask is preserved across an execve(2).`

After landing CPU is selected, following operation is simple: just enqueue this task into landing CPU's runqueue, and we are done:

```c
void wake_up_new_task(struct task_struct *p)
{
        ...
/* Select a CPU for new thread to run */
#ifdef CONFIG_SMP
        /*   
         * Fork balancing, do it here and not earlier because:
         *  - cpus_allowed can change in the fork path
         *  - any previously selected cpu might disappear through hotplug
         */
        set_task_cpu(p, select_task_rq(p, task_cpu(p), SD_BALANCE_FORK, 0));
#endif

        rq = __task_rq_lock(p);
        activate_task(rq, p, 0);
        p->on_rq = TASK_ON_RQ_QUEUED;
        ...
}
```

--  
Yizhou Shan  
Created: Feb 11, 2018  
Last Updated: Feb 19, 2018

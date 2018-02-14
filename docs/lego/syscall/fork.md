# fork()

## Entry Points
- `fork()`
- `vfork()`
- `clone()`
- `kernel_thread()`

All of them land on `do_fork()`, which is Lego's main fork function.

## do_fork()

There are mainly three parts within `do_fork()`: `1)` `copy_process()`, which duplicates a new task based on `current`, including allocate new kernel stack, new task_struct, increase mm reference counter, etc. `2)` If we are creating a new process, then tell global monitor or memory manager to let them update bookkeeping and create corresponding data structures. `3)` `wake_up_new_task()`, which gives away the newly created task to local scheduler.

### 1) copy_process()
This is a fairly long and complex function, thus I will mainly walk through important and interesting parts.

#### dup_task_struct()
todo

#### copy_thread_tls()
todo

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

### 2) p2m_fork()
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

### 3) wake_up_new_task()
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
Feb 11, 2018

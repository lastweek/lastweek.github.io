# The highest priority thread in kernel

This document is about `migration/N` kernel threads, `stop_sched` schdueling class, and the interesting source file `kernel/stop_machine.c`. Background on kernel scheduler design is recommended.

Scheduler uses the following code to pick the next runnable task:
```c
static inline struct task_struct *
pick_next_task(struct rq *rq, struct task_struct *prev)
{
        struct task_struct *p;
        const struct sched_class *class;

again:
        for_each_class(class) {
                p = class->pick_next_task(rq, prev);
                if (p) {
                        if (unlikely(p == RETRY_TASK))
                                goto again;
                        return p;
                }    
        }
        BUG();
}
```

while the class is linked together as:
```c
#define sched_class_highest     (&stop_sched_class)                                                       
#define for_each_class(class) \                                                                           
   for (class = sched_class_highest; class; class = class->next)
```

Clearly, the highest priority class is `stop_sched_class`. Whenever this scheduling has class runnable threads, scheduler will always run them first. So what kernel threads are using this scheduling class? Well, you must have seen something like `migration/0` when you do `ps aux` in Linux. And yes, these kernel threads are the only users.

These threads are sleeping most of their lifetime, they will be invoked to do some very urgent stuff. For example, when a user thread that is currently running on CPU0 calls `sched_setaffinity()` to bind to CPU1, kernel is not able to do this because this user thread is currently running (runqueue can not move a *running* task out, it can only move queued task out). Then, scheduler has to ask `migration/0` for help. Once there is a job enqueued, `migration/0` will be invoked. Since it has the highest-priority, it will start execution immediately. Thus the migration from CPU0 to CPU1 is performed safely and fast.

`migration` code is defined in `kernel/stop_machine.c`. They are created during early boot. They use the `smpboot_register_percpu_thread` to create threads. They are written in this way because Linux supports cpu hotplug. To simplify we can also create them manually through `kthread_create`. Since Lego does not support cpu hotplug, and this `cpu_stop_init` is called after SMP is initialized, so Lego has slight different initialiaztion:
```c
void __init cpu_stop_init(void)
{
        unsigned int cpu;

        for_each_possible_cpu(cpu) {
                struct cpu_stopper *stopper = &per_cpu(cpu_stopper, cpu);

                spin_lock_init(&stopper->lock);
                INIT_LIST_HEAD(&stopper->works);
        }

        BUG_ON(smpboot_register_percpu_thread(&cpu_stop_threads));

        /*
         * smpboot_create_threads use kthread_create_on_cpu() to
         * create new threads. And they are parked, too.
         * Since we call this function after smp_init(), all CPUs
         * are already online, thus we need to unpark them manually.
         */
        for_each_online_cpu(cpu)
                stop_machine_unpark(cpu);

```

Internally, it also use a list to keep enqueued jobs. Once the thread is waken up, it tries to lookup this list and dequeue jobs (similar to kthread creation, kworker etc.):
```c
static void cpu_stopper_thread(unsigned int cpu)
{
        struct cpu_stopper *stopper = &per_cpu(cpu_stopper, cpu);
        struct cpu_stop_work *work;

repeat:
        work = NULL;
        spin_lock_irq(&stopper->lock);
        if (!list_empty(&stopper->works)) {
                work = list_first_entry(&stopper->works,
                                        struct cpu_stop_work, list);
                list_del_init(&work->list);
        }   
        spin_unlock_irq(&stopper->lock);

        if (work) {
                ...
                ret = fn(arg);
                ...
                goto repeat;
        }   
}
```

It has several interesting public APIs that are quite similar to `smp_call_functions`, but the difference is: this set of APIs provide a guaranteed time-to-execute waiting time, because it will simply preempt anything running on CPU.

```c
int stop_one_cpu(unsigned int cpu, cpu_stop_fn_t fn, void *arg);
int stop_cpus(const struct cpumask *cpumask, cpu_stop_fn_t fn, void *arg);
int try_stop_cpus(const struct cpumask *cpumask, cpu_stop_fn_t fn, void *arg);
```

They are used only when there are some very urgent things to do. So, please use with caution.

--  
Yizhou Shan  
Feb 12, 2018

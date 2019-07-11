# Hiding In The Performance Shadows

:vertical_traffic_light:

There are shadows under the sun.  
There are shadows in your life.  
There are shadows in your computer.  

This note is about latency tolerance techniques,
ranging from nanoseconds to seconds. We will look at some
interesting academic ideas.

## Nanoseconds

Architecture solutions to attack nanosecond-level performance shadows
that are mostly created by lower level data and instruction cache misses.
OoO and SMT are the base to hide these latencies, but they fall short
when ROB is full (or some other reasons).
When that happens, these academic ideas come in rescue.

### Runahead

**Quote**
> *"In runahead, once the processor stalls, it uses the instruction window to
> continue to fetch and execute operations. The goal of runahead is to generate
> new cache misses, thereby turning subsequent demand requests into cache hits
> instead of cache misses.[5]"*

**Papers**

1. Improving Data Cache Performance by Pre-executing Instructions Under a Cache Miss, ICS’97
2. Runahead Execution: An Alternative to Very Large Instruction Windows for Out-of-order Processors, HPCA’03
3. Efficient Runahead Execution: Power-Efficient Memory Latency Tolerance, IEEE Micro’06
    - Good timeline graphs show the benefit of Runahead.
4. Runahead Threads to Improve SMT Performance, HPCA’08
    - QoS control policy.
5. Continuous Runahead: Transparent Hardware Acceleration for Memory Intensive Workloads, MICRO’16
    - Nice idea to tackle the issue that runahead does not get enough time to run.
    - Also has the notion of ideal runahead coverage.

**Comments**

- We should separate mechanism and policy.
- Runahead is the mechanism. It includes:
    - Enter runahead
    - Execution in runahead context (most important thing is to maintain those INV bits and pseudo-retires)
    - Exit runahead
- Prefetch is one of the policy, a major one. It's the side effect of running instructions in the execution phase of runahead mode.
- QoS control is another policy. This means adding specific rules to the execution phase. More specifically: limit the core resource usage of the runahead thread, thus reduce the impact on the co-running HW thread.


### Helper Threads (or Precomputation)

**Quote**
> *"Precomputation uses idle thread contexts in a multithreaded architecture
> to improve performance of single-threaded applications.
> It attacks program stalls from data cache misses by
> pre-computing future memory accesses in available thread
> contexts, and prefetching these data.[1]"*

> *"Such pre-execution threads are
> purely speculative, and their instructions are never committed
> into the main computation. Instead, the pre-execution
> threads run code designed to trigger cache misses. As long
> as the pre-execution threads execute far enough in front of
> the main thread, they effectively hide the latency of the
> cache misses so that the main thread experiences signicantly fewer memory stalls.[5]"*


**Papers**

1. Speculative Precomputation: Long-range Prefetching of Delinquent Loads, ISCA'01
2. *Dynamic* Speculative Precomputation, Micro'01
    - Take a step further by using HW to construct the offloaded code slice automatically.
3. Execution-based Prediction Using Speculative Slices, ISCA'01
4. Tolerating Memory Latency through *Software-Controlled* Pre-Execution in Simultaneous Multithreading Processors, ISCA'01
    - What's up with ISCA'01? This paper proposed to use software to control
    when to start running precomputation and when to exit. It uses compiler's
    help to generate those code slices, and insert special start/end instructions.
    On the contrast, hardware-controller precomputation relies on hints such
    as cache misses.
5. Design and Evaluation of Compiler Algorithms for PreExecution, ASPLOS'02
    - 5.1 A Study of Source-Level Compiler Algorithms for Automatic Construction of Pre-Execution Code, TOCS'04
6. Dynamic Helper Threaded Prefetching on the Sun UltraSPARC® CMP Processor, Micro'05
    - The **function table** at helper thread seems nice and useful.
7. Accelerating and Adapting Precomputation Threads for Effcient Prefetching, HPCA'07
    - Dynamically construct precomputation code, called p-slices. They can adapt
    the same program differently depending on the program's data input and the underlying
    hardware architecture.
8. Inter-core Prefetching for Multicore Processors Using Migrating Helper Threads, ASPLOS'11
9. Bootstrapping: Using SMT Hardware to Improve Single-Thread Performance, ASPLOS'19

**Comments**

- The catch about precomputation is that it must create lightweight threads
  that can actually proceed faster than the main thread, so that they
  stay out in front.
- Also, same thing here, we should separate mechanisma and policies.
  Helper thread (or precomputation) is mainly used as a vehicle
  for speculatively generating data addresses and prefetching.

### Put it all together

- Both runahead and helper thread were proposed to do prefetch.
  But they have a key difference. Runahead is invoked in the *same core*, and is invoked
  when ROB is full (not always though). Helper thread is invoked at *another core*.
- For runahead, it can just fetch the instructions and run, no need to cook another code snipppt.
  For helper thread, it needs to extract a code slice that will run on another core.

## Microseconds

Fill me in

## Milliseconds

Fill me in.


--  
Yizhou Shan  
Created: Jul 11, 2019  
Last Updated: Jul 11, 2019

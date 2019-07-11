# Hiding In The Performance Shadows

:vertical_traffic_light:

There are shadows under the sun.
There are shadows in your life.
There are shadows in your computer.

### Nanosecond

## Runahead

“In runahead, once the processor stalls, it uses the instruction window to continue to fetch and execute operations. The goal of runahead is to generate new cache misses, thereby turning subsequent demand requests into cache hits instead of cache misses.”

Papers
- Improving Data Cache Performance by Pre-executing Instructions Under a Cache Miss, ICS’97
- Runahead Execution: An Alternative to Very Large Instruction Windows for Out-of-order Processors, HPCA’03
- Efficient Runahead Execution: Power-Efficient Memory Latency Tolerance, IEEE Micro’06
  - Good timeline graphs show the benefit of Runahead.
- Runahead Threads to Improve SMT Performance, HPCA’08
  - QoS control policy.
- Continuous Runahead: Transparent Hardware Acceleration for Memory Intensive Workloads, MICRO’16
  - A nice read by itself.

In a mechanism and policy separation view:
- Runahead is the mechanism, which includes `a)` enter runahead, `b)` execution in runahead context (most important thing is to maintain those INV bits and pseudo-retires), `c)` exit runahead.
- Prefetch is one of the policy, a major one. It's the side effect of running instructions in the execution phase of runahead mode.
- QoS control is another policy. This means adding specific rules to the execution phase. More specifically: limit the core resource usage of the runahead thread, thus reduce the impact on the co-running HW thread.


### Helper Threads

Fill me in

## Microsecond

Fill me in

## Millisecond

Fill me in.

--
Yizhou Shan
Created: Jul 11, 2019
Last Updated: Jul 11, 2019
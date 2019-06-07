# Measure user/kernel space crossing overhead

This [repo](https://github.com/lastweek/linux-xperf-4.19.44) can help us
to measure the pure user/kernel space crossing overhead in CPU cycles.

The mechanism is described in its README. Check it out!

Some quick takeaways:
- It ain't cheap! It usually take ~400 cycles from user to kernel space.
- User-to-kernel crossing is more expansive than kernel-to-user crossing!
- Virtilization adds more overhead

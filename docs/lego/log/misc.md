# MISC

- `/etc/ld.so.preload`: GLIBC uses `access()` to check if this file exist (normally it does not exist)[^1]. This is something related to `LD_PRELOAD`: If both `LD_PRELOAD` and `/etc/ld.so.preload` are employed, the libraries specified by `LD_PRELOAD` are preloaded first. /`etc/ld.so.preload` has a system-wide effect, causing the specified libraries to be preloaded for all programs that are executed on the system[^2].

- I was reading a FAST18 paper (Fail-Slow Datacenter). I found it quite interesting and some suggestions are very useful for all system designers. Especially:
    - __Make implicit error-masking explicit. DO NOT FAIL SILENTLY__. Since this is not a fail-stop (__binary__) issue, normally system designers will not raise exceptions. System designers should be aware of uncommon situations, raise explicit exceptions to convert a fail-slow (__non-binary__) case to a fail-stop (__binary__) case .Actually, this also reminds the email by Linus Torvards on BUG_ON usage[^3].
    - __Exposing performance statistic information for all-level (device, firmware, system software, application)__. However, based on my own experience, do not generate too much useless logs, it will just help to hide the root cause.

- Testing of applications is often done on a testing environment, smaller in size (perhaps only a single server) and less loaded than the "live" environment. The replication behavior of such an installation may differ from a live environment in ways that mean that replication lag is unlikely to be observed in testing - masking replication-sensitive bugs.

- mmap `PROT_NONE` is really used by applications, or library. They have their special usage.

[^1]: [etc/ld.so.preload](https://unix.stackexchange.com/questions/282057/what-would-suddenly-cause-programs-to-read-etc-ld-so-preload-when-they-start-up)

[^2]: [ld.so.8.html](http://man7.org/linux/man-pages/man8/ld.so.8.html)

[^3]: [LKML:BUG_ON](https://lkml.org/lkml/2016/10/4/337)

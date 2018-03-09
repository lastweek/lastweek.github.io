# MISC

- `/etc/ld.so.preload`: GLIBC uses `access()` to check if this file exist (normally it does not exist)[^1]. This is something related to `LD_PRELOAD`: If both `LD_PRELOAD` and `/etc/ld.so.preload` are employed, the libraries specified by `LD_PRELOAD` are preloaded first. /`etc/ld.so.preload` has a system-wide effect, causing the specified libraries to be preloaded for all programs that are executed on the system[^2].

[^1]: [etc/ld.so.preload](https://unix.stackexchange.com/questions/282057/what-would-suddenly-cause-programs-to-read-etc-ld-so-preload-when-they-start-up)

[^2]: [ld.so.8.html](http://man7.org/linux/man-pages/man8/ld.so.8.html)

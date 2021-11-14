# gVisor Case Study

gVisor is an application kernel to run container jobs.
It is like a library OS. It intercept syscalls made into Linux kernel
and implement almost everything in userspace. Of course, since gVisor
itself is still running as a user program in Linux, gVisor will interact
with Linux kernel. In other words, gVisor interact with Linux kernel on application's behalf.

Why gVisor? It is result of the perf & security trade-off between VM and container.
To use VM, we have native perf and limited security exposure, most things are protected by hardware. But the downside is the slow start time and simply too heavy.
Container is lightweight, you can deploy code directly.
However, all containers share the underlying Linux kernel.
So the security exposure space is much much large, it is the whole Linux
kernel! And in fact, kernel does have a lot of security issues.
That's why gVisor wants to take things into their own hand.
By using gVisor and sandboxing apps using their library/app kernel,
most of the OS functionalties are built into app's own domain,
will not affect others. So the shared surface is smaller.

It is interesting that gVisor comes out from May 2018.
And the MIT Biscuit go-based OS comes out around Oct 2018.
Both are using Go to write OS functionalties.

## Resources

They have a good explanation on their architecture [here](https://gvisor.dev/docs/).

Also, check out [The True Cost of Containing: A gVisor Case Study, HotClou'19](https://www.usenix.org/conference/hotcloud19/presentation/young).

## Note

Source code is https://github.com/google/gvisor.

I actually not particular sure where should I start.
We don't really need to understand gVisor in order to use it though.

I decided to run it. I followed the docker+gVisor quick start guide.
So apparently, docker can use gVisor instead of Linux to launch the container.
We explicitly use the `runsc` runtime from gVisor.
After the container is started, I run dmesg. It looks interesting.
Same for files under `/proc`. Everything is emualted by gVisor.
```bash
docker run --runtime=runsc --rm -it ubuntu /bin/bash
```

```
root@59e9ca6d20a2:/proc# dmesg
[    0.000000] Starting gVisor...
[    0.461512] Waiting for children...
[    0.882428] Searching for socket adapter...
[    1.224004] Gathering forks...
[    1.310421] Consulting tar man page...
[    1.542386] Committing treasure map to memory...
[    1.648830] Feeding the init monster...
[    1.910484] Letting the watchdogs out...
[    2.316306] Mounting deweydecimalfs...
[    2.734728] Creating process schedule...
[    3.013152] Generating random numbers by fair dice roll...
[    3.351471] Setting up VFS2...
[    3.508762] Ready!

```
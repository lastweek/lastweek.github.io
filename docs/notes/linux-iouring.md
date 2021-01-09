# Linux io_uring

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Jan 8, 2021| Initial|

It has been two years since io_uring was added into mainline kernel.
Over this short course, io_uring has grown a lot.
The idea of using kernel, or even building kernel in an async way,
ryhthms with a research idea I had, that's why I have always kept
an eye on the development of io_uring.

Nonetheless, I'm not sure how real world softwares are picking it up.
The io_uring introduced a set of new APIs and we have to rewrite
applications to take advantage of its benefits.
Although it may have performance benefits, this may prevent a wider
adoption.

Some argue there is nothing new about io_uring.
I partially agree.
It is a common practice to use rings to bridge multiple communicating
parties, or to realize async ops.
But actually implement the feature for syscalls is challenging.

There are not too many stuff out there,
you will mostly come across the following writeups:
1) [Ringing in a new asynchronous I/O API](https://lwn.net/Articles/776703/)
2) [The rapid growth of io_uring](https://lwn.net/Articles/810414/)

There is user library called [liburing](https://github.com/axboe/liburing) to ease the use of io_ring.

The kernel code is `fs/io_uring.c`. Such a big file. Bad practice.

I think the whole io_uring thing is worth checking out.
And you should think about what you can further do about it.
I think it has great potentials.

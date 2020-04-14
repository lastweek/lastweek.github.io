# On READ_ONCE and Compiler Opts

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Apr 13, 2020| Initial Version|


I decide to write this blog after I once again got tricked by GCC optimizations.
I was designing a simple single-producer-single-consumer ring buffer.
Since there is a small time gap between slot-being-allocated and slot-being-usable (i.e., data filled),
the producer will set a non-atomic flag once the data is filled thus usable.
The consumer, running on a seperate CPU, will repeatly checking the usable flag
after it has grabbed the slot.

Simple, right? Yet I ran into a lot random stuck during testing.
I didn't even check the ring buffer design as I was so confident.
There was no timeout checking either. After some digging,
I realized I missed using `READ_ONCE` when consumer thread is polling for the usable flag.

Yeah, once again, `gcc -O2` tricked me:
it will optmize away repeated memory accesses
if it thinks the accessed variable/data is thread-local.
For instance, the following code snippet shows how gcc -O2 removes the memory access part.
Without -O2, a simple assembly loop is generated. With -O2, gcc generates a deadlock itself.

``` c
          Original C                        Assembly                 Assembly
                                            (gcc -S)               (gcc -S -O2)
int x;                           |                            |
                                 | .L2:                       | .L2:
/* Spin until x becomes true */  |     movl    x(%rip), %eax  |     jmp .L2
void wait_for_x(void)            |     cmpl    $1, %eax       |
{                                |     je      .L2            |
        while (x == 1)           |                            |
                ;                |                            |
}                                |                            |
```

*Why this is happening?* Because gcc thinks vairable `x` is thread-local and will not be accessed
by multiple threads at the same time. Thus gcc thinks the above `while (x == 1) ;` check will never break,
so generating an assembly deadlock jmp loop.

*Why does this matter?* Assume `x` is a shared variable.
In the following code snippet, there are two threads, A and B.
Thread A wait until B change `x` to 1.
If we compile with -O2, thread A will deadlock.
And this was my bug above.

```c
int x; /* a global shared variable*/

           Thread A                         Thread B

/* Spin until x becomes true */  |   /* Set x at some point */
void wait_for_x(void)            |   x = 1;
{                                | 
        while (x == 1)           | 
                ;                | 
}                                | 
```

The common approach, is to add `volatile` modifier, to explicitly express the concurrency issue.
But [volatile is considered harmful](https://github.com/torvalds/linux/blob/master/Documentation/process/volatile-considered-harmful.rst) by linux kernel, and I agree with it.

I generally use `READ_ONCE`, `WRITE_ONCE`, `ACCESS_ONCE` macros.
They "tell" gcc that the particualr variable is a shared global variable,
thus for each time a C statment is running, the variable should be accessed once and exactly once.
The fix for above case is: `while (READ_ONCE(x == 1)) ;`.

I will not go into details about why and how those macros are implemented.
For more information, refers to [source code](https://github.com/torvalds/linux/blob/master/include/linux/compiler.h#L182), [ktsan wiki](https://github.com/google/ktsan/wiki/READ_ONCE-and-WRITE_ONCE).

Hope you enjoyed this simple bug-documentation blog.

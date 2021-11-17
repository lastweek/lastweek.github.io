# Go


??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Nov 5, 2021| Initial|

:sailboat:

I decided to learn Go and use it build some sample projects.
I may just start from a simple webserver.
Since Go is used a lot in virtualization part (e.g., Docker, gVisor)
and databases (mangoDB?), I'm thinking of doing along that line as well.

The learning code will be pushed into https://github.com/lastweek/learn-go.

## Resources

- [awesome-go](https://awesome-go.com/)
- [gVisor](https://github.com/google/gvisor)

## Notes

**Function call pass by value or reference**

For function call, the following are passed by value: a) struct b) basic data type (e.g., int).
So the function receives a copy of each argument; modifications to the copy do not affect the caller.
However, the following are pointer like: pointers (to struct, int), slice, map, function, or channel.
The caller may be affected by any modifications the function makes to variable *indirectly* referred to by the argument.
(Some testing code here https://github.com/lastweek/learn-go/blob/master/playground/datatypes.go)

**Defer**

Defer is one of my favorite featues of Go.
I have bad memories on maintaining the error handling code in C,
especially in kernel: I have to carefully order the error handling
code at the end of function, have proper labels and write proper goto.
Here, `defer` elegantly solves this complex error handling issue.

**Goroutine**

Stack: a goroutine usually has a small stack typically 2KB. But unlike
an OS thread, a goroutine's stack is not fixed; it grows and shrinks as needed.
It could beas much as 1GB.

Scheduling: what's the policy there? Does the runtime use some sort of timer if user code is
not giving up control? It is an M:N scheduler. Some internal documentation: https://github.com/golang/go/blob/master/src/runtime/HACKING.md

## Go Runtime

The source code is here under this directory [src/runtime](https://github.com/golang/go/tree/master/src/runtime).
A huge directory with a lot of files. Why not create more subdirectories to better organize all these files?

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

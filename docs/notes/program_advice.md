# Programming Advice

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Mar 28, 2020| Started. |

## FreeBSD

[Source](https://www.freebsd.org/doc/en_US.ISO8859-1/books/developers-handbook/introduction-archguide.html).

Our ideology can be described by the following guidelines:

- Do not add new functionality unless an implementor cannot complete a real application without it.
- It is as important to decide what a system is not as to decide what it is. Do not serve all the world's needs; rather, make the system extensible so that additional needs can be met in an upwardly compatible fashion.
- The only thing worse than generalizing from one example is generalizing from no examples at all.
- If a problem is not completely understood, it is probably best to provide no solution at all.
- If you can get 90 percent of the desired effect for 10 percent of the work, use the simpler solution.
- Isolate complexity as much as possible.
- Provide mechanism, rather than policy. In particular, place user interface policy in the client's hands.

From Scheifler & Gettys: "X Window System"

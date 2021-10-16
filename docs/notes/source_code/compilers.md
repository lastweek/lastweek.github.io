# Compilers

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Oct 16, 2021| Move compilers section from the summary file |

The general ones:

- [Clang, LLVM, in C++](https://github.com/llvm/llvm-project)
	- This is a collection of projects. Clang is the frontend,
	compiles C/C++ code into LLVM's own IR format.
	The the backend LLVM will take multiple Passes to optimize
	the IR and the finally generate the assembly.
	- The beauty of Clang and LLVM is that they can be used
	as libraries, and we could invoke them to manipulate the
	compilation results, to do source-to-source transforms,
	modify Pass's IR etc. I found this super interesting!
	- To get started, I strongly recommend [LLVM for Grad Students](https://www.cs.cornell.edu/~asampson/blog/llvm.html)
- [OpenJDK](https://github.com/lastweek/source-jdk)
- [CPython](https://github.com/lastweek/source-cpython)
- [GNU GCC](https://github.com/gcc-mirror/gcc)
- [Rustc, in Rust](https://github.com/lastweek/source-rust)
- [PHP, in C](https://github.com/lastweek/source-php-src)
- [Google V8, in C++](https://github.com/lastweek/v8)
- [Apple Swift, in C++](https://github.com/lastweek/source-swift)
- [TCL, in C](https://github.com/lastweek/source-tcl)
- [Perl 5, in C](https://github.com/lastweek/source-perl5)
- [Lua, in C](https://github.com/lua/lua)
- [Ruby, in C](https://github.com/ruby/ruby)
- [Scala](https://github.com/scala/scala)
- [SpinalHDL]()


## CPython

Today (Oct 14, 201) I was reading Hacker News and came across this post [A viable solution for Python concurrency](https://lwn.net/Articles/872869/).
It was about removing the Global Interpreter Lock (GIL) in the cpython compilers. Quite interesting.
The technique is to use Biased Atomic Reference Accounting. Basically, it uses non-atomic operation if it is single-thread
so to avoid the cost of atomic instructions. But for multiple thread case, it will normal atomic instructions (which will be
much better the original GIL implementation).

So I decide to take another look at the cpython source code, which I have cloned ([repo](https://github.com/lastweek/source-cpython))quite a while ago when I had a broken leg. Once I decided to read the code, I google some cpython internals and these links pop up quite nicely.
There are A LOT good contents out there, I probably don't have time reading that now.

I briefly read the code, a lot typedefs for sure. The `PyStatus` structure is interesting.
And the way they organize the repo is also interesting. For a common python library, say csv,
there will a python library file under `Lib/csv.py`, then optionally a C accelerated version in `Modules/_csv.c`.
Essentially the whole thing is built like a Exokernel, the base is written in C for performance and portability among OSes.
Then a more rich python wrapper on top of that, which will be the default built-in python libraries we use day-to-day.

For those common [built-in functions](https://docs.python.org/3/library/functions.html),
they are organized [here](https://github.com/lastweek/source-cpython/blob/master/Python/bltinmodule.c#L2878)

0. [Your Guide to the CPython Source Code](https://realpython.com/cpython-source-code-guide/#part-1-introduction-to-cpython)
1. [Exploring CPython’s Internals](https://devguide.python.org/exploring/)
2. [Design of CPython’s Compiler](https://devguide.python.org/compiler/)
3. [Yet another guided tour of CPython](https://paper.dropbox.com/doc/Yet-another-guided-tour-of-CPython-XY7KgFGn88zMNivGJ4Jzv)

## Java

- [OpenJDK](https://github.com/lastweek/source-jdk)
	- **JRE = JVM + Runtime Classes** => JVM is the one parsing the bytecode, along with some extra classes/libraries, they form JRE.
	- **JDK = JRE + Development Tools** => JDK as in Development Kit therefore consists of some tools in addition to JRE.
	- JDK is a monster collection of resources in one place.
	  The JVM here is called `HotSpot`, a reference JVM implementation written in C++,
	  Since JDK also has so many runtime support, it has a lot Java code.
	- Personally I haven't written Java since 2013 or so.
	  Although I'm not using it anytime soon, I'm curious how it performs nowadays.
	- The repo is VERY WELL organized. see `src/`

- [HotSpot JVM](https://github.com/lastweek/source-openj9)
	- This one is included in the OpenJDK Repo, written in C++.
	- e.g., the GC code is under `src/hotspot/share/gc`.
- [Eclipse Openj9 JVM](https://github.com/lastweek/source-openj9)
	- A JVM for OpenJDK that's optimized for small footprint, fast start-up, and high throughput

All these OpenJDK components follow the [Java Language Spec and JVM Spec](https://docs.oracle.com/javase/specs/).

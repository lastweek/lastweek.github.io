# Benchmarks

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Apr 2, 2020| Update|
	|Aug 13, 2019| Update|
	|Aug 03, 2019| Initial draft|

## Areas

### Synchronization/Concurrency Community

- Phoenix HPCA (heavy mmap/munmap, i.e., mm-sem usage)
- MOSBENCH/Metis (same as Phoenix)
- LevelDB (a popular workload)
- Linux locktorture
- Filesystems (fs)
- LiTL, ATC'16, https://github.com/multicore-locks/litl
- References
    - ShuffleLock, SOSP'19
    - Compact NUMA-aware Locks, EuroSys'19
    - fill me in

### OS

- [will-it-scale](https://github.com/antonblanchard/will-it-scale)
- [lmbench](http://lmbench.sourceforge.net/whatis_lmbench.html)
- [sysbench](https://github.com/akopytov/sysbench/)


### FPGA

- [Rosetta: A Realistic High-Level Synthesis Benchmark Suite for Software Programmable FPGAs, FPGA'18](https://hj424.github.io/papers/rosetta_fpga2018.pdf)
- AmophOS has a lot more.

## Misc Information

- [Systems Benchmarking Crimes](https://www.cse.unsw.edu.au/~gernot/benchmarking-crimes.html)

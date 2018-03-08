# getrusage

The syscall `getrusage` is used to get user program resource usage. It is a nice syscall. But only nice if kernel has all the nice bookkeeping. It is a luxury for us to have all the counting.

The syscall is added recently due to `wait` family syscalls, which use and bookkeep some of `rusage`.

As on the last updated date (Mar 7), the syscall in Lego only reports number of context switches and a few others.

--  
Yizhou Shan  
Created: Mar 7, 2018  
Last Updated: Mar 7, 2018

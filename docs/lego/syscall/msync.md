# msync()

The document is a summary I wrote after reading `Failure-atomic msync()` paper, which help me understand several questions related to `msync()`.

* `msync() is not atomic.` During msync(), pages are being written back to disk one by one (or batched): few pages have been flushed back, but few pages are still in the memory. This premature writeback is not atomic and will be affected by failure.

* `msync() need concurrency control`. This actually is the issue I asked before. With a multi-threaded application, does msync() provide the synchronization semantic? The answer is no. Other threads within the same process are able to write to pages under msync(). This implies, application need to handle concurrency by themselves, e.g., rwlocks. At the very beginning, I thought msync() provide this semantic. The only way to implement this should be: kernel make all pages' PTE read-only, and then perform flush back. If any other threads does a write during flush, they will have a page fault. And in the pgfault function, we hold the threads until the pages are written back.

* Probably some nice reading. `fsync, fdatasync`[^1].

--  
Yizhou Shan  
Created: Feb 01, 2018  
Last Updated: Mar 23, 2018

[^1]: [RFLUSH: Rethink the Flush](https://www.usenix.org/system/files/conference/fast18/fast18-yeon.pdf)

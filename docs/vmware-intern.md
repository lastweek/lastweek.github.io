- Intel Xeon 6138p, integrated FPGA (check it out!)
- retpoline (perf impact?)
- Intel Total Memory Encryption. Multi-Key Total Memory Encryption (MKTME).

- __RDMA + NVM:__ An interesting topic. There are a lot interesting stuff to think about. I discussed this with Sanidhya today, he shared some very valuable findings:
    - RDMA write: when does it mark a `persistent` point?
    - RDMA write followed by a RDMA read, is kind of implicit memory barrier imposed by memory controller.

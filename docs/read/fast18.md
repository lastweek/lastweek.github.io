# FAST'18

Brief read of all FAST18 papers. (Mar 24)

- Continue from REFLUSH.

- One paper is doing PM ordering stuff. Mentioned Total Store Ordering (TSO) again, which is the consistency model I truly love the most: it benefit programmers, make our's life much easier.

- `Delta Synchronization`: important topic and implementation trick, also very useful for Yutong's path.

- `Erasure Coding v.s. Replication`: In order to be failure tolerant, data centers have in- creasingly started to adopt erasure codes in place of replication. A class of erasure codes known as maximum dis- tance separable (MDS) codes offer the same level of fail- ure tolerance as replication codes with minimal storage overhead. For example, Facebook [19] reported reduced storage overhead of 1.4x by using Reed-Solomon (RS) codes, a popular class of MDS codes, as opposed to the storage overhead of 3x incurred in triple replication [13]. __The disadvantage of the traditional MDS codes is their high repair cost.__ In case of replication, when a node or storage subsystem fails, an exact copy of the lost data can be copied from surviving nodes. However, in case of erasure codes, dependent data that is more voluminous in comparison with the lost data, is copied from surviving nodes and the lost data is then computed by a repair node, which results in a higher repair cost when compared to replication. This leads to increased repair bandwidth and repair time[^3].
    - The advantage of erasure coding is it can save needed storage. The downside is it takes longer to repair, because it does not maintain a full copy.
    - On the contrary, the core idea of RAMCloud is fast recovery.
    - This reminds several trade-offs while designing the replication algorithm for lego: 1) storage overhead, 2) time needed to make replication/erasure coding, 3) time needed to recovery.
    - Probably, 2) matters most. We can report failure to nodes, but we don't want to affect performance a lot.


- At the heart of this issue is how data is organized, or indexed, on disk. The most common design pattern for modern file systems is to use a form of __indirection__, such as `inodes`, between the name of a file in a directory and its physical placement on disk. Indirection simplifies implementation of some metadata operations, such as renames or file creates, but the contents of the file system can end up __scattered over__ the disk in the worst case. Cylinder groups and other best-effort heuristics [32] are designed to mitigate this scattering. Full-path indexing is an alternative to indirection, known to have good performance on nearly all operations.

- Read somehing: `some functionalities move up to the OS kernel (K) and some other move down to the SSD firmware (L) [18, 31, 36].`. This makes me think, that, moving functionalities up-to-kernel or down-to-device will be a forever controversial topic. Each system has its own internal requirement, and those requirements change over time. So, there should not be any split-and-benefit-all solution.

--  
Yizhou Shan  
Created: Mar 24, 2018  
Last Updated: Mar 24, 2018


[^1]: WAFL Iron: Repairing Live Enterprise File Systems, FAST'18
[^2]: Linux Block IO: Introducing Multi-queue SSD Access on
Multi-core Systems, SYSTOR'13
[^3]: Clay Codes: Moulding MDS Codes to Yield an MSR Code, FAST'18

# Replication, Checkpoint, Logging, and Recovery
## Discussion

- 03/25/18:
    - Revisit RAMCloud, which has a very similar goal with Lego. It keeps a full copy of data in DRAM, use disk to ensure crash consistency. The key assumption of RAMCloud is the battery-backed DRAM or PM on its disk side.
    - We don't need to provide a 100% recoverable model. Our goal here is to reduce the failure probabilities introduced by more components. Let us say Lego do the persist in a batching fashion, instead of per-page. We are not able to recover if and only if failure happen *while* we do the batch persist. But we are safe if failure happen between batched persist.
    - That actually also means we need to checkpoint process state in Processor side. We have to save all the process context along with the persisted memory log! Otherwise, the memory content is useless, we don't know the exact IP and other things.
    - I'm wrong. :-)


- 03/20/18: when memory is enough, use pessimistic replication, when demand is high, use optimistic to save memory components.

## Replication

Before started, I spent some time recap, and found Wiki pages[^1][^2][^3] are actually very good.

Two main approaches:

- __Optimistic (Lazy, Passive) Replication__ [^4], in which replicas are allowed to diverge
    - __Eventual consistency__[^5][^6][^7], meaning that replicas are guaranteed to converge only when the system has been quiesced for a period of time
- __Pessimistic (Active, Multi-master[^8]) Replication__, tries to guarantee from the beginning that all of the replicas are identical to each other, as if there was only a single copy of the data all along.

Lego is more towards memory replication, not storage replication. We may want to conduct some ideas from DSM replication (MRSW, MRMW), or in-memory DB such as RAMCloud, VoltDB?

## Checkpointing
Some nice reading[^9].

Application types:

- Long-running v.s. Short-lived
- Built-in checkpoint/journaling v.s. no built-in checkpoint/journaling

Two main approaches:

- __Coordinated__
    - 2PC
- __Un-coordinated__
    - Domino effect

We should favor __[Long-running && no built-in checkpoint/journaling]__ applications. Normally they are not distributed systems, right? Even it is, it might be running as a single-node version. Based on this, I think we should favor coordinated checkpointing.

HPC community[^10][^11][^12] has a lot publications on checkpoint/recovery (e.g., Lawrence National Laboratory).

## MISC
Some other interesting topics:

- Erasure Coding
    - Less space overhead
    - Parity Calculation is CPU-intensive
    - Increased latency

--  
Yizhou Shan  
Created: Mar 19, 2018  
Last Updated: Mar 19, 2018


[^1]: [Wiki: Replication](https://en.wikipedia.org/wiki/Replication_(computing))
[^2]: [Wiki: High-availability_cluster](https://en.wikipedia.org/wiki/High-availability_cluster)
[^3]: [Wiki: Virtual synchrony](https://en.wikipedia.org/wiki/Virtual_synchrony)
[^4]: [Wiki: Optimistic Replication](https://en.wikipedia.org/wiki/Optimistic_replication)
[^5]: [Wiki: Quiesce](https://en.wikipedia.org/wiki/Quiesce)
[^6]: [Wiki: Eventual Consistency](https://en.wikipedia.org/wiki/Eventual_consistency)
[^7]: [Wiki: CAP Theorem](https://en.wikipedia.org/wiki/CAP_theorem)
[^8]: [Wiki: Multi-master replication](https://en.wikipedia.org/wiki/Multi-master_replication)
[^9]: [Wiki: Application Checkpointing](https://en.wikipedia.org/wiki/Application_checkpointing)
[^10]: [Paper: A Survey of Checkpoint/Restart Implementations ](http://crd.lbl.gov/assets/pubs_presos/CDS/FTG/Papers/2002/checkpointSurvey-020724b.pdf)
[^11]: [Paper: The Design and Implementation of Berkeley Lab’s Linux
Checkpoint/Restart](http://crd.lbl.gov/assets/pubs_presos/CDS/FTG/Papers/2002/blcr.pdf)
[^12]: [Berkeley Lab Checkpoint/Restart (BLCR) for LINUX](http://crd.lbl.gov/departments/computer-science/CLaSS/research/BLCR/)

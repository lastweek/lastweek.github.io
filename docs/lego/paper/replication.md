# Replication, Checkpoint, Logging, and Recovery
## Discussion

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

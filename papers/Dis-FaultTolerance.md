# Fault-Tolerance, Replication, Consensus Protocol

## Implementing fault-tolerant services using the state machine approach, _ACM Computer Survey'90_
- 5
- Classic

## Practical Byzantine fault tolerance and proactive recovery, _ACM Computer Syst'02_
- TODO
- view?

## Incremental Consistency Guarantees for Replicated Objects, _OSDI'16_
- 4

## Just Say NO to Paxos Overhead: Replacing Consensus with Network Ordering, _OSDI'16_
- 5
- Dividing responsibility between the network layer and replication protocol.
Oh mama, the Ordered Unreliable Multicast (OUM) is really useful and can be
implemented in datacenter via SDN. Similar to the Global Clock in Google
Spanner? The philosophy is using state-of-art technology to _break_ old
assumptions (e.g. network can not be ordered, global clock can not be
synchronized) and thus build fast systems. Interesting.
- Based on OUM network, the Paxos can be pruned. The perf can be improved.
But I really do not want to talk about Paxos. :-(

## XFT: Practical Fault Tolerance beyond Crashes, _OSDI'16_
- 3
- Damn it I hate Byzantine non-crash fault :-(

# Switch Buffering and Packet Scheduling

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Jan 12, 2021 | Initial Version|

I came across this topic for a research project I'm doing.

I think the switch buffering architecture and packet scheduling
are closely related. The buffering architecture could limit
what scheduling algorithms can be used.
However, I think they are still two different things
and we should look at them separately.
For example, consider a Combined Input Output Queued Switch,
I think it is possible to use a shared memory to implement
the output queues and use a separate PIFO blocks for packet scheduling.

My current impression for state-of-the-art switches is:
1) They use a large central packet buffer, can be as large as 64MB (i.e., Tofino2);
2) They could have some input and output buffers independent from the central packet buffer,
but these buffers would be small;
3) They have something called Traffic Manager to schedule packets;
4) They usually have fixed packet scheduler. I'm not quite sure whether
they have the programmable packet scheduler concept pioneered by PIFO.


## Switch buffering

- Input Queued
    - Virtual Output Queued
- Output Queued
- Combined Input and Output Queued
- Shared Memory

### References

These set of papers covered the basic concept of Input/Output Queued switches.

1. The iSLIP scheduling algorithm for *input-queued* switches, 1999
2. Matching Output Queueing with a Combined Input Output Queued Switch, 1999
    - This paper proposed PIFO.
    - It is trying to prove a CIOQ switch can be as good as a output queued switch.
3. Saturating the Transceiver Bandwidth: Switch Fabric Design on FPGAs, 2012
    - Use shared memory as switch.
4. Investigating the Feasibility of FPGA-based Network Switches, 2019
5. High-Performance FPGA Network Switch Architecture, 2020
6. Scheduling Algorithms for High Performance Network Switching on FPGAs: A Survey, 2018

1. [Intel® Ethernet Switch FM10000 Series](https://www.intel.com/content/www/us/en/design/products-and-solutions/networking-and-io/ethernet-switch-fm10000-series/technical-library.html?grouping=EMT_Content%20Type&sort=title:asc)
2. Intel Barefoot Tofino2 has a 64MB Unified Packet Buffer 

## Packet Scheduling

- Programmable packet scheduling - PIFO
- Work-Conserving v.s. Non-Work-Conserving

I think this is a very interesting topic. Yet there are
only few papers on this topic. But there is definitely an
increasing interest.

The PIFO SIGCOMM'16 paper is for sure one of the seminal work in this space. There are some very old papers (circa 1999) on switch buffering architecute. The PIFO was proposed by a 1999 INFOCOM paper.

I may able to write more later.

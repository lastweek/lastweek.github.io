# Learning IB

## Q
- Send: receiver's CPU will be involved? A: I think so.
- Atomic Operations: what exactly does the atomic mean in this context?
- When a RECV was consumed, will a CQE be generated at receiver side? Yes.
- Actually, what is the purpose of `ib_poll_cq`? For sender, it uses this to check if the msg has been sent. For receiver, does it use this to check if a msg has been received (cos a RECV WQE has been consumed)? A: Understand now.
- RDMA Write with Immediate Data: according to spec, the remote side will consume a WQE and generate a CQE. Will this involve remote CPU? A:
- RPC: SEND or RDMA Write with Immediate, which is better and why?

## IB Specification

- The QP is the __virtual interface that the hardware provides to an IBA consumer__; it serves as a virtual communication port for the consumer.

- Memory Region, L_Key, R_Key (sec 3.5.3/3.5.4)
    - Used in RDMA requests.
    - This is key in many design choices.

- Addressing (sec 3.5.10 and sec 4)
    - Each QP has as queue pair number (__QPN__) assigned by the channel
adapter which uniquely identifies the QP __within the channel adapter__.
    - QPN GID, LID stuff

- {==__IBA Semantic (sec 3.6)__==}
    - Channel (Send/Receive), classical I/O channel
        - The message transmitted on the wire only names the destination’s QP, the message does not describe where in the destination consumer’s memory space the message content will be written. Instead, the destination QP contains addressing information used to deliver the message to the appropriate memory location.
        - Post Receive Buffer (a channel semantic operation for SEND from remote.)
    - Memory (RDMA)
        - With memory semantics the initiating party directly reads or writes the virtual address space of a remote node. The remote party needs only communicate the location of the buffer; it is not involved with the actual transfer of the data. Hence, this style is sometimes referred to as single-ended communications.
	- L_Key and R_Key used to validate access permission.

- Immediate Data
    - RDMA Write and SEND can carry __4 bytes of Immediate data__.
    - sec 3.6 SEND can carry Immediate data for each send message. If included, the Immediate data is contained within an additional header field on the last packet of the SEND Operation (sec 9.4.1 SEND Operation).
    - sec 3.7.4 __An RDMA Write with immediate data__ will consume a receive WQE even though the QP did not place any data into the receive buffer since the IMMDT is placed in a CQE that references the receive WQE and indicates that the WQE has completed.
    - sec 9.4.3 If specified by the verbs layer, Immediate data is included in the __last packet of an RDMA WRITE message__. The Immediate data is not written to the target virtual address range, but is passed to the client after the last RDMA WRITE packet is successfully processed.
    - sec 10.7.2.2 C10-86: The responder’s Receive Queue shall consume a Work Request when Immediate Data is specified in a successfully completed incoming RDMA Write.

- QP transport services
    - RC
    - RD
    - UC
    - UD
- IB Layers
    - The __network__ and __link__ protocols deliver a packet to the desired destination. The __transport__ portion of the packet delivers the packet to the proper QP and instructs the QP how to process the packet’s data.
    - Upper Layers (Consumer Operations). __This is the layer most people focus on and try to optimize, right?__

- {==__IB Transaction Flow (sec 3.8)__==}
    - Describe the general flow. A nice read.
    - So the WQE of RDMA Write/Read, the sender side's driver will create a CQE when sender get ACK from receiver? And that marks the end of a RDMA Read/Write? For RC, I think so. According to: __When the originator receives an acknowledgment, it creates a CQE on the CQ and retires the WQE from the send queue.__
    - __sec 3.2.1 Each time the remote consumer successfully executes a SEND operation, the hardware takes the next entry from the receive queue, places the received data in the memory location specified in that receive WQE, and places a CQE on the completion queue indicating to the consumer that the receive operation has completed. Thus the execution of a SEND operation causes a receive queue operation at the remote consumer.__ That is one important claim, the receiver side can poll the CQ to know if it has received a SEND or not.

- IB I/O Operations (sec 3.9)
    - Interesting. So, instead of a Host Channel Adapter (HCA), we have Target Channel Adapter (TCA), which is attached to a IO device such as SSD. If we look from the IB layered architecture, everything below __upper level protocols__ remain the same. In upper level protocols, which used to be Consumer, now is I/O controller.
    - Do we have this kind of hardware on market? Fabric over NVMe?

- Transport Layer (sec 9)
    - The transport header contains the information required by the endnode to complete the specified operation, e.g. delivery of data payload to the appropriate entity within the endnode such as __a thread__ or __IO controller__.
    - For a host platform, __the client of the transport layer is the Verbs software layer__. The client posts buffers or commands to these queues and hardware transfers data from or into the buffers.
    - Reliable transport has response (acknowledge). Unreliable transport does not use acknowledgment messages.
    - SEND can carry __4 bytes of Immediate data__ for each send message. If included, the Immediate data is contained within an additional header field on the last packet of the SEND Operation (sec 9.4.1 SEND Operation).
    - __WQ Packet Ordering Stuff__ (sec 9.5 Transaction Ordering): A requester shall transmit request messages in the order that the Work Queue Elements (WQEs) were posted.
    - Reliable Service (sec 9.7)
        - Before it can consider a WQE completed, the requester must wait for the necessary response(s) to arrive. If the requester requires an explicit response such that it can complete a given WQE, then the requester shall be responsible to take the necessary steps to ensure that the needed response is forthcoming.
	- This section is still too much details on hardware behavior. But Mel must have more detailed stuff in house.

- Software Transport interface (sec 10)
    - I think this section is trying to describe the various software concepts, such as HCA, Protection domain, and so on. The actual manipulations are carried out by Verbs, which are described in sec 11.
    - A QP, which is a component of the channel interface, is NOT directly accessible by the Verbs consumer and can only be manipulated through the use of Verbs.
    - A CQ can be used to multiplex work completions from multiple work queues across queue pairs on the same HCA.
    - Shared Receive Queue (sec 10.2.9) (Is it used in Lego?)
    - Memory Management (sec 10.6)
        - Memory Region
	- Able to register a __virtually contiguous address range__, even though the physical pages are not contiguous.
	- Able to register a __physically contiguous address range__.
	- Prior to invoking a Register Physical Memory Region or Reregister Physical Memory Region Verb, the Consumer should __pin down__ in physical memory every physical buffer within the Memory Region. (But now Mellanox supports pgfault in their products, right?)
    - Work Request (sec 10.7 and sec 10.8)
        - Signaled Completion and Unsignaled Completion (sec 10.7.3.1) Finally meet these two description in tech documents. In Lego, we used to use unsignaled (polling), and then we change that to signaled handler.
	- Submitting a list of Work Requests.. (10.8.2.1)
	- .. __the HCA is notified that one or more WQEs are ready to be processed.__ What is the mechanism of this notification? How does HCA got notified? HCA polling, or driver write something into HCA?
	- Completion Queue Operations: poll a specified CQ for a Work Completion, that is `ib_poll_cq()`! (sec 11.4.2)

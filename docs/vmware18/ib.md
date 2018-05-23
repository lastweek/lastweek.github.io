# Learning IB

Reading IB Spec:

- The QP is the __virtual interface that the hardware provides to an IBA consumer__; it serves as a virtual communication port for the consumer.

- One-sided RDMA, two-sided RDMA

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

- IB I/O Operations (sec 3.9)
    - Interesting. So, instead of a Host Channel Adapter (HCA), we have Target Channel Adapter (TCA), which is attached to a IO device such as SSD. If we look from the IB layered architecture, everything below __upper level protocols__ remain the same. In upper level protocols, which used to be Consumer, now is I/O controller.
    - Do we have this kind of hardware on market? Fabric over NVMe?

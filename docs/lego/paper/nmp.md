# Near Memory Processing

* ==NMP: Near Memory Processing==
* ==NDC: Near Data Computing==

* `PRIME: A Novel Processing-in-memory Architecture for Neural Network
Computation in ReRAM-based Main Memory, ISCA'16`
    * High-performance
acceleration of NN requires high memory bandwidth since
the ==PUs are hungry for fetching the synaptic weights [17]==. To
address this challenge, recent special-purpose chip designs
have adopted large on-chip memory to store the synaptic
weights. For example, DaDianNao [18] employed a large
on-chip eDRAM for both high bandwidth and data locality;
TrueNorth utilized an SRAM crossbar memory for synapses
in each core [19].
* ==DianNao== and ==DaDianNao==
    * ... __memory bandwidth requirements__ of two important
layer types: convolutional layers with private kernels
(used in DNNs) and classifier layers used in both CNNs and
DNNs. For these types of layers, the total number of required
synapses can be massive, in the millions of parameters, or
even tens or hundreds thereof.
    * providing sufficient eDRAM capacity to hold
all __synapse__ on the combined eDRAM of all chips will
save on `off-chip DRAM accesses`, which are particularly
costly energy-wise
    * ==Synapses==. In a perceptron layer, all synapses are usually
unique, and thus there is no reuse within the layer. On the
other hand, the synapses are reused across network invocations,
i.e., for each new input data (also called “input row”)
presented to the neural network. So a sufficiently large L2
could store all network synapses and take advantage of that
locality. For DNNs with private kernels, this is not possible
as the total number of synapses are in the tens or hundreds
of millions (the largest network to date has a billion
synapses [26]). However, for both CNNs and DNNs with
shared kernels, the total number of synapses range in the
millions, which is within the reach of an L2 cache. In Figure
6, see CLASS1 - Tiled+L2, we emulate the case where reuse
across network invocations is possible by considering only
the perceptron layer; as a result, the total bandwidth requirements
are now drastically reduced.
    * So, ML workloads do need large memory bandwidth, and need a lot memory. But how about __temporary working set size__? It's the best if it has a reasonable working set size that can fit the cache.
* ==TPU==
    * Each model needs between 5M and 100M weights (9th
column of Table 1), which can take a lot of time and energy to
access. To amortize the access costs, __the same weights are reused
across a batch of independent examples during inference or
training__, which improves performance.
    * The weights for the matrix unit are staged through an onchip
__Weight FIFO__ that reads from an __off-chip 8 GiB DRAM
called Weight Memory__ (for inference, weights are read-only; 8
GiB supports many simultaneously active models). The weight
FIFO is four tiles deep. The intermediate results are held in the __24
MiB on-chip Unified Buffer__, which can serve as inputs to the Matrix Unit.
    * ==In virtual cache model, we actually can assign those weights to some designated sets, thus avoid conflicting with other data, which means we can sustain those weights in cache!==

To conclude:  
`a)` ML needs to use weight/synapses during computation, and those data will be reused repeatly across different stages. Besides, output from last stage serves the input of next stage, so buffering the `intermediate data` is important. Most ML accelerators use some kind of `on-chip memory` (*Weighted FIFO, Unified Cache in TPU*) to buffer those data. This fits the `HBM+Disaggregated Memory` model: HBM is the on-chip memory, while disaggregated memory is the off-chip memory. `b)` Combined with virtual cache, we could assign special virtual addresses to weight data, so they stay in some designated cache sets. Kernel can avoid allocating conflict virtual addresses later. Thus we can retain these weight data in virtual cache easily.

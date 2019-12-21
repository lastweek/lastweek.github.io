# High-performance AXI-MM in HLS


My personal experience: the native AXI-MM in HLS is horrible.
It fails to generate efficient code.
The best practice I found is the use an external Datamover.
In HLS, all memory access is made via AXI-Stream.
Using AXI-Stream means we can wait the result asynchronously,
hence we can deal with long memory access in a more informed manner.

Usually using AXI-Stream and Datamover delivers code with II=1.

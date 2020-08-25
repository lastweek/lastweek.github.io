# FPGA

## My Story with FPGA

Back at late 2018, I started using FPGA to do datacenter research.
More specific, we used FPGA to build a disaggregated memory component,
which was intended as a follow-up to our prior work LegoOS, OSDI'18.

Along the way, our idea spin-off a bit. I started looking into building
an real **OS** into FPGA: we tried to build `sched` (temporal and spacial), `mm`, `net`,
and various OS functionalties into FPGA (more than a traditional FPGA shell,
and other FPGA OSs that a lot of acadamic papers claim!).
This experiences enriched me with all sorts of low-level FPGA knowledge.
I spent quit a lot of time digging into partial reconfiguration and
various hacks to avoid its limitations
(see [Bitstream Explained](http://lastweek.io/fpga/bitstream/),
[Morphous PR](http://lastweek.io/fpga/pr/),
[Ultrascale SSI](https://forums.xilinx.com/t5/FPGA-Configuration/Issues-with-ll-and-msk-file-with-an-SSI-Ultrascale-chip-VCU118/td-p/1047253)).
This FPGA OS project did not go well and we decided to suspend it.

I came across various FPGA projects for which I will list below.

TODO.

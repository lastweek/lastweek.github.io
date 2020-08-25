# FPGA

What is HDL? Hard and Difficult Language. :)

This page reflects on various FPGA projects I came across.

## Code

### Network

- [Alex Forencich's Verilog Ethernet](https://github.com/alexforencich/verilog-ethernet)
    - This repo includes Ethernet PHY, MAC, IP, and UDP layer IPs.
    - It works on various boards.
    - THE BEST choice if you are trying to connect your board to network.
    - Written in Verilog
- [Alex Forencich's Corundum NIC](https://github.com/corundum/corundum)
    - This repo is a full-fledged NIC implementation including the above
      Verilog-Ethernet part, DMA engines, PCIe controller, interrupts,
      and so on.
    - A NIC has more features than a basic FPGA Ethenet solution.
      You need a NIC if you are working with host softwares,
      otherwise you should consider using the verilog-ethernet version.
    - Written in Verilog
- [TCP/IP, RoCEv2 from ETH](https://github.com/fpgasystems/fpga-network-stack)
    - There are several papers published using this repo.
      It provides the basic TCP/IP and RoCE v2 stack (StRom, EuroSys'19).
    - Personally I haven't used this repo so I don't have any comments.
    - Written in Xilinx HLS.

### Memory

TODO.

### Partial Reconfiguration

TODO.

### Compilers

- SpinalHDL
- Chisel
- Google XLS

### Soft Cores

- [VexRiscv, based on SpinalHDL](https://github.com/SpinalHDL/VexRiscv)
- [ZipCPU, RISC CPU, written in Verilog](https://github.com/ZipCPU/zipcpu)

### MISC

- [OpenWIFI](https://github.com/open-sdr/openwifi)
- [NyuziProcessor, a GPGPU Processor](https://github.com/jbush001/NyuziProcessor)
- [HDMI](https://github.com/hdl-util/hdmi)

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

# On-High-Level-Languages-For-FPGA-Design

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|May 31, 2020 | Initial |

With FPGA getting popular among system folks, it's crucial to pick up
the right language for the project. Most folks will not use Verilog/VHDL directly,
but use higher level languages like Xilinx HLS, Chisel, SpinalHDL etc.

All my dicussions and opinions are based on my own limited experience with FPGA (since Oct 2018),
it does not reflect any others' opinions.

In short:
for folks new to FPGA and want to start a medium- or large- sized network-oriented academic projects,
I would recommend avoid using Xilinx HLS, but use SpinalHDL/Chisel or others instead.
Of course, you still need to know a bit bout Verilog/VHDL and all the tools (e.g., Vivado)
for the final project packaging.

I started using HLS from 2018 Oct. I've writtin more than 20K HLS code,
including but not limited to RDMA-like modules, partial-reconfiguration ICAP3 controller.
I pick it because it is C-like and expressive when first using it.
However, along the way, me and my labmates have had a lot issues with HLS, some due to
compiler, some are still non-explainable.

My own opinions about HLS.
The good part.
1) HLS is easy to pick up and write. Its semantic is similar to C.
2) Good for prototying small project.
3) HLS has several useful AXI-Stream interfaces.
4) HLS has many options allowing to control FPGA resource usage.

The bad part.
1) HLS is not designed around streaming interface, which is a crutial
   part for network oriented projects. It's dataflow primitive is very restrictive,
   hard to construct a system with clear flow.
2) Compiler. Some code pattern generate undefined behaviours, even though totally
   correct in turns of logic. Ugh, we have had so much trouble for this part,
   and this is the most annoying part.
3) Hard to control BRAM access, i.e., avoid false-dependency and track consistency.
4) Hard to express bits related ops. HLS has `range` operators, but really hard to write,
   a lot macros flying around.
5) Streaming interface is a bit fragile, we found a lot random stucks during runtime
   due to buffer issue.
6) For code to be really useful, you have to write in a switch-case state machine way.
   There is no difference with a verilog one, but with more complexity, especially
   for large-scale projects.
7) Simulation framework is not easy to use, a lot restritions too.

We had a lot trouble with HLS. Not until recently, one of my labmate picked up SpinalHDL,
and we found it amazing. I'm not personally writing SpinalHDL code, but I felt it is
super expressive and match hardware primitive, physically and mentally.
Personally, I would use scala-based ones over HLS for my future projects.

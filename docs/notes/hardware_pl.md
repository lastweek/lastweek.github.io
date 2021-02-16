# Hardware Design Languages

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Nov 13, 2020| Initial Version|
	|Sep 28, 2020| Initial Version|

## Introduction

There is an increasing interest from both industry and acadamic on
designing high-level domain-specific languages for hardware development (both FPGA and ASIC).
These advancements would benefit both software and hardware developers.

This document reflects my effort on configuring/running these systems and
my thoughts on their pros and cons (if any).

| System | Language | Sponsor/Status  |
|:-------|----------|-----------------|
| Xilinx High-Level Synthesis                  | C++   | Industry. Mature|
| Chisel                                       | Scala | Industy and Acadamic. Mature |
| SpinalHDL                                    | Scala | Industry (solo effort). Mature |
| [Dahlia](https://github.com/cucapra/dahlia)  | Scala | Acadamic |
| [Google XLS](https://google.github.io/xls/)  | Rust-like | Industry. Pre-mature|

## SpinalHDL

SpinalHDL is a scala-based meta HLD programming language.
SpinalHDL will convert Scala into Verilog. The generated Verilog is very simple and matches what we write in Scala.
Besides, you can use Scala Functional Programming to express hardware, really powerful!

I found the following stuff very convenient:
1. __Connection__.
I need to connect a lot of AxiStream interfaces very frequently.
To connect an input port onto an output port, we can do something like the following snippets.
```scala
io.in >> io.out.
```
2. __Functional Programming__.
I can do something like this to get the sum of an array:
```scala
array.foldLeft(0)(_+_)
```

## Google XLS

The [XLS (Accelerated HW Synthesis)](https://google.github.io/xls/) project is a Rust-like DSL for hardware development.

### Build

I used their `docker build .`, which is extremely lengthy. This is my first using Bazel.
Once the build is done, use `docker images` to check the new docker image ID.
To run, `docker run -i -t <ID> /bin/bash`. After that, follow their [quick-guide](https://google.github.io/xls/tools_quick_start/).

The whole project is pre-mature. There are not too many examples, the building process is too long,
and even the basic `.x -> .v` generation needs quite some manual typing.

Following its `simple_adder` quick-start instructions, the following Verilog code is generated:

```Verilog
module __simple_add__add(
  input wire clk,
  input wire [31:0] x,
  input wire [31:0] y,
  output wire [31:0] out
);
  // ===== Pipe stage 0:

  // Registers for pipe stage 0:
  reg [31:0] p0_x;
  reg [31:0] p0_y;
  always_ff @ (posedge clk) begin
    p0_x <= x;
    p0_y <= y;
  end

  // ===== Pipe stage 1:
  wire [31:0] p1_add_3_comb;
  assign p1_add_3_comb = p0_x + p0_y;

  // Registers for pipe stage 1:
  reg [31:0] p1_add_3;
  always_ff @ (posedge clk) begin
    p1_add_3 <= p1_add_3_comb;
  end
  assign out = p1_add_3;
endmodule
```

## LLVM CIRCT

["CIRCT" stands for "Circuit IR Compilers and Tools"](https://github.com/llvm/circt).
This is also an early-stage LLVM project.
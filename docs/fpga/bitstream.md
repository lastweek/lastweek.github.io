# FPGA Bitstream Explained

:dromedary_camel:

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Sep 18, 2020 | add github link and usenix paper |
	|Dec 20, 2019 | Update |
	|Oct 24, 2019 | Created |

The proof-of-concept code to decode Xilinx bitstream is here: https://github.com/lastweek/fpga_decode_bitstream.

USENIX Security 2020 has a paper on decrypting Xilinx bitstream: https://www.usenix.org/conference/usenixsecurity20/presentation/ender.
They find a vulnerability in the 7-series chip and in turn able to decrypt a fully encrypted bitstream. WHAT A HACK!

## Introduction

A bitstream can configure an FPGA.
A bitstream includes the descriptions of the hardware logic, routing, and initial
values of the registers and the on-chip memory.
The common impression is that a bitstream has vendor-specific format thus cannot be reversed or understood.
This impression is partially true.

A bitstream file is more than the bits to configure an FPGA,
it also has certain human-readable fields to describe those bits.
In fact, it has a **assembly-like instruction set** to describe the FPGA configuration process.
This note is trying to walk through this.

At a high-level, a bitstream file is similar to an executable program.
Analogous to the ELF format, a bistream has its own format to describe the contents.
Note, the file format is publicly documented [1](https://www.xilinx.com/support/documentation/user_guides/ug570-ultrascale-configuration.pdf).
Thus, you **can** analyze the contents of a bitstream file, meaning you can understand the steps taken to configure the FPGA.
The un-documented part is the **bits mapping**:
the format of the configuration bits,
especially how the bitstream bits map to specific on-chip LUTs, wires etc.
Think this way, you can understand that the assembly instruction is doing addition on registers,
but it does not tell you which register.

As a normal FPGA user, you mostly do not need to understand neither of these.
You only need to understand these if you are planning to do **bitstream readback**,
**preemption scheduling**, and so on.

After reading this note, I hope you could understand that a bitstream file is just
a sequence of instructions and data.
The FPGA itself has a simple state machine to parse the bitstream and then configure the chip (ICAP in Xilinx).
Part of the bistream file format is public, the mapping between the bitstream configuration bits
and the actual physical resource is undocumented.

## Bistream Related Files
In a normal flow, Vivado only generates a simple `.bit` file.
When you click "Program Device", Vivado will use this file to configure your FPGA.

In addition to generating this file, Vivado is capable of generating a bunch other files.
You can find a complete coverage in this [link](https://www.xilinx.com/support/answers/14468.html).
We give a high level summary here.
Most of the files have the same content and have similar file size.
For instance, the difference between a `.rbt` and a `.bit` is that the former one is in ASCII format while the latter is in binary format,
but they have the *same* contents. As for a `.bit` and a `.bin` file, the latter does not have some ASCII headers at the beginning of the file.

`.ll`, the logical link file, is very interesting.
It tells you the mapping between user logic and the actual bit offset in the bistream file data section.
This file can be used to aid preemption scheduling.
However, note that, this file only documents a very small part of the mapping.
To the best of my knowledge, I think only the registers, on-chip memory are documented, but the routing
information is missing. Thus, this file can help reserve engineer bitstream data section to some extend, but not full of it.
[Prjxray](https://github.com/SymbiFlow/prjxray) is an open source project working on cracking everything on 7-series FPGA.

## Details

We use `.rbt` and `.bit` to demonstrate the file format.
Note that they are essentially the same thing, except the former in human-readable ASCII format.

The target board is VCU118, the one used by many cloud vendors.

The following snippt is the first few lines of the `.rpt` file.
The first few lines are human-readable ASCII contents describing some general information
about the bitstream. Starting from line 8 is the actual bitstream file contents.
Note that the `.bin` file starts directly from line 8, no general header info is attached.
The interesting part is the 1s and 0s.
Unless otherwise noted, when we refer to bitstream format, we focus on the 1s and 0s only
and omit any general ASICC information headers.

```
Xilinx ASCII Bitstream
Created by Bitstream 2018.3 SW Build 2405991 on Thu Dec  6 23:36:41 MST 2018
Design name:    base_mb_wrapper;UserID=0XFFFFFFFF;Version=2018.3
Architecture:   virtexuplus
Part:           xcvu9p-flga2104-2L-e
Date:           Wed Nov 20 04:13:05 2019
Bits:           641272864
11111111111111111111111111111111
11111111111111111111111111111111
11111111111111111111111111111111
...
```

Note that each line has 32 bits, thus 4 bytes.
In Xilinx bistream format, each four bytes is a packet (analogous to CPU instruction).
Each packet has certain format, it could be a special *header packet*, or a normal *data packet*.
The header packet follows a simple assembly-like instruction set to dictate the configuration process.
The bitstream file is a sequence of these four bytes packets. 

Why it sounds so complicated, a sequence of instructions?!
I think the short answer is that configuraing FPGA is not an easy task,
and any wrong doings may permanently harm the chip.
Natually, the designer would have a on-chip state machine to control the configuration process,
not only to control the whole process but also to ensure safety.

Each Xilinx FPGA has an on-chip *configuration packet processor*.
All configuration methods such as JTAG, SelectMAP, ICAP merge into this final narrow bridge to carry out the configuration.
The configuration packet processor has many internal registers (similar to x86 RAX, CRn, MSR registers).
The bitstream usually interact with one of the registers at a time to do one thing.
For a more detailed explanation, check out [this blog](https://www.kc8apf.net/2018/05/unpacking-xilinx-7-series-bitstreams-part-2/),
and UG570 chapter 9.

To this end, a bitstream consits of three parts:

- 1) Header packets to prepare the configuration process.
- 2) The actual configuration bits in a contiguous sequence of data packets.
     AN write to the `FDRI` register marks the beginning of this section.
     The length of this section is described by the packet following the FDRI header packet.
- 3) Header packets to clean up the configuration process.

The actual configuration bits are the ones determine the FPGA functionality.
Note that if you are using an SSI Xilinx device like VCU118, the bitstream format is a bit more complicated.
Basically, each die has the above three parts. If an chip has N dies, it will have N above triplet.
I have complained about this is not well documented [here](https://forums.xilinx.com/t5/FPGA-Configuration/Readback-Verify-and-Capture-on-SSI-devices/m-p/1045810/highlight/true#M14828)
and [here](https://forums.xilinx.com/t5/FPGA-Configuration/Issues-with-ll-and-msk-file-with-an-SSI-Ultrascale-chip-VCU118/m-p/1047253).


I wrote a simple [C program](https://github.com/lastweek/FPGA-Xilinx-Bitstream)
to parse the `.rbt` file and associate a human-reable syntax with each line.
I didn't have a complete coverage of the header packet format.
The following snippt shows a parsed `.rbt` file with header removed.
Here, `0xffffffff` has no effect, like a NOP.
`0x000000bb` and `0x11220044` are special bus detect words.
`0xaa995566` is another special work marking the synchronization status.
The last few lines mark the beginning of the configuration bits section.

```
Parsed from base_mb_wrapper.rbt
ffffffff 
ffffffff 
ffffffff 
ffffffff 
ffffffff 
ffffffff 
ffffffff 
ffffffff 
ffffffff 
ffffffff 
ffffffff 
ffffffff 
ffffffff 
ffffffff 
ffffffff 
ffffffff 
000000bb Bus Width Sync
11220044 Bus Width Detect
ffffffff 
ffffffff 
aa995566  SYNC
20000000 
20000000 
30022001 Write to regs 17
00000000 
30020001 Write to regs 16
00000000 
30008001 Write to CMD
00000000 
20000000 
30008001 Write to CMD
00000007 
20000000 
20000000 
30002001 Write to FAR
00000000 
30026001 Write to regs 19
00000000 
30012001 Write to regs 9
38003fe5 Write to regs 1
3001c001 Write to regs 14
00400000 
30018001 Write to IDCODE
04b31093 IDCODE=4b31093
30008001 Write to CMD
00000009 
20000000 
3000c001 Write to regs 6
00000001 
3000a001 Write to regs 5
00000101 
3000c001 Write to regs 6
00000000 
30030001 Write to regs 24
00000000 
20000000 
20000000 
20000000 
20000000 
20000000 
20000000 
20000000 
20000000 
30002001 Write to FAR
00000000 
30008001 Write to CMD
00000001 
20000000 
30004000 Write to FDRI
5065eadc 			<- The length of configuration bits, follows a certain format
00000000			<- The first 4 bytes of the configuration bits!
```

Hope you have learned something.

## References

1. [Xilinx UG570](https://www.xilinx.com/support/documentation/user_guides/ug570-ultrascale-configuration.pdf)
2. [Xilinx bitstream files](https://www.xilinx.com/support/answers/14468.html)
3. [Another blog on Xilinx Bitstream Internals](https://www.kc8apf.net/2018/05/unpacking-xilinx-7-series-bitstreams-part-2/) 
4. [Source code to annotate bitstream](https://github.com/lastweek/FPGA-Xilinx-Bitstream)


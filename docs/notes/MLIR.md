# MLIR

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|May 8, 2023| Add Mojo |
	|Jan 14, 2023 | Add LingoDB and DAPHNE|
	|Jul 3, 2022 | Add Pathways|
	|Apr 2, 2022 | Ported from Craft. Recently, I switched to Craft for technical writing. I'm very happy I made that transition. Craft is great at exporting things to Markdown format. |

:boom:

This document is organized as follows.

1. MLIR at 10,000 feet - an overview.
2. Why MLIR was created? - a study of the original MLIR paper.
3. How MLIR is used in the wild? - case studies.

Without further ado, let's get started.

## MLIR At 10,000 Feet


MLIR is short for Multi-Level Intermediate Representation.
MLIR helps to build reusage compiler infrastructure
and reduce duplicate codes.

I draw the following figure to show MLIR's workflow at a very high level.

In specific:

- MLIR's input: applications, compilers, C program, etc
- Within MLIR, we can implement multiple *Dialects* for distinct inputs. For instance, we could use a Dialect to deal with tensors. Further, we can deploy a shared optimization layer to unify things.
- Once we have an optimal IR, MLIR can now lower it onto the backends such as LLVM for CPUs, CIRCT for FPGAs. If you are targeting specialized hardware such as FPGA or TPU, you still need vendor-tools for final compilation (e.g., use Vivado to synthesis Verilog).

![MLIR.png](https://res.craft.do/user/full/55556ffd-6bd0-f98b-802b-8680fc9006d8/doc/C108C7BD-1633-4A3C-AA6B-C7CC05C399F2/FA08E0F8-687F-4489-B2AC-29230E33CCBE_2/S1WndKzLkyiRmIkfMb87HYcQZv6wBiT9dUTrOyWgpBAz/MLIR.png)

## Resources

I have found several excellent primer readings.

- [LLVM Paper from Google, 2020](https://arxiv.org/pdf/2002.11054.pdf). This paper describes the rationale behind MLIR. Chris L is one of the authors.
- [LLVM MLIR Tutorial](https://llvm.org/devmtg/2020-09/slides/MLIR_Tutorial.pdf)
	- I didn't understand this image when I first read it. But now it all makes sense. MLIR is something that lies across language AST and LLVM IR.
	- ![Screen Shot 2022-03-26 at 12.33.07.png](https://res.craft.do/user/full/55556ffd-6bd0-f98b-802b-8680fc9006d8/C49C3496-9B3F-4DE2-8BA1-E14318AEDD11_2/MTX2hqSriKVySNvWxTykadfIFFtq4JlJMwxn4imR2U0z/Screen%20Shot%202022-03-26%20at%2012.33.07.png)
- [ScaleHLS, HPCA'22](https://arxiv.org/abs/2107.11673) can compile HLS C/C++ or PyTorch model to optimized HLS C/C++ using MLIR.

## Motivation from the Google MLIR Paper

This paper has a *really nice Intro*, pay close attention to how they lay out the storyline.
If you are new to PL just like me,
I strongly recommend going through the MLIR Toy Example (covered below ) for a better understanding,
and then come back, read through this again. The following text are directly copied from this seminal paper.

1. A common characteristic of popular ML systems is their *“one size ﬁts all”* approach—a single abstraction level to interface with the system: the LLVM Intermediate Representation (IR) is roughly “C with vectors”, and JVM provides an “object-oriented type system with a garbage collector” abstraction. This “one size ﬁts all” approach is incredibly valuable—and in practice, the mapping to these domains from ubiquitous source languages (C/C++ and Java respectively) is straightforward.   (**Praise the unified LLVM IR**)
2. At the same time, many problems are better modeled at a higher- or lower-level abstraction, e.g. source-level analysis of C++ code is very difﬁcult on LLVM IR. We observe that many languages (including e.g. Swift, Rust, Julia, Fortran) develop their own IR in order to solve domain-speciﬁc problems, like language/library-speciﬁc optimizations, ﬂow-sensitive type checking. Similarly, machine learning systems typically use “ML graphs” as a domain-speciﬁc abstraction in the same way. (**Point out the issues about LLVM IR**)
3. While the development of domain speciﬁc IRs is a well studied art, their engineering and implementation cost remains high. … this can lead to lower quality compiler systems. (**Point out that developing customized IR framework is challenging**)
4. The MLIR project aims to directly tackle these programming language design and implementation challenges—by making it very cheap to deﬁne and introduce new abstraction levels, and provide “in the box” infrastructure to solve common compiler engineering problems. MLIR does this by
	- standardizing the Static Single Assignment (SSA)-based IR data structures
	- providing a declarative system for deﬁning IR dialects (demonstrated below using the Toy example)
	- providing a wide range of common infrastructure (including documentation, parsing and printing logic, location tracking, multithreaded compilation support, pass management, etc).

This image shows that most high-level languages have their own AST and associated infrastructure for transforming etc. Though language-specific, these are modules doing similar things. MLIR is a general framework to facilitate the development of such language-specific modules. It allows developers to use a unified codebase/framework to do their optimizations and develop some common, shared optimizations for multiple inputs.

I recommend reading Toy Example Tutorial for a deep understanding.

![Screen Shot 2022-03-26 at 08.24.47.png](https://res.craft.do/user/full/55556ffd-6bd0-f98b-802b-8680fc9006d8/doc/C108C7BD-1633-4A3C-AA6B-C7CC05C399F2/52181421-3c4c-4b2e-a279-c9098115ce58)

This image is MLIR’s original motivation. They found that *ML graphs* have a lot of different compilers. The compilation process is fragmented and some compilers are not following the best practices.

![Screen Shot 2022-03-26 at 08.50.23.png](https://res.craft.do/user/full/55556ffd-6bd0-f98b-802b-8680fc9006d8/F89AC27B-EB56-45AC-9009-D52DBEE9221C_2/4n18Uryiocyh9pUbGnZ5OfJrfydBxYrofThywU8wamcz/Screen%20Shot%202022-03-26%20at%2008.50.23.png)

## Case Studies

### Example 1: [MLIR Toy Example](https://mlir.llvm.org/docs/Tutorials/Toy/)

While reading through its documentation, I’m starting to get a sense of what problem MLIR is trying to solve. The MLIR paper for sure describes the problem at a high level, but being able to read through the code example and its documentation helps a lot.

The following quote is the same motivation described in the MLIR paper.
> Other compilers, like LLVM (see the [Kaleidoscope tutorial](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/index.html)), offer a fixed set of predefined types and (usually *low-level* / RISC-like) instructions.
>
> ***It is up to the frontend for a given language to perform any language-specific type-checking, analysis, or transformation before emitting LLVM IR. <- also mentioned in the MLIR paper.***
>
> For example, **Clang will use its AST** to perform not only static analysis but also transformations, such as C++ template instantiation through AST cloning and rewrite. Finally, languages with construction at a higher level than C/C++ may **require non-trivial lowering from their AST to generate LLVM IR**.
>
> Consequently, **multiple frontends end up reimplementing significant pieces of infrastructure to support the need for these analyses and transformations**. MLIR addresses this issue by being designed for extensibility. There are few pre-defined instructions (*operations* in MLIR terminology) or types.


Like C, Swift, Rust, etc., each language has its own AST optimizers that do some language-specific transformations and analysis. This is quite tedious to do. So:

> MLIR is designed to allow all IR elements, such as attributes, operations, and types, to be customized. At the same time, IR elements can always be reduced to the above fundamental concepts. **This allows MLIR to parse, represent, and** [**round-trip**](https://mlir.llvm.org/getting_started/Glossary/#round-trip)** IR for *any* operation.**


This is EXACTLY what I want to say for the APSys submission.
> Through dialects, MLIR allows for the representation of many different levels of abstraction; the Toy dialect that we have previously defined is one such example.
>
> ***Though these different dialects may represent different abstractions, there is often a set of common transformations and analyses that we would like to perform.***

**The blog builds the Toy Example following these steps**:

1. It first defines the semantics of this toy language and some simple operations. It then defines an IR for the Toy language in an MLIR dialect. MLIR can transform the source code into its internal IR using the above dialect.
2. It then performs "*High-level Language-Specific Analysis and Transformation*" and other optimizations on the generated IR within MLIR. The transformations are pretty straightforward, such as eliminating duplicated ops. These optimizations, however, would be difficult for LLVM to carry out.
3. It then discussed *an MLIR internal interface infrastructure* that facilitates the above transformations. The rationale is that most transformations used by distinct languages are similar, hence a framework can reduce code duplication and also allow developers to design a set of shared common optimizations/passes.
4. Then, the interesting part. It *converts* this Dialect into other MLIR built-in dialects (e.g., affine, arithmetic), thereby lowering the toy Dialect into more concrete memory accesses, and arithmetic ops, etc.
5. Finally, it again lowers the above partially-lowered IR onto the LLVM IR. Once we are here, we can invoke LLVM to generate code (e.g., for x86 or ARM CPUs) or run with the LLVM JIT. Of course, instead of lowering it onto the LLVM IR, one can also lower it onto another IR, e.g., TPU IR (what TensorFlow does).

**My understanding**

- MLIR is a generic framework that allows you to define your customized IR using MLIR's generic primitives (i.e., an indirection layer). From MLIR's perspective, your IR is just one of the many dialects it supports.
- More importantly, a dialect can fully or partially convert into other dialects. For instance, if you convert your IR into the LLVM IR, you can immediately take advantage of the LLVM's code-generation framework for CPUs. If you convert your IR into the TPU IR, you can then generate code running on TPUs.

**Say I want to build some P4 or FPGA stuff using MLIR, I would do**:

1. I would first define a language model together with a new IR using MLIR primitives.
2. Then, within MLIR, I would do all sorts of language-specific optimizations, transformations, etc. I can also do some conversions among other dialects.
3. After all that, say I've got an optimized IR. What should I do next? I cannot fully lower it to the LLVM IR, because there is no P4/FPGA backend in the LLVM framework.
   1. If I target FPGA, I could generate FIRRTL, which is the input of *CIRCIT* or *Chisel*.
   2. If I target P4, I could generate the MLIR IR into something like a P4 IR/backend, which then will do vendor-specific compilation into deployable binaries.
4. Is this *P4 IR thing* already part of the p4 compiler chain? If so, why should I go through all this trouble adding a new MLIR dialect, why not directly use the p4 compile chain? What benefits are we getting out of MLIR though?
   1. Answer: we will benefit from MLIR only if we are targeting multiple backends at the same time, thus we can share the same optimization infrastructure. In specific, one piece of code can run on top of a set of heterogeneous devices. All the optimizations are nicely done within the MLIR layer.

### Example 2: Google IREE

[IREE](https://google.github.io/iree/)

IREE (**I**ntermediate **R**epresentation **E**xecution **E**nvironment[1](https://google.github.io/iree/#fn:1)) is an [MLIR](https://mlir.llvm.org/)-based end-to-end compiler and runtime that lowers Machine Learning (ML) models to a unified IR

I’m not exactly sure what IREE is doing. Overall, it takes an ML program and tries to transform it into scheduling and computation modules run on various hardware components.

- The bottom right part is interesting. You can see that it can lower onto the LLVM IR, further generating codes for various CPUs; it can also lower onto SPIR-V IR, a special IR defined for GPUs. I'm not sure what VMVX is.

![Screen Shot 2022-03-26 at 09.10.42.png](https://res.craft.do/user/full/55556ffd-6bd0-f98b-802b-8680fc9006d8/F02E751A-340E-4AC1-AECD-8502450676BD_2/fHUo9RWXbyDU1RgAjOQSIlmhpiKpyxhDFl6ig8y4kdUz/Screen%20Shot%202022-03-26%20at%2009.10.42.png)

### Example 3: LLVM CIRCT

CIRCT’s inputs:

1. Chisel's FIRRTL
2. MLIR's output

CIRCT's outputs:

1. Verilog
2. C++?
3. TCL?

![Screen Shot 2022-03-26 at 12.11.37.png](https://res.craft.do/user/full/55556ffd-6bd0-f98b-802b-8680fc9006d8/8CF12468-C5DA-4555-B833-0051342D1640_2/OfxTbXZg3eUNbphX1tWByxSvBjN5QEMwRwxCoEVDYG8z/Screen%20Shot%202022-03-26%20at%2012.11.37.png)

[CIRCT Charter - CIRCT](https://circt.llvm.org/docs/Charter/)

[https://llvm.org/devmtg/2021-11/slides/2021-CIRCT-LiftingHardwareDevOutOfThe20thCentury.pdf](https://llvm.org/devmtg/2021-11/slides/2021-CIRCT-LiftingHardwareDevOutOfThe20thCentury.pdf)

- CIRCT implements its own FIRRTL parser, so it can take an FIR file to generate RTL
- Other than that, CIRCT could also take MLIR outputs to generate RTL.
- Apparently, CIRCT also uses the Dialects concepts.

![Screen Shot 2022-03-26 at 12.03.35.png](https://res.craft.do/user/full/55556ffd-6bd0-f98b-802b-8680fc9006d8/9D957931-486E-476E-95A4-1F1737060FCA_2/OH2HCgV3d7oxbZKmTSoJ7CjyolqxtN97DZpFFNYBdrkz/Screen%20Shot%202022-03-26%20at%2012.03.35.png)

![Screen Shot 2022-03-26 at 12.07.12.png](https://res.craft.do/user/full/55556ffd-6bd0-f98b-802b-8680fc9006d8/76C90AD7-0D5E-4065-8D78-9EE777448D09_2/qqqd249WUm24ANyx7mAApu2UBOmpuor30V7sPiMlOMcz/Screen%20Shot%202022-03-26%20at%2012.07.12.png)

### Example 4: TensorFlow/PyTorch with MLIR

Torch-MLIR: [https://github.com/llvm/torch-mlir](https://github.com/llvm/torch-mlir)

- It compiles some Torch operations into a newly defined ***torch-dialect*** in MLIR.
- Within MLIR, the torch-dialect is further lowered onto built-in dialects such as affine
- [https://github.com/llvm/torch-mlir/blob/main/Torch-MLIR.png](https://github.com/llvm/torch-mlir/blob/main/Torch-MLIR.png)

![Screen Shot 2022-03-26 at 10.49.08.png](https://res.craft.do/user/full/55556ffd-6bd0-f98b-802b-8680fc9006d8/4FA7EEE6-B140-41FD-A817-E79DE9A8240A_2/miINPYeQwLU1EK2cB2JqmuzgjcaZHLNjlaeQMxr9eqoz/Screen%20Shot%202022-03-26%20at%2010.49.08.png)

### Example 5: ScaleHLS, HPCA’22

[https://github.com/hanchenye/scalehls](https://github.com/hanchenye/scalehls)

[https://raw.githubusercontent.com/hanchenye/scalehls/master/docs/ScaleHLS.svg](https://raw.githubusercontent.com/hanchenye/scalehls/master/docs/ScaleHLS.svg)  The whole system is implemented on top of MLIR. They introduced a new `HLSCPP` dialect. They take HLS C programs, or TORCH/ONNX graph-level programs, then produce highly-optimized HLS C/C++ programs.

It is a very interesting read. The following image shows its workflow.

![Screen Shot 2022-03-26 at 11.03.07.png](https://res.craft.do/user/full/55556ffd-6bd0-f98b-802b-8680fc9006d8/F3E059BD-1D25-4079-906A-0473EC00F25B_2/zn4K6fBjzy8dq2lJKtJbqtFYkV7OBRCHRTW59y0dTykz/Screen%20Shot%202022-03-26%20at%2011.03.07.png)

My thought: I think we will continue seeing more MLIR-based solutions
to help DSA development. It'll be interesting to see some higher-level,
or higher-order primitives constructed in MLIR to help, say, FPGA-based
SQL develpoment (or rather, any types of FPGA-based computations).
In general, MLIR helps to raise the abstrantion, hence we are able
to raise the programmability futher.

### Example 6: EQueue, HPCA'22

Compiler-Driven Simulation of Reconfigurable Hardware Accelerators, HPCA'22.

- The goal is to help simulation.
- Add a new dialect in MLIR to model different accelerators.
- There are two general approaches to do simulation: 1) use RTL-level, which is very precise and also very slow. 2) use high-level simulators, sth like gem5. Fast, but is far away from hardware.
- The goal of this paper is to use MLIR to build sth in the middle. It introduces a new dialect IR, which can describe various accelerator structure (e.g., how many processors, memory, DMA engines etc). Since MLIR can lower IR, their system can model the accelerator at different levels. On one extreme, they can do very high-level simulation (probably just use their new IR). On the other extreme, they can lower their IR to be close to actual hardware.
- Check their Fig3-Fig5 to understand how they can model different accelerators!

### Example 7: Pathways, Google

The paper is [Pathways: Asynchronous Distributed Dataflow For ML, arXiv'22](https://arxiv.org/pdf/2203.12533.pdf)

From the paper:

> "Sec 4.2: The client then constructs a device location-agnostic PATHWAYS intermediate representation (IR) for the program, expressed as a custom MLIR (Lattner et al., 2021) dialect. The IR is progressively “lowered” via a series of standard compiler passes, which eventually output a low-level representation that includes the physical device locations. This low-level program takes into account the network connectivity between physical devices and includes operations to transfer outputs from a source computation shard to the locations of its destination shards, including scatter and gather operations when a data exchange is required."

### Example 8: DAPHNE, CIDR22

[DAPHNE](https://daphne-eu.eu/) is an extensive open framework that unites ML, HPC, and data management workloads.
It uses MLIR to build operators and data representations (e.g., tensor, matrix).

### Example 9: LingoDB, VLDB22

[LingoDB](https://www.vldb.org/pvldb/vol15/p2389-jungmair.pdf) is quite interesting. I don't have enough knowledge to understand the paper well.
But it appears to co-design database's query optimizer and underlying operators.
The query optimizations are implemented as MLIR passes.

### Example 10: Mojo

The Modular.AI's first production releasing video is really exciting.
Chris and the his team introduced another amazing programming language to the world.
The [doc](https://docs.modular.com/mojo/notebooks/BoolMLIR.html) says Mojo's low-level primitives are built on top of MLIR.
I'm still on waiting list to try Mojo out :)

### Misc

Alpa, arXiv'21 proposes a set of methods to partition an ML
training process to best utilize pipeline, data, model parallelism.
This seems to be the first one doing all 3 at once. 
There are, of course, similar papers in the past doing 2 out of 3
(a paper from the Stanford folks).

TVM IP stuff is also highly related.


## General PL Related Readings

1. Saw this paper on twitter today (03/25/2022). It won the ICSE influential award. [https://people.inf.ethz.ch/suz/publications/natural.pdf](https://people.inf.ethz.ch/suz/publications/natural.pdf)

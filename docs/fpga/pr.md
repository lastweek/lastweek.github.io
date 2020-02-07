# Morphous (Dynamic-sized) Partial Reconfiguration

:ox:

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Feb 6, 2020 | Created |

Traditional partital reconfiguration (PR) is limited to using fix-sized PR regions.
With one particular static bitstream, users are restricted to only have few pre-defined PR regions.
If you wish to extend the PR region size, a whole chip reprogram is needed to burn a new static bitstream.

This practice is suggested by FPGA vendors, and there are reasons behind it.

However, during our experiment, we found that it is possible to have dynamic-sized PR regions
with one static design. The mechanism is quite straightforward with some simple hacks.

I will use a MicroBlaze-based design to demonstrate the approach with a VCU118 board. Stay tuned.

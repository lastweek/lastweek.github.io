# Misc

If we want to do relocation, we need to be careful:
- identical areas in terms of shape, resource distribution within
- proxy logic (i.e., partition pins) location within the PR partition
- the wire between proxy logic and static region.
    - I think this might cause timing issue?


The `lock_design` in Vivado is to ensure the routing between static region
and all the PR partitions remain the same.

Proxy Logic and Bus Macro
- S1: Relocation of reconfigurable modules on Xilinx FPGA
- S2: A Highly Flexible Reconfigurable System on a Xilinx FPGA

Expansion of `CONTAIN_ROUTING Area`

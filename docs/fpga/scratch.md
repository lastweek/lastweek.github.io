# Scratch Commands

```
get_property LOC [get_cells count_out_OBUF[3]_inst]

get_property ROUTE $net

This returns a list of *nodes*. We can also see this in the GUI.
% get_property ROUTE [get_nets inst_count/count_out[0]]

Manually lock a route:
set_property FIXED_ROUTE [get_property ROUTE [get_nets inst_count/count_out[0]]] [get_nets inst_count/count_out[0]]
```

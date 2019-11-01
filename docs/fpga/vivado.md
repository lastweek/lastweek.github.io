# Vivado Practice

:dragon_face:

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Oct 31, 2019 | Happy Halloween|
	|Sep 20, 2019 | Created |

## Tricks

This list will be updated frequently.


#### Get the List of Partition Pins

The partition pins are inserted by Vivado at the boundary of a PR region.
`PartPin` is short for Partition Pins.
`PPLOC` is short for Partpin LOC.

```tcl
get_pplocs -pin [get_pins -hier *]
```

#### Disable Expansion of `CONTAIN_ROUTING` Area

The contained routing requirement of RP Pblocks for UltraScale and UltraScale+ devices has
been relaxed to allow for improved routing and timing results. Instead of routing being
confined strictly to the resources owned by the Pblock, the routing footprint is expanded.

This option is enabled by default.
when this option is enabled, not all interface ports receive a partition pin.

When you disable this option, the implications are:
1) each interface port (per bit) receivces a partition pin,
2) `hd_visual/` will not be generated.

This command is useful when you want to do some hacking about Partition Pins.

```tcl
set_param hd.routingContainmentAreaExpansion false
```

## Read-the-docs

- [UG912 Vivado Properties Reference Guide](https://www.xilinx.com/content/dam/xilinx/support/documentation/sw_manuals/xilinx2019_1/ug912-vivado-properties.pdf<Paste>)
	- Excellent resource on explaining cell, net, pin, port, and so on.
	- `pin`: A pin is a point of logical connectivity on a primitive or
	hierarchical cell. A pin allows the contents of a cell to be abstracted away,
	and the logic simplified for ease-of-use. A pin is attached to a cell and can be connected to pins on other cells by a net.
	- `port`: A port is a special type of hierarchical pin, providing an external connection point at the
	top-level of a hierarchical design, or an internal connection point in a hierarchical cell or
	block module to connect the internal logic to the pins on the hierarchical cell. 
	- `cell`: A cell is an instance of a netlist logic object, which can either be a leaf-cell or a hierarchical
	cell. A leaf-cell is a primitive, or a primitive macro, with no further logic detail in the netlist.
	A hierarchical cell is a module or block that contains one or more additional levels of logic,
	and eventually concludes at leaf-cells. .. cells have PINs which are connected to NETs to define the external
	netlist... The CELL can be placed onto a BEL object in the case of basic logic such as flops, LUTs, and
	MUXes; or can be placed onto a SITE object in the case of larger logic cells such as BRAMs and DSPs.
	- `net`: A net is a set of interconnected pins, ports, and wires. Every wire has a net name, which
	identifies it. Two or more wires can have the same net name. All wires sharing a common net
	name are part of a single NET, and all pins or ports connected to these wires are electrically connected. ..
	In the design netlist, a NET can be connected to the PIN of a CELL, or to a PORT. ..
	As the design is mapped onto the target Xilinx FPGA, the NET is mapped to routing
	resources such as WIREs, NODEs, and PIPs on the device, and is connected to BELs through
	BEL_PINs, and to SITEs through SITE_PINs. 
	- `pblock`: A Pblock is a collection of cells, and one or more rectangular areas or regions that specify
	the device resources contained by the Pblock. Pblocks are used during floorplanning
	placement to group related logic and assign it to a region of the target device.
		- ??? example
			create_pblock Pblock_usbEngine  
			add_cells_to_pblock [get_pblocks Pblock_usbEngine] [get_cells -quiet [listusbEngine1]]  
			resize_pblock [get_pblocks Pblock_usbEngine] -add {SLICE_X8Y105:SLICE_X23Y149}  
			resize_pblock [get_pblocks Pblock_usbEngine] -add {DSP48_X0Y42:DSP48_X1Y59}  
			resize_pblock [get_pblocks Pblock_usbEngine] -add {RAMB18_X0Y42:RAMB18_X1Y59}  
			resize_pblock [get_pblocks Pblock_usbEngine] -add {RAMB36_X0Y21:RAMB36_X1Y29}
	- `CONTAIN_ROUTING`: The `CONTAIN_ROUTING` property restricts the routing of signals contained within a Pblock
	to use routing resources within the area defined by the Pblock. This prevents signals inside
	the Pblock from being routed outside the Pblock, and increases the reusability of the design.
		- This is useful when you are trying to do advanced PR hacks.

- [Book: Practical Programming in Tcl and Tk](http://www.beedub.com/book/tkbook.pdf)
- [UG894 Vivado Using TCL scripting](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug894-vivado-tcl-scripting.pdf)
	- Get you started with Vivado TCL
- [UG835 Vivado TCL Reference Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug894-vivado-tcl-scripting.pdf)
	- aka. Vivado TCL Man Page

- [UG909 Partial Reconfiguration](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug909-vivado-partial-reconfiguration.pdf)
	- `Partition Pins`
		- Interface points called partition pins are automatically created within the Pblock ranges
		defined for the Reconfigurable Partition. These virtual I/O are established within
		interconnect tiles as the anchor points that remain consistent from one module to the next.
		- In UltraScale or UltraScale+ designs, __not all interface ports receive a partition pin__. With the
		__routing expansion__ feature, as explained in Expansion of `CONTAIN_ROUTING` Area, some
		interface nets are completely contained within the expanded region. When this happens, no
		partition pin is inserted; the entire net, including the source and all loads, is contained
		within the area captured by the partial bit file. Rather than pick an unnecessary
		intermediate point for the route, the entire net is rerouted, giving the Vivado tools the
		flexibility to pick an optimal solution.
		- ??? exmaple
			set_property HD.PARTPIN_LOCS INT_R_X4Y153 [get_ports <port_name>]  
			set_property HD.PARTPIN_RANGE SLICE_X4Y153:SLICE_X5Y157 [get_ports <port_name>]  
			set_property HD.PARTPIN_RANGE {SLICE_Xx0Yx0:SLICE_Xx1Yy1 SLICE_XxNYyN:SLICE_XxMYyM} [get_pins <rp_cell_name>/*]<Paste>
		- These pins can be manually relocated and locked.



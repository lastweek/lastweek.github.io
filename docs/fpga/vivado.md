# Vivado Practice

:dragon_face:

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Nov 5, 2019 | More stuff|
	|Nov 4, 2019 | Add UG903 |
	|Oct 31, 2019 | Happy Halloween|
	|Sep 20, 2019 | Created |

---

## Cheatsheet

### Partition Pins

The partition pins are inserted by Vivado at the boundary of a PR region.
`PartPin` is short for Partition Pins.
`PPLOC` is short for Partpin LOC.

Get the list of partition pins:
```tcl
get_pplocs -pins [get_pins -hier *]
```

Partition pin (seems) map to a NODE:
```tcl
% report_property [get_pplocs -pins [get_pins XXX]]
% report_property [get_pplocs -pins [get_pins inst_count/count_out[0]]]

INFO: [Vivado 12-4841] Found PartPin: INT_X17Y790/NN1_E_BEG3
Property           Type    Read-only  Value
BASE_CLOCK_REGION  string  true       X0Y13
CLASS              string  true       node
```

---
### Pblocks

#### Semantic of `EXCLUDE_PLACEMENT`

The document describe this as: Pblock property that prevents the _placement_ of any logic not
belonging to the Pblock inside the defined Pblock range.

During my own simple experiment, I found that even Vivado will not place other logics
into the Pblock, _the routes of static region_ can still go across pblock.

#### Semantic of `CONTAIN_ROUTING`

References: UG909 and UG905.

The contained routing requirement of RP Pblocks for UltraScale and UltraScale+ devices has
been relaxed to allow for improved routing and timing results. Instead of routing being
confined strictly to the resources owned by the Pblock, the routing footprint is expanded.

Note that this option is enabled by default. When this option is enabled,
1) not all interface ports receive a partition pin,
2) the RP will use routing resources outside its confined area. This is annonying in some way.

If this option is disabled, the implications are:
1) each interface port (per bit) receivces a partition pin,
2) RP will only resources confined to its pblocks,
3) the generated PR bitstream will be smaller,
4) `hd_visual/` will not be generated.

However, this option does not prevent routings from the static region from crossing RPs.

This command is useful when you want to do some hacking about Partition Pins.
Actually, you can also do this via GUI.

```tcl
set_param hd.routingContainmentAreaExpansion false
```

---
### Clear RM and Lock Down Static

These commands clear out the Reconfigurable Module logics from the whole design
and then lock down the static region and static routing. (Reference: UG947)

```tcl
update_design -cell XXX -black_box

lock_design -level routing
```

---
### Routing

#### Get the routing of a net

```tcl
set net [get_nets XXX]
get_property ROUTE $net
```

#### Lock the routing of a net

We need to lock both the net and the connected cells. Reference is UG903.

Following commands lock a route of a net. This net is already routed.
You could run one by one.
After execution, the route will become dashed (means locked).
Replace the net name with your interested one.
```bash
set net [get_nets inst_count/count_out[0]]
get_property ROUTE $net
set_property FIXED_ROUTE [get_property ROUTE $net] $net

set_property is_bel_fixed 1 [get_cells XXX]
set_property is_loc_fixed 1 [get_cells XXX]
```

#### Manual routing

A great GUI-based manual routing tutorial can be found at [UG986 Lab 3](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug986-vivado-tutorial-implementation.pdf). The last step of manual routing, of course is to lock down the LOC and set `FIXED_ROUTE`.

But how can we manually route an unrouted net?
The difficulty is that we need to manually find out all the connection nodes/tiles etc..
This applies to LOC placement as well.



---
## Read-the-docs

Basic

- [UG912 Vivado Properties Reference Guide](https://www.xilinx.com/content/dam/xilinx/support/documentation/sw_manuals/xilinx2019_1/ug912-vivado-properties.pdf<Paste>)
	- Excellent resource on explaining cell, net, pin, port, and so on.
	- Differentiate `Netlist Objects` and `Device Resource Objects`.
		- `Netlist Objects`
			- `pin`: A pin is a point of logical connectivity on a primitive or
				hierarchical cell. A pin allows the contents of a cell to be abstracted away,
				and the logic simplified for ease-of-use. A pin is attached to a cell and can be connected to pins on other cells by a net.
				`get_pins -of [get_cells XXX]`. `get_pins XXX`
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
		- `Device Resource Objects`
			- `BEL`: 1) leaf-level cells from the netlist design can be mapped onto bels on the target part
				2) Bels are grouped in sites. 3) Each bel has bel_pins that map to pins on the cells.
				4) `get_bels -of [get_cells XX]`, `get_bels -of [get_nets XX]`, and so on.
			- `BEL_PIN`: 1) a pin or connection point on a BEL object. 2) BEL_PIN is a device object,
				associated with netlist objects such as the PIN on a CELL, which is the connection point for the NET.
				3) `get_bel_pins -of_objects [get_pins -of [get_cells XXX]]`
			- `TILE`
			- `SITE`
			- `NODE`
			- `WIRE`
			- `PIP`
	- `CONTAIN_ROUTING`: The `CONTAIN_ROUTING` property restricts the routing of signals contained within a Pblock
	to use routing resources within the area defined by the Pblock. This prevents signals inside
	the Pblock from being routed outside the Pblock, and increases the reusability of the design.
		- This is useful when you are trying to do advanced PR hacks.
- [UG835 Vivado TCL Reference Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug894-vivado-tcl-scripting.pdf)
	- aka. Vivado TCL Man Page. Read this with the above UG912.
- [UG894 Vivado Using TCL scripting](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug894-vivado-tcl-scripting.pdf)
	- Get you started with Vivado TCL
- [UG903 Using Constraints](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug903-vivado-using-constraints.pdf)
	- About Xilinx XDC files. You will need to understand UG912 first.
	- Physical Constraints
		- `DONT_TOUCH`. Prevent netlist optimizations. 1) prevent a net from being optimized away. 2) Prevent merging of manually replicated logic.
		- Placement constraints
		- Routing constraints

- [Book: Practical Programming in Tcl and Tk](http://www.beedub.com/book/tkbook.pdf)


Partial Reconfiguration Related

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
- [UG905 Hierarchical Design](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2019_1/ug905-vivado-hierarchical-design.pdf)
	- Add the `CONTAIN_ROUTING` property to all OOC Pblocks. Without this property,
	`lock_design` cannot lock the routing of an imported module because it cannot be
	guaranteed that there are no routing conflicts

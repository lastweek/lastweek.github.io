# Vivado Practice

:dromedary_camel:

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Oct 31, 2019 | Happy Halloween|
	|Sep 20, 2019 | Created |

## Basic Knowledge

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


- [Book: Practical Programming in Tcl and Tk](http://www.beedub.com/book/tkbook.pdf)
- [UG835 Vivado TCL Command Reference Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug894-vivado-tcl-scripting.pdf)
	- Good reference if you are hacking TCL scripts. 


## Tricks

We have a lot juicy hackings. Stay tuned.

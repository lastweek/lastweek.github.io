# Modern Virtualization Technology

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Jun 22, 2021| add steps and bare-metal virt |
	|Dec 31, 2020| minor update|
	|Feb 4, 2020| Add VFIO stuff|
	|Jan 26, 2020| Minor adjustment|
	|Jan 25, 2020| Initial Document|

## Intro

Why this doc?
I started this when I was trying to understand how virtualization actually works.
I was just reading QEMU/KVM and taking notes, but I end up exploring more.
Most of the stuff is just basic but hopefully you find them useful.

Favorite quote about QEMU (in fact, about virtualization in general):

!!! quote
     And at the end of the day, all virtualization really means is running a particular set of assembly instructions (the guest OS) to manipulate locations within a giant memory map for causing a particular set of side effects, where QEMU is just a user-space application providing a memory map and mimicking the same side effects you would get when executing those guest instructions on the appropriate bare metal hardware

Also check out [Awesome-Virtualization](https://github.com/Wenzel/awesome-virtualization/issues).

## History of Virtualization

1. Software-based Virtualization. This is where VMware started. No hardware support but just smart software tricks. You should read their papers.
2. Para-virtualization. This is what Xen invented. They changed the guest OS for a better emulation. No hardware support still. But the guest OS is changed.
3. Hardware-assited virtualization. This is what AMD and Intel Vt-d + IOMMU for. The CPU would support virtualization mode and non-virtualization mode (in x86, each mode has Ring 0-3). However, the hardware change alone cannot work. They must work a virtual machine monitor for at least device emulation and other things. This is where KVM and QEMU came in. KVM lets Linux able to use those hardware features and turn Linux into a type-2 hypervisor. QEMU, acting as a VMM, helps setup KVM and emulates devices.
4. Offload virtualization to dedicated hardware. This is what big cloud vendors are doing. For example, AWS Nitro cards, Mirosoft FPGA based SmartNIC cards.
Rather than using QEMU (or vendor kernel) to emulate storage/network devices, these vendors build customized cards that would handle all that in hardware!
Guest VMs are not aware of these because they only see the MMIO spaces. It is just that the MMIO space directly maps a to real hardware rather than captured by QEMU. This approach can greatly save host CPU usage, hence reduce Datacenter Virtualization Tax.
5. Bare-metal virtualization. Going back to where we started!

## Modern Virtualization Hardware

Examples AWS Nitro cards, Microsoft FPGA based SmartNIC cards.

### Principles

TODO

### Case Studies

TODO

1. Network Device and VNF
2. Block layer NVMe
3. Security
4. more

## Note

The questions I've focused on are:
- 1) how QEMU emulates all the devices.
- 2) how KVM uses CPU features to switch between VMs, catch faults, return to QEMU etc.
- 3) how KVM and QEMU work together.
- 4) how virto works and how device-passthrough works (via VFIO).
- 5) Finally, if I want to write a new virtual machine monitor like QEMU,
what should I build. Several recent projects (e.g., rust-vmm, firecracker) have hints on this.

- <a href="https://gdoc.pub/doc/e/2PACX-1vSsskD0A2XgHoZhaYLAkS7lmCOrfxkGXk1WTovWEAyeoELVdBjrE-NzD8h-NvJfKhxMpUg2aXzaD-XG" target="_blank">Google Doc Version</a>
- <a href="http://lastweek.io/pubs/virt_note.pdf" target="_blank">PDF Version</a>

<iframe style="width: 100%; height: 800px;" frameborder="1" allowfullscreen 
    src="https://docs.google.com/document/d/e/2PACX-1vSsskD0A2XgHoZhaYLAkS7lmCOrfxkGXk1WTovWEAyeoELVdBjrE-NzD8h-NvJfKhxMpUg2aXzaD-XG/pub?embedded=true">        
</iframe>

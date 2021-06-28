# Virtualization

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Jun 22, 2021| add steps and bare-metal virt |
	|Dec 31, 2020| minor update|
	|Feb 4, 2020| Add VFIO stuff|
	|Jan 26, 2020| Minor adjustment|
	|Jan 25, 2020| Initial Document|

Also check out [Awesome-Virtualization](https://github.com/Wenzel/awesome-virtualization/issues)

Why? In order to truly understand the whole virtualization thing,
I decided to read QEMU/KVM/etc source code.
The document was orginally written in a Google Document.

The questions I've focused on are:

- 1) how QEMU emulates all the devices (essentially, CPU and device communicates via addresses,
and this is where all the tricks happen),
- 2) how KVM uses CPU features to switch between VMs, catch faults, return to QEMU etc,
- 3) how KVM and QEMU work together,
- 4) how virto works and how device-passthrough works (via VFIO),
- 5) and finally, if I want to write a new virtual machine monitor like QEMU,
what should I build. Several recent projects (e.g., rust-vmm, firecracker)
have some hints on this.

My favorite quote about QEMU (in fact, about virtualization in general):

!!! quote
     And at the end of the day, all virtualization really means is running a particular set of assembly instructions (the guest OS) to manipulate locations within a giant memory map for causing a particular set of side effects, where QEMU is just a user-space application providing a memory map and mimicking the same side effects you would get when executing those guest instructions on the appropriate bare metal hardware

## History of Virtualization

1. Software-based Virtualization. This is where VMware started. No hardware support. Smart tricks.
2. Para-virtualization. This is what Xen invented. They will change the guest OS in order for better emulation. No hardware support. But the guest OS is changed.
3. Hardware-assited virtualization. This is what AMD and Intel Vt-d, IOMMU started. The CPU itself would support virtualization mode and non-virtualization mode. The hardware change alone cannot work. They are usually used to accelerate existing technologies. Hence, you can run Xen+Vt-d, QEMU+Vt-d (which is enabled by KVM).
4. Offload virtualization to dedicated hardware, e.g., AWS Nitro. Rather than using QEMU (or vendor kernel) to emulate storage/network devices, they build customized cards that would handle all that in hardware! The idea is simple, the guest MMIO space would be handled by the dedicated device. This approach can greatly save host CPU usage. Exmaples: AWS Nitro, Microsoft SmartNIC for their network offloading (i.e., openvswitch), Huawei. Google seems doing everything in SW.
5. Bare-metal virtualization.

## Note

- <a href="https://gdoc.pub/doc/e/2PACX-1vSsskD0A2XgHoZhaYLAkS7lmCOrfxkGXk1WTovWEAyeoELVdBjrE-NzD8h-NvJfKhxMpUg2aXzaD-XG" target="_blank">Google Doc Version</a>
- <a href="http://lastweek.io/pubs/virt_note.pdf" target="_blank">PDF Version</a>

<iframe style="width: 100%; height: 800px;" frameborder="1" allowfullscreen 
    src="https://docs.google.com/document/d/e/2PACX-1vSsskD0A2XgHoZhaYLAkS7lmCOrfxkGXk1WTovWEAyeoELVdBjrE-NzD8h-NvJfKhxMpUg2aXzaD-XG/pub?embedded=true">        
</iframe>

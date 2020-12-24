# Notes on Virtualization

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Feb 4, 2020| Add VFIO stuff|
	|Jan 26, 2020| Minor adjustment|
	|Jan 25, 2020| Initial Document|

:rat:

In order to understand the whole virtualization thing, I decided to read QEMU/KVM/etc source code.
The document was orginally written in a Google Document, the following presentation
is just an embedded version.
For better readibility, you can also check out the:

I'd also recommend some reading on the histoy of virtualization.
It goes from software-based virt, to paravirt, to hardware-assisted virt, and now even on separate hw cards (e.g., AWS Nitro cards).

- <a href="https://gdoc.pub/doc/e/2PACX-1vSsskD0A2XgHoZhaYLAkS7lmCOrfxkGXk1WTovWEAyeoELVdBjrE-NzD8h-NvJfKhxMpUg2aXzaD-XG" target="_blank">Google Doc Version</a>
- <a href="http://lastweek.io/pubs/virt_note.pdf" target="_blank">PDF Version</a>

<iframe style="width: 100%; height: 800px;" frameborder="1" allowfullscreen 
    src="https://docs.google.com/document/d/e/2PACX-1vSsskD0A2XgHoZhaYLAkS7lmCOrfxkGXk1WTovWEAyeoELVdBjrE-NzD8h-NvJfKhxMpUg2aXzaD-XG/pub?embedded=true">        
</iframe>

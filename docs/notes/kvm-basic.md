# Just some basics about KVM

Update: you can fine more info here https://gdoc.pub/doc/e/2PACX-1vSsskD0A2XgHoZhaYLAkS7lmCOrfxkGXk1WTovWEAyeoELVdBjrE-NzD8h-NvJfKhxMpUg2aXzaD-XG.

## Resources

- [Intel Virtualisation: How VT-x, KVM and QEMU Work Together](https://binarydebt.wordpress.com/2018/10/14/intel-virtualisation-how-vt-x-kvm-and-qemu-work-together/)

## Hacking Notes

If you are hacking some low-level stuff that is running as a VM,
pay close attention if KVM is involved. I started this note because
I spent sometime twisting `page_fault` IDT entry, but it turns out
KVM uses `async_page_fault`. Oh, well.

- KVM page fault entry (`arch/x86/entry/entry_64.S`)
    - It is `idtentry async_page_fault       do_async_page_fault     has_error_code=1`
    - ..not `idtentry page_fault             do_page_fault           has_error_code=1`


## More on Virturlization

Well. I swear I want to learn more about Virturlization..

- Intel SDM, volume 3, Chapter 23 - Chapter 33.

--  
Yizhou Shan  
Created: May 20, 2019  
Last Updated: Sep 11, 2019

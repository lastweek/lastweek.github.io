# Just some basics about KVM

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


--  
Yizhou Shan  
Created: May 20, 2019  
Last Updated: Aug 03, 2019

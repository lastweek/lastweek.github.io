# Just some basics about KVM

If you are hacking some low-level stuff that is running as a VM,
pay close attention if KVM is involved. I started this note because
I spent sometime twist `page_fault` IDT entry, but it turns out
KVM uses `async_page_fault`. Well.

- KVM page fault entry. File: `arch/x86/entry/entry_64.S`
	- It is `idtentry async_page_fault       do_async_page_fault     has_error_code=1`
	- ..not `idtentry page_fault             do_page_fault           has_error_code=1`

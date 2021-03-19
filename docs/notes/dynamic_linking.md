# Dynamic Linking

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Mar 19, 2021| add sth about LD_PRELOAD |
	|Jan 01, 2021| Add kernel module loading part|
	|Dec 24, 2020| Adopted from my previous [note](https://github.com/lastweek/source-glibc)|

:rowboat:

This blog looks at some part of the user-space dynamic linker,
how kernel loads user program, and how kernel loads kernel modules.

The related code: glibc, kernel execve loader, kernel module loader.

---

## C Start Up (csu)

For code pointers, see the glibc code [here](https://github.com/lastweek/source-glibc).

In glibc:

- `csu/libc-start.c`
- `__libc_start_main()` is the entry point.
  Inside, it will call `__libc_csu_init()`.
  Then it will call user's `main()`.
- Great reference: [Linux x86 Program Start Up](http://dbp-consulting.com/tutorials/debugging/linuxProgramStartup.html).
  I saved a printed [PDF copy](assets/Linux-x86-Program-Start-Up.pdf) in this repo.

## Dynamic Linking in User Space

The dynamic linker/loader `ld.so` is part of glibc.

I was particularly interested in how it resolves the dynamic symbols during
runtime. I took a brief read of the source code and found some relevant ones.

### ld.so

ld.so is the dynamic linker/loader:
The programs ld.so find and load the shared objects (shared libraries) needed by a program, prepare the program to run, and then run it.
You can run `man ld.so` to see more details.

ld.so is a program, after all. It is part of glibc library.

- ELF's `.interp` section points to the dynamic linker. During execve(), kernel will jump to ld.so instead of user code entry point.
- Related code: `elf/rtld.c`, `sysdep/generic`, `sysdep/x86_64/`, and more
- Inside `dl_main()`, you can see how `LD_PRELOAD` is handled.
- `GOT[1]` contains address of the `link_map` data structure.
- `GOT[2]` points to `_dl_runtime_resolve()`! This is the runtime dynamic linker entry point.

File `sysdep/generic/dl-machine.c` populates `GOT[1]` and `GOT[2]`.
```c linenums="1" hl_lines="16 20"
/* Set up the loaded object described by L so its unrelocated PLT
   entries will jump to the on-demand fixup code in dl-runtime.c.  */

static inline int
elf_machine_runtime_setup (struct link_map *l, int lazy)
{
  extern void _dl_runtime_resolve (Elf32_Word);

  if (lazy)
    {
      /* The GOT entries for functions in the PLT have not yet been filled
         in.  Their initial contents will arrange when called to push an
         offset into the .rel.plt section, push _GLOBAL_OFFSET_TABLE_[1],
         and then jump to _GLOBAL_OFFSET_TABLE[2].  */
      Elf32_Addr *got = (Elf32_Addr *) D_PTR (l, l_info[DT_PLTGOT]);
      got[1] = (Elf32_Addr) l;  /* Identify this shared object.  */

      /* This function will get called to fix up the GOT entry indicated by
         the offset on the stack, and then jump to the resolved address.  */
      got[2] = (Elf32_Addr) &_dl_runtime_resolve;
    }

  return lazy;
}
```

`_dl_runtime_resolve()` is architecture specific and has a mix of assembly and C code.
The flow is similar to the syscall handling: it first saves the registers,
then calling the actual resolver, then restore all saved registers.
For 64bit x86, the source code is in `sysdeps/x86_64/dl-trampoline.h`:
```asm linenums="1" hl_lines="11"
	.globl _dl_runtime_resolve
	.type _dl_runtime_resolve, @function
_dl_runtime_resolve:
	...
	...

	# Copy args pushed by PLT in register.
	# %rdi: link_map, %rsi: reloc_index
	mov (LOCAL_STORAGE_AREA + 8)(%BASE), %RSI_LP
	mov LOCAL_STORAGE_AREA(%BASE), %RDI_LP
	call _dl_fixup		# Call resolver.
	mov %RAX_LP, %R11_LP	# Save return value

	...
```

Bingo, `_dl_fixup()` is the final piece of the runtime dynamic linker resolver. We could find it in `elf/dl-runtime.c`, which is a file for on-demand PLT fixup.:
```c linenums="1"
/* This function is called through a special trampoline from the PLT the
   first time each PLT entry is called.  We must perform the relocation
   specified in the PLT of the given shared object, and return the resolved
   function address to the trampoline, which will restart the original call
   to that address.  Future calls will bounce directly from the PLT to the
   function.  */

DL_FIXUP_VALUE_TYPE
attribute_hidden __attribute ((noinline)) ARCH_FIXUP_ATTRIBUTE
_dl_fixup (
# ifdef ELF_MACHINE_RUNTIME_FIXUP_ARGS
	   ELF_MACHINE_RUNTIME_FIXUP_ARGS,
# endif
	   struct link_map *l, ElfW(Word) reloc_arg)
{
	...
}
```

Understanding this piece of code requires some effort. Happy hacking!

#### Fun fact about LD_PRELOAD

If you use `LD_PRELOAD` to run a program,
it will affect `popen()` since it will inherit environment variables.
Hence, if you are doing some one time initilization within in your LD_PRELOAD library via, say `constructor` marked function,
you should call `unsetenv("LD_PRELOAD")` before `popen()` call.

### Understanding

Most recent ELF produced by GCC is slightly different than
the ones described by previous textbook or papers.
The difference is small, though. You should use `man elf` to check latest.

- When a program imports a certain function or variable, the linker
  will include a string with the function or variable’s name in the
  `.dynstr` section.
- A symbol (Elf Sym) that refers to the function or variable's name in the `.dynsym` section,
  and a relocation (Elf Rel) pointing to that symbol in the `.rela.plt` section.
- `.rela.dyn` and `.rela.plt` are for imported variables and functions, respectively.
- `.plt` is the normal one, it has instructions.
- `.got` and `.got.plt` maybe the first is for variable, and the latter is for function.
  But essentially the same global offset table functionality.

Relationship among `.dynstr`, `.dynsym`, `.rela.dyn` or `.rela.plt`. Credit: [link](https://www.usenix.org/system/files/conference/usenixsecurity15/sec15-paper-di-frederico.pdf):
![image1](assets/relation.png)

PIC Lazy Binding. Credit: [link](https://uclibc.org/docs/psABI-x86_64.pdf):
![image2](assets/gotplt.png)

!!! note

GOT and PLT were invented for share libraries,
so those libraries can be used by arbitrary processes
without changing any of the library text.

However, nowadays, even an non-PIC binary will always have GOT and PLT sections.
In theory, it probably should use **basic load-time relocation**
to resolve dynamic symbols (See [CSAPP](https://csapp.cs.cmu.edu/) chapter 7 if you are not familiar with this).

I think GOT/PLT are used over load-time relocation technique for the following 2 reasons:
a) load-time relocation needs to
modify code and this not good during time.
Especially considering code section probably is not writable.
b) GOT/PLT's lazy-binding has performance win at start-up time.
However, keep in mind that
GOT/PLT's lazy-bindling pay extra runtime cost!

Reading:

- [System V Application Binary Interface](https://uclibc.org/docs/psABI-x86_64.pdf)
- [How the ELF Ruined Christmas](https://www.usenix.org/system/files/conference/usenixsecurity15/sec15-paper-di-frederico.pdf)

## How Kernel Loads User Program

Kernel loads user program via `exec()` or some variations.
This [post](../lego/kernel/loader.md) explained the flow in great details.

Note that kernel can recognize dynamic linking via the `.interp` section
and then invoke the dynamic linker `ld.so` instead of invoking user ELF binary directly.

## How Kernel Loads Kernel Module

Kernel can load modules during runtime.
Those modules are ELF binaries.
Let's first examine those binaries and see how kernel parses them.

Suppose we have this simple C module code:
```c linenums="1"
int foo(void)
{
    printk("Hello World!\n");
}

static int hello_init(void)
{
    printk("Hello World!\n");
    printk("Hello World!\n");
    foo();
    return 0;
}
```

Once you compile it into a kernel module, we can examine the binary
by using `objdump -dx hello.ko`.
Those highlighted lines mark some of the dynamic linking slots.
They will be patched by basic load-time relocation.
``` linenums="1" hl_lines="19-23"
Disassembly of section .text.unlikely:

0000000000000000 <foo>:
   0:   e8 00 00 00 00          callq  5 <foo+0x5>
                        1: R_X86_64_PLT32       __fentry__-0x4
   5:   55                      push   %rbp
   6:   48 c7 c7 00 00 00 00    mov    $0x0,%rdi
                        9: R_X86_64_32S .rodata.str1.1
   d:   48 89 e5                mov    %rsp,%rbp
  10:   e8 00 00 00 00          callq  15 <foo+0x15>
                        11: R_X86_64_PLT32      printk-0x4
  15:   5d                      pop    %rbp
  16:   c3                      retq   

0000000000000017 <init_module>:
  17:   e8 00 00 00 00          callq  1c <init_module+0x5>
                        18: R_X86_64_PLT32      __fentry__-0x4
  1c:   55                      push   %rbp
  1d:   48 c7 c7 00 00 00 00    mov    $0x0,%rdi
                        20: R_X86_64_32S        .rodata.str1.1
  24:   48 89 e5                mov    %rsp,%rbp
  27:   e8 00 00 00 00          callq  2c <init_module+0x15>
                        28: R_X86_64_PLT32      printk-0x4
  2c:   48 c7 c7 00 00 00 00    mov    $0x0,%rdi
                        2f: R_X86_64_32S        .rodata.str1.1
  33:   e8 00 00 00 00          callq  38 <init_module+0x21>
                        34: R_X86_64_PLT32      printk-0x4
  38:   e8 00 00 00 00          callq  3d <init_module+0x26>
                        39: R_X86_64_PLT32      foo-0x4
  3d:   31 c0                   xor    %eax,%eax
  3f:   5d                      pop    %rbp
  40:   c3                      retq   
```

It is also worth checking out the `.symtab` section.
If your module is using kernel functions or variables,
the compiler does not know their precise addresses during compile time.
The compiler will add several entries into the `.symtab` with properties
marked as `GLOBAL, UND`. For example, you can run `readelf -s hello.ko`
to check that. I will post part of the output:
``` linenums="1"
Symbol table '.symtab' contains 29 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 0000000000000000     0 SECTION LOCAL  DEFAULT    1 
    ....
    13: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS haha.mod.c
    ....
    21: 0000000000000017    42 FUNC    LOCAL  DEFAULT    5 hello_init
    22: 0000000000000000    11 FUNC    LOCAL  DEFAULT    3 hello_exit
    23: 0000000000000000   896 OBJECT  GLOBAL DEFAULT   12 __this_module
    24: 0000000000000000    11 FUNC    GLOBAL DEFAULT    3 cleanup_module
    25: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND __fentry__
    26: 0000000000000017    42 FUNC    GLOBAL DEFAULT    5 init_module
    27: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT  UND printk
    28: 0000000000000000    23 FUNC    GLOBAL DEFAULT    5 foo
```

The `simplify_symbols()` below will find the kernel virtual addresses
for UNDEF symbols in the `.symtab` section. Those will further be
used to patch dynamic relocation entries.

---

Now let us dive into kernel implementation.

The kernel has several system calls for module.
The loading part is using `SYSCALL_DEFINE3(init_module)`.
Within that, it calls the big function `load_module()`.

In the begining of `load_module()`, there are some
usual tasks examining ELF headers, allocating memory etc.
After that, kernel will try to find the addresses for UNDEF symbols:

```c linenums="1"
kernel/module.c load_module()
        /* Fix up syms, so that st_value is a pointer to location. */
        err = simplify_symbols(mod, info);
        if (err < 0)
                goto free_modinfo;

        err = apply_relocations(mod, info);
        if (err < 0)
                goto free_modinfo;

==>

This function will find the kernel virtual addresses
for UNDEF symbols in the `.symtab` section.

simplify_symbols()
              case SHN_UNDEF:
                        ksym = resolve_symbol_wait(mod, info, name);
                        /* Ok if resolved.  */
                        if (ksym && !IS_ERR(ksym)) {
                                sym[i].st_value = kernel_symbol_value(ksym);
                                break;
                        }
```

After resolving symbols to the real kernel virtual addresses,
the next step is to patch the code to update all the relocation entries.
If will do so for sections with these two types: `SHT_REL` and `SHT_RELA`.
It looks like x86_64 is only using `apply_relocate_add()`, the one with explict addends.
```c linenums="1"
kernel/module.c apply_relocations()
		...
                else if (info->sechdrs[i].sh_type == SHT_REL)
                        err = apply_relocate(info->sechdrs, info->strtab,
                                             info->index.sym, i, mod);
                else if (info->sechdrs[i].sh_type == SHT_RELA)
                        err = apply_relocate_add(info->sechdrs, info->strtab,
                                                 info->index.sym, i, mod);
```

Zoom into `apply_relocate_add()`, very interesting function.
It is similar to the userspace linker ld.so.
It could be summarized as follows:

- Find the start of the relocation entry section in ELF.
- Walk through each relocation entry, for each entry, do:
    - Get the location where we need to patch the code (e.g., the assembly instructions dumped above)
    - Find the symbol the entry is using. The symbol was alread resolved to kernel virtual address
    - Update the location by applying certain computation on top of the resolved symbol address.
      The computation is dictated by entry type (e.g., `R_X86_64_PLT32`)

See the full kernel code [here](https://elixir.bootlin.com/linux/v5.10.4/source/arch/x86/kernel/module.c#L129).

## Summary

There you have it. We walk through how kernel loads user program, how kernel loads kernel module,
and how dynamic linker resolves dynamic linking. The kernel and ld.so share a lot similarities
in dealing with the linking process.

We have not covered the static linking part in this post, but its process is
similar to how the basic load-time relocation patches instructions.

The essense of linking and loading is to do lazy information binding
and pass information along the toolchain.
The whole concetps involves many parties, ranging from compiler, linker, and kernel.
Each takes its own part in the process.

As always, hope you enjoyed this blog. Happy Hacking!

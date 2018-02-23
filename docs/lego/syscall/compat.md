# Compat SYSCALL in Lego

Lego does __not__ support compatible syscalls, where one is able to run 32-bit image on 64-bit OS. However, the ugly FPU code and signal part in Linux is heavily hacked with the assumption that compat syscall is supported. We are no expert in this FPU thing, just to make sure we don't break this FPU evil, Lego adds the fake compat syscall support. Fake means whenever a 32-bit syscall is issued, Lego will just panic.

## Kconfig
If one compiles a x86_64 Linux kernel, compat syscalls are supported by default. Everything related to compat syscalls are controlled by the following two Kconfig options. Lego may want to support compat syscalls in the future, thus we add these two Kconfigs to avoid future mess:

- `CONFIG_COMPAT`
- `CONFIG_IA32_EMULATION`

## Internal

### Entry Points
The assembly entry points are defined in `entry/entry_64_compat.S`:
```asm
ENTRY(entry_SYSENTER_compat)
        ...
        call    do_fast_syscall_32
GLOBAL(__end_entry_SYSENTER_compat)
ENDPROC(entry_SYSENTER_compat)

ENTRY(entry_SYSCALL_compat)
        ...
        call    do_fast_syscall_32
END(entry_SYSCALL_compat)

ENTRY(entry_INT80_compat)
        ...
        call    do_int80_syscall_32
END(entry_INT80_compat)
```

### Entry Points Setup
The assembly entry points are filled to system registers and IDT table. So users can `actually` issue those calls, Lego is able to catch them:
```c
static void syscall_init(void)
{
        wrmsr(MSR_STAR, 0, (__USER32_CS << 16) | __KERNEL_CS);
        wrmsrl(MSR_LSTAR, (unsigned long)entry_SYSCALL_64);

#ifdef CONFIG_IA32_EMULATION
        wrmsrl(MSR_CSTAR, (unsigned long)entry_SYSCALL_compat);
        /*  
         * This only works on Intel CPUs.
         * On AMD CPUs these MSRs are 32-bit, CPU truncates MSR_IA32_SYSENTER_EIP.
         * This does not cause SYSENTER to jump to the wrong location, because
         * AMD doesn't allow SYSENTER in long mode (either 32- or 64-bit).
         */
        wrmsrl_safe(MSR_IA32_SYSENTER_CS, (u64)__KERNEL_CS);
        wrmsrl_safe(MSR_IA32_SYSENTER_ESP, 0ULL);
        wrmsrl_safe(MSR_IA32_SYSENTER_EIP, (u64)entry_SYSENTER_compat);
#else
        wrmsrl(MSR_CSTAR, (unsigned long)ignore_sysret);
        wrmsrl_safe(MSR_IA32_SYSENTER_CS, (u64)GDT_ENTRY_INVALID_SEG);
        wrmsrl_safe(MSR_IA32_SYSENTER_ESP, 0ULL);
        wrmsrl_safe(MSR_IA32_SYSENTER_EIP, 0ULL);
#endif


        /* Flags to clear on syscall */
        wrmsrl(MSR_SYSCALL_MASK,
               X86_EFLAGS_TF|X86_EFLAGS_DF|X86_EFLAGS_IF|
               X86_EFLAGS_IOPL|X86_EFLAGS_AC|X86_EFLAGS_NT);
}
arch/x86/kernel/cpu/common.c

void __init trap_init(void)
{
        ...
#ifdef CONFIG_IA32_EMULATION
        set_system_intr_gate(IA32_SYSCALL_VECTOR, entry_INT80_compat);
        set_bit(IA32_SYSCALL_VECTOR, used_vectors);
#endif
        ...
}
arch/x86/kernel/traps.c
```

### C code
The actual C code is in `entry/common.c`:
```c
#if defined(CONFIG_X86_32) || defined(CONFIG_IA32_EMULATION)
static __always_inline void do_syscall_32_irqs_on(struct pt_regs *regs)
{
#ifdef CONFIG_IA32_EMULATION
        current->thread.status |= TS_COMPAT;
#endif

        BUG();
}

/* Handles int $0x80 */
__visible void do_int80_syscall_32(struct pt_regs *regs)
{
        BUG();
}

/* Returns 0 to return using IRET or 1 to return using SYSEXIT/SYSRETL. */
__visible long do_fast_syscall_32(struct pt_regs *regs)
{
        BUG();
}
#endif
```

--  
Yizhou Shan  
Created: Feb 22, 2018  
Last Updated: Feb 22, 2018

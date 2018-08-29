# IRQ

IRQ is majorly ported based on `linux-4.4`. The decision of porting of whole IRQ stack from linux was made at early stage of Lego, when I'm not so familiar with this stuff. This technique decision has pros and cons.

The whole thing is made complicated by having IRQ domain. IRQ domain is introduced to address the multiple interrupt controller issue. And in x86, we kind of have mutiple as well: IO-APIC, REMAP, LAPIC. Although we are not supporting IRQ remap now.

## Init

- The first part of initialization is `trap_init()` at early `setup_arch()`.
- The second major entry point is `irq_init()` at `start_kernel()`. This `irq_init()` is actually a combination of linux's:
    - `early_irq_init()`: 1) setup `irq_desc[]` array, and then call `arch_early_irq_init()`, which will register two IRQ domains (x86_vector_domain, msi_domain).
    - `init_IRQ()`: is actually a callback to low-level x86 interrupt setup. It mainly setup the desc's data/chip etc, and register all different handlers.
    - In Lego, you will be able to find all the functionalitis are moved into `arch_irq_init()`. And, to this point, we have a complete setup.
- The third (and last) entry point is `smp_prepare_cpus()`:
```
smp_prepare_cpus()
-> apic_bsp_setup()
   -> setup_local_APIC()
   -> setup_IO_APIC()
   -> x86_init.timers.setup_percpu_clockev()
```

## IRQ Domain
We should have at least 2 or 3 IRQ domains:

- x86_vector
- x86_msi
- x86_ioapic-N (each ioapic has one)

The first two guys are created during `arch_irq_init()`. While the latter ioapic ones are created during `setup_IO_APIC()`. All of them are allocated eventually by `__irq_domain_add()`, and linked at `LIST_HEAD(irq_domain_list)`.

So....  Lego or Linux maintains its own IRQ numbers, starting from 0 to NR_IRQs.
However, this IRQ number MAY not have a identical mapping to hardware's own IRQ number (let us call it hwirq). Given this, we want to know the mapping between IRQ and hwirq. That's the purpose of having `linear_revmap` and `revmap_tree` within each domain, it is used to translate hwirq to IRQ.

Why two different data structures? `linear_revmap` is fairly simple, an array, which is indexed by hwirq. However, the hwirq maybe very large, we don't want to waste memory, that's how we want to use trees.

These two can be used together. If we fail to insert into `linear_revmap`, we insert into tree. During search time, we need to look up both.

By default, `x86_vector` and `x86_msi` use radix tree only. `x86_ioapic-N` uses a mix of linear and radix tree.

To dump all IRQ domains, call `dump_irq_domain_list()`, which give you something like this:
```c
[  118.308544]  name              mapped  linear-max  direct-max  devtree-node
[  118.316114]  x86_ioapic-2          24          24           0    
[  118.322707]  x86_ioapic-1          24          24           0    
[  118.329299]  x86_ioapic-0          24          24           0    
[  118.335893]  x86_msi               25           0           0    
[  118.342486] *x86_vector            40           0           0    
[  118.349078] irq    hwirq    chip name        chip data           active  type            domain
[  118.358775]     1  0x00001  IO-APIC          0xffff88107fcae000        LINEAR          x86_ioapic-0
[  118.368858]     3  0x00003  IO-APIC          0xffff88107fc8f000        LINEAR          x86_ioapic-0
[  118.378940]     4  0x00004  IO-APIC          0xffff88107fc6e000        LINEAR          x86_ioapic-0
[  118.389025]     5  0x00005  IO-APIC          0xffff88107fc6f000        LINEAR          x86_ioapic-0
[  118.399109]     6  0x00006  IO-APIC          0xffff88107fc4e000        LINEAR          x86_ioapic-0
[  118.409192]     7  0x00007  IO-APIC          0xffff88107fc4f000        LINEAR          x86_ioapic-0
[  118.419276]     8  0x00008  IO-APIC          0xffff88107fc2e000        LINEAR          x86_ioapic-0
[  118.429358]     9  0x00009  IO-APIC          0xffff88107fc2f000        LINEAR          x86_ioapic-0
[  118.439442]    10  0x0000a  IO-APIC          0xffff88107fc0e000        LINEAR          x86_ioapic-0
[  118.449525]    11  0x0000b  IO-APIC          0xffff88107fc0f000        LINEAR          x86_ioapic-0
[  118.459609]    12  0x0000c  IO-APIC          0xffff88107fff0000        LINEAR          x86_ioapic-0
[  118.469692]    13  0x0000d  IO-APIC          0xffff88107fff1000        LINEAR          x86_ioapic-0
[  118.479776]    14  0x0000e  IO-APIC          0xffff88107fff2000        LINEAR          x86_ioapic-0
[  118.489860]    15  0x0000f  IO-APIC          0xffff88107fff3000        LINEAR          x86_ioapic-0
[  118.499943]    24  0x300000  PCI-MSI                      (null)     *     RADIX          x86_msi
[  118.509833]    25  0x300001  PCI-MSI                      (null)     *     RADIX          x86_msi
[  118.519722]    26  0x300002  PCI-MSI                      (null)     *     RADIX          x86_msi
[  118.529612]    27  0x300003  PCI-MSI                      (null)     *     RADIX          x86_msi
[  118.539501]    28  0x300004  PCI-MSI                      (null)           RADIX          x86_msi
```

## Aug 20, 2018
Well, I've ported the IRQ stuff at early days of Lego. At that time, I mainly ported the low-level APIC, IO-APIC, and ACPI stuff, along with the upper layer irqchip, irqdesc stuff.

These days, I was verifying our IB code and tried to add back mlx4en's interrupt handler, somehow, there is no interrupt after `request_irq()`.

Two possible reasons: 1) I missed something during PCI setup, 2) underlying APIC and IO-APIC need more work.


--
Last Updated: Aug 28, 2018

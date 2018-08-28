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
- x86_ioapic_N (each ioapic has one)

The first two guys are created during `arch_irq_init()`. While the latter ioapic ones are created during `setup_IO_APIC()`. All of them are allocated eventually by `__irq_domain_add()`, and linked at `LIST_HEAD(irq_domain_list)`.

At the time of writing, Lego does not have radix tree. Thus, all domains are using linear reverse mapping between Lego IRQ number and HW IRQ number. The special knob is located at:
```c hl_lines="3 4 5"
__irq_domain_add()
{
        if (size == 0) {
                size = NR_IRQS;
        }

	domain = kzalloc(sizeof(*domain) + (sizeof(unsigned int) * size), GFP_KERNEL);

	domain->revmap_size = size;

irq_find_mapping()
irq_domain_insert_irq()
```

To dump all IRQ domains, call `dump_irq_domain_list()`, which give you something like this:
```c
[91946.721459]  IRQ_DOMAIN[0]: x86_ioapic-2
[91946.725634]     hwirq_max:             24
[91946.730094]     revmap_direct_max_irq: 0
[91946.734458]     revmap_size:           24   
[91946.738917]  IRQ_DOMAIN[1]: x86_ioapic-1
[91946.743280]     hwirq_max:             24   
[91946.747740]     revmap_direct_max_irq: 0
[91946.752103]     revmap_size:           24   
[91946.756564]  IRQ_DOMAIN[2]: x86_ioapic-0
[91946.760927]     hwirq_max:             24   
[91946.765386]     revmap_direct_max_irq: 0
[91946.769750]     revmap_size:           24   
[91946.774210]  IRQ_DOMAIN[3]: x86_msi
[91946.778089]     hwirq_max:             18446744073709551615
[91946.784294]     revmap_direct_max_irq: 0
[91946.788657]     revmap_size:           4352
[91946.793311]  IRQ_DOMAIN[4]: x86_vector
[91946.797479]     hwirq_max:             18446744073709551615
[91946.803685]     revmap_direct_max_irq: 0
[91946.808048]     revmap_size:           4352
```

By having a size, the linear map will be allocated as always. Another two functions `irq_find_mapping()`, `irq_domain_insert_irq()` are users of revmap_size/revmap, they will be taken care of.


## Aug 20, 2018
Well, I've ported the IRQ stuff at early days of Lego. At that time, I mainly ported the low-level APIC, IO-APIC, and ACPI stuff, along with the upper layer irqchip, irqdesc stuff.

These days, I was verifying our IB code and tried to add back mlx4en's interrupt handler, somehow, there is no interrupt after `request_irq()`.

Two possible reasons: 1) I missed something during PCI setup, 2) underlying APIC and IO-APIC need more work.

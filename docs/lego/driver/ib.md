# Infiniband Subsystem

## Current Status
Lego's IB stack is ported based on `linux-3.11.1`. We ported:

- `ib_core`
- `mlx4_ib`
- `mlx4_core`

Lego does not support uverbs. At the time of writing, Lego IB stack has only been tested on `Mellanox Technologies MT27500 Family [ConnectX-3]`.

## Random summary

The stack is SUPER complex, a lot data structures and pointers fly all over. Good thing is the whole stack is layered clearly.

Top down

### `ib_core`

- IB core code is in `driver/infiniband/core`, which exposes the major IB API to both user and kernel applications. Inside, it has two parts. The first part is function callback, that call back to underlying device-specific functions. The second part is the management stack, including communication manager (cm), management datagram (mad), and so on.
- In IB, each port's QP0 and QP1 are reserved for management purpose. They will receive/send MAD from/to subnet manager, who typically runs on switch. All the IB management stuff is carried out by exchanging MAD.
- There are several key data structures: ib_client, ib_device, and mad_agent. MAD, CM, and some others are ib_client, which means they use IB device, and will be called back whenever a device has been added. mad_agent is something that will be called back whenever a device received a MAD message from switch (see `ib_mad_completion_handler()`). A lot layers, huh?
- `ib_mad_completion_handler()`: we changed the behavior of it. we use busy polling instead of interrupt. Originally, it will be invoked by mlx4_core/eq.c

### `mlx4_ib and mlx4_core`

- mlx4_core is actually the Ethernet driver for Mellanox NIC device (drivers/net/ethernet/mellanox/hw/mlx4), which do the actual dirty work of talking with device. On the other hand, mlx4_ib is the glue code between ib_core and mlx4_core, who do the translation.

- A lot IB verbs are ultimately translated into `fw.c __mlx4_cmd()`, which actually send commands to device and get the result. There are two ways of getting result: 1) polling: after writing to device memory the command, the same thread keep polling. 2) sleep and wait for interrupt. By default, the interrupt way is used (obviously). But, at the time of writing (Aug 20, 2018), we don't really have a working IRQ subsystem, so we use polling instead. __I'm still a little concerned that without interrupt handler, we might lose some events and the NIC may behavave incorrectly if interrupts are not handled.__

--  
Yizhou Shan  
Created: Aug 20, 2018  
Last Updated: Aug 20, 2018

# PCI Subsystem

## What we have ported so far
-  PCI data structures such as `pci_dev`, `pci_bus`, and so on.
-  Mechanism to scan bus and build data structures during boot. Performed by `pci_scan_root_bus()`, and most code is in `driver/pci/probe.c`

## Unfinished business 

- Ways to go through all PCI device.
- `pci_init_capabilities()`: for each PCI device
- `pci_fixup_device()`: a lot quicks, maybe not useful
- `pcie_aspm_init_link_state()`: PCIe link state
- `pci_iov_bus_range`: all SR-IOV support

--  
Yizhou Shan  
Created: July 5, 2018  
Last Updated: July 5, 2018

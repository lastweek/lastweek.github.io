# How to add an IOMMU device in QEMU?

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Aug 2, 2021 | Initial|

TL;DR
This blog explains how QEMU simulate IOMMU device
and how you can add one of your own.
We will take a brief read of Intel IOMMU, ARM SMMU, and Virtio-IOMMU.
Finally we will add a new one to RISC-V virt machine mode.

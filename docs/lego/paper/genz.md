# Interconnect Technology Comparison

|Technology|Products or Vendor|Domain|Coherent|Semantic|Bandwidth|Latency|
|-|-|-|-|-|:-|-|
|Gen-Z|N/A|Cross components|:heavy_multiplication_x:|Memory|32 GBps ~ 400+ GBps <br> `Unidirectional`|<100ns|
|OpenCAPI|IBM Power9|Motherboard|:heavy_check_mark:|Memory|50 GBps per lane <br> `Bidirectional`|?|
|CCIX|N/A|Motherboard|:heavy_check_mark:|Memory|32/40/50 GBps/lane <br> `Bidirectional`|?|
|OmniPath|Intel KnightsLanding|Cross networrk|:heavy_multiplication_x:|Network|25 GBps/port <br> `Bidirectional`|?|
|PCIe 3.0|A Lot|Motherboard|:heavy_multiplication_x:|PCIe|~1GBps/lane|?|
|PCIe 4.0|Soon|Motherboard|:heavy_multiplication_x:|PCIe|~2GBps/lane|?|
|EDR|Mellanox ConnectX4,X5|Cross network|:heavy_multiplication_x:|Network|100Gbps|0.5us|
|HDR|Mellanox ConnectX6|Cross network|:heavy_multiplication_x:|Network|200Gbps|<0.5us|
|HyperTransport|AMD|Motherboard|:heavy_check_mark:|Memory|51.2 GBps per link <br> `Bidirectional`|?|
|NVLink|NVIDIA V100 <br> IBM Power9|Motherboard|:heavy_check_mark:|Memory|50GBps per link <br> `Bidirectional`|?|
|QPI|Intel|Motherboard|:heavy_check_mark:|Memory|?|?|
|Intel Main Memory Bus|Processors|Processor|:heavy_check_mark:|Memory|E7-8894 v4 85 GB/s <br> E5-2620 v3 59 GB/s|?|

- POWER9, NVLink 2.0, 300GB/s

References:

- NVLink
    - [http://www.nvidia.com/object/nvlink.html](http://www.nvidia.com/object/nvlink.html)
    - [https://en.wikipedia.org/wiki/NVLink](https://en.wikipedia.org/wiki/NVLink)

- HyperTransport
    - [https://en.wikipedia.org/wiki/HyperTransport](https://en.wikipedia.org/wiki/HyperTransport)

- QPI
    - [https://en.wikipedia.org/wiki/Intel_QuickPath_Interconnect](https://en.wikipedia.org/wiki/Intel_QuickPath_Interconnect)
    - [https://communities.intel.com/thread/21872](https://communities.intel.com/thread/21872)

- Gen-Z CCIX OpenCAPI
    - [https://www.openfabrics.org/images/eventpresos/2017presentations/213_CCIXGen-Z_BBenton.pdf](https://www.openfabrics.org/images/eventpresos/2017presentations/213_CCIXGen-Z_BBenton.pdf)
    - [Gen-Z Overview](http://genzconsortium.org/wp-content/uploads/2017/08/Gen-Z-Overview.pdf)

- PCIe
    - [https://www.anandtech.com/show/11967/pcisig-finalizes-and-releasees-pcie-40-spec](https://www.anandtech.com/show/11967/pcisig-finalizes-and-releasees-pcie-40-spec)

- OmniPath
    - [http://www.hoti.org/hoti23/slides/rimmer.pdf](http://www.hoti.org/hoti23/slides/rimmer.pdf)
    - [https://www.intel.com/content/www/us/en/products/network-io/high-performance-fabrics/omni-path-edge-switch-100-series.html](https://www.intel.com/content/www/us/en/products/network-io/high-performance-fabrics/omni-path-edge-switch-100-series.html)

- :whale:

# Interconnect Technology Comparison

|Technology|Products or Vendor|Domain|Coherent|Semantic|Maximum Bandwidth|Latency|
|-|-|-|-|-|:------|-|
|Gen-Z[^7][^8]|N/A|Cross components|:heavy_multiplication_x:|Memory|32 GBps ~ 400+ GBps <br> `Unidirectional`|<100ns|
|OpenCAPI[^7]|IBM Power9|Motherboard|:heavy_check_mark:|Memory|50 GBps per lane <br> `Bidirectional`|?|
|CCIX[^7]|N/A|Motherboard|:heavy_check_mark:|Memory|32/40/50 GBps/lane <br> `Bidirectional`|?|
|OmniPath[^9][^10]|Intel KnightsLanding|Cross networrk|:heavy_multiplication_x:|Network|25 GBps/port <br> `Bidirectional`|?|
|PCIe 3.0|A Lot|Motherboard|:heavy_multiplication_x:|PCIe|~1GBps/lane|?|
|PCIe 4.0|Soon|Motherboard|:heavy_multiplication_x:|PCIe|~2GBps/lane|?|
|IB EDR|Mellanox ConnectX4,X5|Cross network|:heavy_multiplication_x:|Network|100Gbps|0.5us|
|IB HDR|Mellanox ConnectX6|Cross network|:heavy_multiplication_x:|Network|200Gbps|<0.5us|
|HyperTransport[^4]|AMD|Motherboard|:heavy_check_mark:|Memory|51.2 GBps per link <br> `Bidirectional`|?|
|NVLink[^2]|NVIDIA V100 <br> IBM Power9|Motherboard|:heavy_check_mark:|Memory|50GBps per link <br> `Bidirectional`|?|
|QPI[^5][^6]|Intel|Motherboard|:heavy_check_mark:|Memory|?|?|
|Intel Main Memory Bus|Intel|Processor|:heavy_check_mark:|Memory|E7-8894 v4 `85 GB/s` <br> E5-2620 v3 `59 GB/s`|?|
|Ethernet[^3]| A Lot|Motherboard|:heavy_multiplication_x:|Network|Mellanox `200Gbps` <br> Cisco ASR `100 Gbps`[^1]|?|

- POWER9, NVLink 2.0, 300GB/s

[^1]: [Ethernet Cisco ASR 9000 Series 4-Port 100-Gigabit Ethernet](https://www.cisco.com/c/en/us/products/collateral/routers/asr-9000-series-aggregation-services-routers/datasheet-c78-740092.html)
[^2]: [Terabit Ethernet](https://en.wikipedia.org/wiki/Terabit_Ethernet)
 [https://en.wikipedia.org/wiki/NVLink](https://en.wikipedia.org/wiki/NVLink)
[^3]: [NVLink](http://www.nvidia.com/object/nvlink.html)
[^4]: [HyperTransport](https://en.wikipedia.org/wiki/HyperTransport)
[^5]: [https://en.wikipedia.org/wiki/Intel_QuickPath_Interconnect](https://en.wikipedia.org/wiki/Intel_QuickPath_Interconnect)
[^6]: [https://communities.intel.com/thread/21872](https://communities.intel.com/thread/21872)

[^7]: [https://www.openfabrics.org/images/eventpresos/2017presentations/213_CCIXGen-Z_BBenton.pdf](https://www.openfabrics.org/images/eventpresos/2017presentations/213_CCIXGen-Z_BBenton.pdf)
[^8]: [Gen-Z Overview](http://genzconsortium.org/wp-content/uploads/2017/08/Gen-Z-Overview.pdf)


[^9]: [http://www.hoti.org/hoti23/slides/rimmer.pdf](http://www.hoti.org/hoti23/slides/rimmer.pdf)
[^10]: [https://www.intel.com/content/www/us/en/products/network-io/high-performance-fabrics/omni-path-edge-switch-100-series.html](https://www.intel.com/content/www/us/en/products/network-io/high-performance-fabrics/omni-path-edge-switch-100-series.html)

--  
Yizhou Shan :whale:  
Created: Feb 28, 2018  
Last Updated: March 01, 2018

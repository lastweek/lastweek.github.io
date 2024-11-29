<!---
<p align="left">
<img src="images/me.png" height=150 width=100>
</p>
--->

Hello! I'm Yizhou, I'm a Research Scientist at [Huawei Cloud](https://www.huaweicloud.com/intl/en-us/).
I earned my PhD from [University of California San Diego](https://cse.ucsd.edu/)
under the supervision of [Prof. Yiying Zhang](https://cseweb.ucsd.edu/~yiying/).

I now run Huawei Cloud's Serverless AI platform, responsible for cost-efficient model serving, agent serving, and supervised fine-tuning.
If you are interested in working with me (full-time or intern), we should talk.

Contact: **syzwhat** AT **gmail** DOT **com**
You can find my [CV here](http://lastweek.io/pubs/Yizhou_Shan_CV.pdf).

??? note "Blogging"

    **Latest**

      - Nov 2022 [SSD 101](./notes/ssd.md)
      - Jul 2022 [CXL](./notes/CXL.md)
      - Apr 2022 [MLIR](./notes/MLIR.md)
      - Mar 2022 [Resource Disaggregation Spectrum](./notes/resource-disaggregation-spectrum.md)
      - Feb 2022 [Distributed Transactions](./notes/dist-xact.md)
      - Dec 2021 [Notes on Modern Data Center Networking](./notes/dcn.md)
    
    **Hot**

      - Oct 2019 [FPGA Bitstream Explained](./fpga/bitstream.md)
      - May 2020 [On DPDK and RDMA Related Software](./notes/source_code/rdma/)
      - Jan 2020 [Modern Virtualization](./notes/virt.md)
      - Dec 2020 [Dynamic Linking](./notes/dynamic_linking.md)
      - Jun 2019 [Practical Cache Coherence](./notes/cache_coherence.md)
      - Dec 2020 [Architecture](./notes/arch.md)
      - and more!


??? tip "Research"
    - [_Nov 2024_] I will serve as a PC for FAST'25, FAST'26, ATC'25.
    - [_Nov 2024_] InstInfer accepted to HPCA'25.
	- [_Apr 2024_] I will serve as a [NSDI'25]() PC.
	- [_Jan 2024_] I will serve as a [EuroSys'25]() PC.
	- [_Jan 2024_] I will serve as a [ATC'24]() PC.
	- [_Dec 2022_] I will serve as a [NSDI'24]() PC.
	- [_Nov 2022_] MARB accepted to DATE'23.
	- [_Oct 2022_] HoPP accepted to HPCA'23.
	- [_Sep 2022_] I will serve as an [ATC'23]() PC.
	- [_Jun 2022_] A vision paper is accepted to [APSys'22](https://apsys2022.comp.nus.edu.sg/index.html)
	- [_Jun 2022_] Serve as [EuroSys'23 PC](https://2023.eurosys.org/index.html)
	- [_Jun 2022_] Serve as [SoCC'22 PC](https://acmsocc.org/2022/program-committee.html)
	- [_Mar 2022_] Serve as [APSys'22 PC]()
	- [_Mar 2022_] Serve as [ChinaSys'22 PC]()
	- [_Mar 2022_] Defended. The full defense slide is [here](./pubs/Defense_Slides_Yizhou_Shan.pdf).
	- [_Oct 2021_] Serve as [EuroSys'22 Shadow PC](https://2022.eurosys.org/)
	- [_Sep 2021_] We made our [SuperNIC]() paper public.
	- [_Sep 2021_] Serve as [SOSP'21 Artifact Evaluation PC]()
	- [_Aug 2021_] We made our [Clio]() paper public.
	- [_Jun 2021_] Start my final internship at Microsoft Research, working on Security + System.
	- [_Jun 2021_] I proposed my thesis and became a Ph.D candidate.
	- [_Jan 2021_] The DPM work is accepted to present at [NVMW'21](http://nvmw.ucsd.edu/)
	- [_Jan 2021_] This summer, I'm going to do my last internship at [MSR Redmond](https://www.microsoft.com/en-us/research/group/security-and-privacy-research-group-redmond/) on [cloud confidential computing](https://azure.microsoft.com/en-us/solutions/confidential-compute/).
	- [_Dec 2020_] Invited to join the [2021 JSys Student Editorial Board](https://escholarship.org/uc/jsys/studenteb)
	- [_Oct 2020_] Serve as [EuroSys'21 Shadow PC](https://www.eurosys2020.org/call-for-shadow-pc-participation/)
	- [_Sep 2020_] Serve as [OSDI'20 Artifact Evaluation PC](https://sysartifacts.github.io/osdi2020/organizers.html)
	- [_Sep 2020_] Serve as ASPLOS'21 External Reviewer. First major conference review!
	- [_Apr 2020_] __Disaggregated Persistent Memory__ accepted to __ATC'20__
	- [_Feb 2020_] Talk about [FPGA OS](https://cseweb.ucsd.edu/~yiying/cse291j-winter20/reading/FPGA-Virtualization.pdf)
	- [_Sep 2019_] Moved to UCSD.
	- [_May 2019_] Intern at [VMware Research](https://research.vmware.com/), with [Marcos K. Aguilera](http://mkaguilera.kawazoe.org/)
	- [_Apr 2019_] __Storm__ accpeted to __SYSTOR'19__. Awarded Best Paper.
	- [_Jan 2019_] Short paper on __Disaggregated Persistent Memory__ accpeted to __NVMW'19__
	- [_Jul 2018_] __LegoOS__ accepted to __OSDI'18__. Awarded Best Paper.
	- [_May 2018_] Intern at [VMware Research](https://research.vmware.com/), with [Stanko Novakovic](https://sites.google.com/site/stankonovakovic/).


## Research

My main research interests span
machine learning systems, distributed systems, data center networking,
OS, hardware (FPGA), disaggregated memory/storage systems,
and their intersections.

**Serving LLMs at Cloud Scale**

- [EPIC, 2024](https://arxiv.org/abs/2410.15332) - Position-Independent KV caching
- [InstInfer, HPCA'25](https://arxiv.org/abs/2409.04992) - Programmable Attention Offload
- [MemServe, 2024](https://arxiv.org/abs/2406.17565) - Disaggregated PD w/ Context Caching
- [TetriServe, 2024](https://arxiv.org/pdf/2401.11181.pdf) - Disaggregated PD
- [CaraServe, 2024](https://arxiv.org/abs/2401.11240) - Multi-LoRA Serving
- [The CAP Principle for LLM Serving, 2024]() - a survey

**Disaggregated Data Center Architecture**

-  [Skadi, HotOS'23](http://lastweek.io/pubs/Skadi_HotOS23.pdf)
-  [Fully Disaggregated Data Center, APSys'22](http://lastweek.io/pubs/apsys22.pdf)
-  [LegoOS, OSDI'18](https://www.usenix.org/conference/osdi18/presentation/shan)

**Disaggregated Memory**

-  [HoPP, HPCA'23](http://lastweek.io/pubs/HoPP-HPCA23.pdf) and [MARB, DATE'23]() - Hardware-accelerated Prefetching for DisaggMem
-  [Clio, ASPLOS'22](http://lastweek.io/pubs/ASPLOS22-Clio.pdf) - An FPGA-based disaggregated memory device
-  [Clover, ATC'20](http://lastweek.io/pubs/ATC20-DPM.pdf) - Pure *one-sided* KVS on disaggregated PM
-  [Storm, SYSTOR'19](http://lastweek.io/pubs/SYSTOR19-Storm.pdf) - Highly-efficient KVS on disaggregated memory
-  [Hotpot, SoCC'17](http://lastweek.io/pubs/SoCC17-Hotpot.pdf) -  Transactional distributed PM over RDMA

**Networking Design**

-  [Storm, SYSTOR'19](http://lastweek.io/pubs/SYSTOR19-Storm.pdf) - RDMA Cards are evolving!
-  [SuperNIC, arXiv'21](https://arxiv.org/pdf/2109.07744.pdf) - An FPGA-based Programmable Multi-Host NIC
-  [Clio, ASPLOS'22](http://lastweek.io/pubs/ASPLOS22-Clio.pdf) - Rethinking RDMA NIC, congestion control


### Publications


13. __CaraServe: CPU-Assisted and Rank-Aware LoRA Serving for Generative LLM Inference__
  <br> Suyi Li, Hanfeng Lu, Tianyuan Wu, Minchen Yu, Qizhen Weng, Xusheng Chen, *Yizhou Shan*, Binhang Yuan, Wei Wang
  <br> [[Preprint]](https://arxiv.org/abs/2401.11240)
       [[Code]]()
12. __Inference without Interference: Disaggregate LLM Inference for Mixed Downstream Workloads__
  <br> Cunchen Hu, Heyang Huang, Liangliang Xu, Xusheng Chen, Jiang Xu, Shuang Chen, Hao Feng, Chenxi Wang, Sa Wang, Yungang Bao, Ninghui Sun, *Yizhou Shan*
  <br> [[Preprint]](https://arxiv.org/pdf/2401.11181.pdf)
       [[Code]]()
11. __Optimizing Hardware-Based Network Computation DAGs for Multiple Tenants with SuperNIC__
  <br> *Yizhou Shan*, Will Lin, Ryan Kosta, Arvind Krishnamurthy, Yiying Zhang
  <br> [[Preprint]](https://arxiv.org/pdf/2109.07744.pdf)
       [[Code]]()
10. __Skadi: Building a Distributed Runtime for Data Systems in Disaggregated Data Centers__
  <br>  Cunchen Hu, Chenxi Wang, Sa Wang, Ninghui Sun, Yungang Bao, Jieru Zhao, Sanidhya Kashyap, Pengfei Zuo, Xusheng Chen, Liangliang Xu, Qin Zhang, Hao Feng, *Yizhou Shan*
  <br> *__HotOS 2023__*
	[[Paper]](https://sigops.org/s/conferences/hotos/2023/papers/hu.pdf)
10. __Core slicing: closing the gap between leaky confidential VMs and bare-metal cloud__
  <br> Ziqiao Zhou, *Yizhou Shan*, Weidong Cui, Xinyang Ge, Marcus Peinado, Andrew Baumann
  <br> *__OSDI 2023__*
       [[Paper]](http://lastweek.io/pubs/coreslicing-osdi23.pdf)
9. __MARB: Bridge the Semantic Gap between Operating System and Application Memory Access Behavior__
  <br> Haifeng Li, Ke Liu, Ting Liang, Zuojun Li, Tianyue Lu, Hui Yuan, Yinben Xia, Yungang Bao, Mingyu Chen, *Yizhou Shan*
  <br> *__DATE 2023__*
8. __HoPP: Hardware-Software Co-Designed Page Prefetching for Disaggregated Memory__
  <br> Haifeng Li, Ke Liu, Ting Liang, Zuojun Li, Tianyue Lu, Hui Yuan, Yinben Xia, Yungang Bao, Mingyu Chen, *Yizhou Shan*
  <br> *__HPCA 2023__*
       [[Paper]](http://lastweek.io/pubs/HoPP-HPCA23.pdf)
7. __Towards a Fully Disaggregated and Programmable Data Center__
  <br> *Yizhou Shan*, Will Lin, Zhiyuan Guo, Yiying Zhang
  <br> *__APSys 2022__*
       [[Paper]](https://dl.acm.org/doi/abs/10.1145/3546591.3547527)
6. __Distributing and Disaggregating Hardware Resources in Data Centers__
  <br> Yizhou Shan
  <br> [UCSD Dissertation 2022](https://escholarship.org/content/qt35s245rd/qt35s245rd_noSplash_e32c0215d4afc739cb21ef2618b5a968.pdf)
5. __Clio: A Hardware-Software Co-Designed Disaggregated Memory System__
  <br> *Yizhou Shan*, Zhiyuan Guo (co-first authors), Xuhao Luo, Yutong Huang, Yiying Zhang
  <br> *__ASPLOS 2022__*
       [[Paper]](http://lastweek.io/pubs/ASPLOS22-Clio.pdf)
       [[Code]](https://github.com/WukLab/Clio)
       [[Slide]]()
4. __Disaggregating Persistent Memory and Controlling Them Remotely: An Exploration of Passive Disaggregated Key-Value Stores__
  <br> Shin-Yeh Tsai, *Yizhou Shan*, Yiying Zhang
  <br> *__ATC 2020__*
       [[Paper]](http://lastweek.io/pubs/ATC20-DPM.pdf)
       [[Code]](https://github.com/WukLab/pDPM)
       [[Slide]](https://github.com/WukLab/pDPM/blob/master/Documentation/ATC20-pDPM-slides.pdf)
       [[Short-Talk]](https://www.youtube.com/watch?v=zEVhlb9J-Iw)
       [[Full-Talk]](https://youtu.be/Oexu-3Sfbxk)
       [[Keynote]](https://www.icloud.com/keynote/0Ox0HGeoa5L1pQ7txzyU_RkUA#ATC20-pDPM-iCloud-Public)

3. __Storm: a fast transactional dataplane for remote data structures__
  <br> Stanko Novakovic, *Yizhou Shan*, Aasheesh Kolli, Michael Cui, Yiying Zhang, Haggai Eran, Liran Liss, Michael Wei, Dan Tsafrir, Marcos Aguilera
  <br> *__SYSTOR 2019__* <font color='#c64444'>__(Best Paper Award)__</font>
       [[Paper]](http://lastweek.io/pubs/SYSTOR19-Storm.pdf)
       [[Slide]](http://www.systor.org/2019/slides/S6P1%20Storm%20A%20Fast%20Transactional%20Dataplane%20for%20Remote%20Data%20Structures.pdf)
       [[Talk]](https://www.youtube.com/watch?v=3ozwrzUVUJ4)

2. __LegoOS: A Disseminated, Distributed OS for Hardware Resource Disaggregation__
  <br> *Yizhou Shan*, Yutong Huang, Yilun Chen, Yiying Zhang
  <br> *__OSDI 2018__* <font color='#c64444'>__(Best Paper Award)__</font>
       [[Paper]](https://www.usenix.org/conference/osdi18/presentation/shan) [[Code]](https://github.com/WukLab/LegoOS)
       [[Slide]](https://www.usenix.org/sites/default/files/conference/protected-files/osdi18_slides_shan.pdf)
       [[Keynote-iCloud]](https://www.icloud.com/keynote/0__Wok6UPN175iDFEuGW9YVkA#LegoOS-OSDI18-Keynote)
       [[Talk]](https://www.youtube.com/watch?v=GX74Q2-ZOQE)

1. __Distributed Shared Persistent Memory__
  <br> *Yizhou Shan*, Shin-Yeh Tsai, Yiying Zhang
  <br> *__SoCC 2017__*
       [[Paper]](http://lastweek.io/pubs/SoCC17-Hotpot.pdf) [[Code]](https://github.com/WukLab/Hotpot)
       [[Slide]](http://lastweek.io/pubs/slides/Yizhou-Hotpot-SoCC17.pptx)
       [[Poster]](http://lastweek.io/pubs/slides/Poster-Hotpot-SoCC17.pptx)

### Workshops

5. __Disaggregating Persistent Memory and Controlling Them Remotely: An Exploration of Passive Disaggregated Key-Value Stores__
  <br> Shin-Yeh Tsai, *Yizhou Shan*, Yiying Zhang
  <br> *12th Annual Non-Volatile Memories Workshop (__NVMW 2021__)*
       [[Paper]](http://lastweek.io/pubs/ATC20-DPM.pdf)

4. __Challenges in Building and Deploying Disaggregated Persistent Memory__
  <br> *Yizhou Shan*, Yutong Huang, Yiying Zhang
  <br> *10th Annual Non-Volatile Memories Workshop (__NVMW 2019__)*
       [[Paper]](http://lastweek.io/pubs/NVMW19-DPM.pdf)

3. __Disaggregating Memory with Software-Managed Virtual Cache__
  <br> _Yizhou Shan_, Yiying Zhang
  <br> *2018 Workshop on Warehouse-scale Memory Systems (__WAMS 2018__) (co-located with ASPLOS '18)*  [[Paper]](http://workshops.inf.ed.ac.uk/wams/)

2. __Distributed Shared Persistent Memory__
  <br> *Yizhou Shan*, Shin-Yeh Tsai, Yiying Zhang
  <br> *9th Annual Non-Volatile Memories Workshop (__NVMW 2018__)*  [[Paper]](https://engineering.purdue.edu/WukLab/hotpot-socc17.pdf)

1. __Disaggregated Operating System__
  <br> Yiying Zhang, *Yizhou Shan*, Sumukh Hallymysore
  <br> *17th International Workshop on High Performance Transaction Systems (__HPTS 2017__)*  [[Paper]](http://hpts.ws/papers/2017/lego.pdf)

<!---
## Posters

3. __Lego: A Distributed, Decomposed OS for Resource Disaggregation__ [PDF](https://lastweek.github.io/pubs/SOSP17-Lego-Poster.pdf)
   <br> *Yizhou Shan*, Yilun Chen, Yutong Huang, Sumukh Hallymysore, Yiying Zhang
   <br> Poster at __SOSP 2017__

1. __Disaggregated Operating System__ [PDF](https://lastweek.github.io/pubs/SoCC17-Lego-Poster.pdf)
   <br> *Yizhou Shan*, Sumukh Hallymysore, Yutong Huang, Yilun Chen, Yiying Zhang
   <br> Poster at __SoCC 2017__
--->

## Professional Services

**Program Committee**

- FAST    (2026, 2025)
- EuroSys (2025, 2024, 2023)
- ATC     (2025, 2024, 2023)
- NSDI    (2026, 2025, 2024)
- SoCC    (2023, 2022)

**Shadow/External Program Committee**

- EuroSys (2022-shadow, 2021-shadow)
- ASPLOS  (2021-external)

**Journal Reviewer**

- Journal of Systems Research: 2021 - Current
- ACM Transactions on Architecture and Code Optimization (TACO): 2021
- ACM Transactions on Storage (TOS): 2020
- IEEE/ACM Transactions on Networking: 2020

**Artifact Evaluation Committee**

- SOSP (2021)
- OSDI (2020)


## Social

:surfer: :rowboat: :basketball: :football:  

* [Google Scholar](https://scholar.google.com/citations?user=qgxGqYAAAAAJ&hl=en)
* [Github](https://github.com/lastweek)
* [Twitter](https://twitter.com/Yizhou_Shan)
* [LinkedIn](https://www.linkedin.com/in/lastweek/)
* [Goodreads](https://www.goodreads.com/user/show/117378875-yizhou-shan)

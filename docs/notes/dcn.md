# Notes on Modern Data Center Networking

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Oct 2, 2021| Planning |

This is my note on datacenter networking. This is work-in-progress.
I will try to cover the following topics:

- Peering
- Cloud gateways
- Cloud internal routing
- Networking Topology
- Software Defined Networking (SDN) and OpenFlow
- Networking Load Balancers
- Networking Upgrade
- Switch Hardware and Software (e.g., p4 switch)
- Host-side NIC Design
- Host-side Network Virtualization (e.g., OpenVSwitch and VPC)
- Transport Design (Retransmission and Congestion Control)
- RDMA and RoCE
- Host-side Networking Stack Design

## Overview

I should draw a figure, including host side network stack/nic, switch, topologies, sdn controllers and so on.
And list which parts demand attention.

## Peering, Gateway, and Routing

## Topology
Clos, fat-tree, jupiter, vl2, fb's 40/100g topology.

### SDN and OpenFlow
Orion, and its predecessor.

### Upgrade 
NSDI papers, live update, cost.

## Network Virtualization
openvswitch, Andromeda.

## Host Networking Stack
Snap.



## Special Topics

This section covers special topics.

### Special Topcis on Transport Design

and programmable transport

#### Congestion Control

Shallow switch buffer. DCTCP.

### Special Topics on RDMA and RoCE

### Speical Topics on Programmable Switch and SmartNIC

### Special Topics on Kernel-Bypassing Netork Stacks

RPC papers. ZygOS, Shenengo, Arrakis etc. whole stack design.


### Special Topics on Packet Scheduling
PIFO etc.

### Special Topics on Datacenter Traffic Study
IMC'10 etc.

### Special Topics on Middlebox and Network Function Virtualization (NFV)


### Special Topics on Circuit Switches
TBD

### Special Topics on Failure, Reliability

Link error rate.
Applied erasure coding on packets.
Trace studies.

## Cloud Case Studies

In this section, we look at popular cloud vendors and briefly their networking stack status.

### GCP

Their networking services https://github.com/priyankavergadia/google-cloud-4-words#networking.

## Azure
SmartNIC

## Google Cloud
1RMA, Swifit, Snap, Orion

## Alibaba

p4 switch.
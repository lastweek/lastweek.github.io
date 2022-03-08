# Data Center Resource Disaggregation

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Mar 7, 2022|Initial|

This note discusses Resource Disaggregation's Design Spectrum.

In our categorization, the traditional distributed systems approach is *logical resource disaggregation*.
The newly emerged hardware resource disaggregation is *physical resource disaggregation*.
The main difference lies in whether an indirection layer is required to achieve the conceptual resource pool view.
Combined, they are two extreme design points of the resource disaggregation idea.

All images below are from my recent defense slides.
This note is part of my defense's intro.

The full defense slide is [here](http://lastweek.io/pubs/Defense_Slides_Yizhou_Shan.pdf).

---

## Intro

**Resource Disaggregation** is a really general idea
with a wide design spectrum that covers many
designs and systems in data centers.
The essense of resource disaggregation
is to *decouple resources so as to achieve independent resource scaling and failing*.
It has been applied in different granularities and to many different domains.

The traditional resource disaggregation is usually
built on top of monolithic servers using conventional distributed systems.
It has been applied everywhere in data centers,
just in different granularities.
For example, in the classical storage disaggregation
deployment, storage pools are disaggregated from compute pools;
in machine learning deployment, paramemter servers are disaggregated
from workers; in typical SDN deployment, control plane servers
are disaggregated from data plane servers/switches.
All these examples are instantiations of the resource disaggregation idea.

![3](./resource-disaggregation-spectrum/3.png)

---

**Hardware Resource Disaggregation** is a super HOT research proposal
that breaks the physical monolithic
servers into segregated, network-attached hardware resource pools,
each of which can be built, managed, and scaled independently.
The disaggregated approach largely increases the management
flexibility of a data center.

![4](./resource-disaggregation-spectrum/4.png)

Hardware resource disaggregation is a drastic depature
from the traditional computing paradigm and it calls
for a top-down redesign on hardware, system software, networking, and applications.

## Design Formula

Is hardware resource disaggregation just a buzzword?
Is it just another old wine in the new bottle kind of idea?

I argue that the traditional resource disaggregation design approach
using distributed systems and the newly emerged hardware resource
disaggregation are not exclusive to each other
and in fact can be unified within one design spectrum,
with each being one end of the spectrum.

Before we dig into the design spectrum.
I want to spent a few words on the _**Resource Disaggregation Formula**_:
one would take a set of system software and a set of disaggregated
hardware devices or servers, then use whatever approach, to produce
the same ultimate goal, which is the **conceptual resource pool view**.
The pool can be a CPU pool, a memory pool, a Parameter Server pool.
Basically every standalone "conceptual" resource.
Think about the examples we mentioned earlier,
all systems follow this formula, just produce different "resource pools".
![1](./resource-disaggregation-spectrum/1.png)

## Design Spectrum

Now, the categorization.

On the far left, we have the **logical resource disaggregation**,
which represents the traditional resource disaggregation model.
This model builds on top of monolithic servers.
A server would contribute part or all its resource
to a certain resource pool. A server can be a part of multiple pools.
Usually, an indirection layer at each server
is required to achieve this goal.
Essentially, the ultimate resource pool just _**logically**_ maps
back to the actual servers.
This is the common-wisdon on building distributed systems.

On the far right, we have the **physical resource disaggregation**,
which represents the emerging hardware resource disaggregation model.
This model builds on top of disaggregated hardware devices.
Usually, no indirection layer is required.
So essentially, the ultimate resource pool could _**physically**_ maps
back to the actual physical devices.

In the middle, we have the *Hybrid Disaggregation* which
has the best of both worlds. It has both normal servers
and disaggregated devices.

The following image shows the design spectrum.
![2](./resource-disaggregation-spectrum/2.png)

## My Work

So far, my work in this space has covered all grounds.
(DUH! I defined the specturm to fit my work! :-) )

![myWork](./resource-disaggregation-spectrum/myWork.png)

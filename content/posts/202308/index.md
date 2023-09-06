---
title: "Refactoring my Homelab: from SystemD to Nomad"
date: 2023-08-30T18:07:27+02:00
mermaid: true
tags:
  - update
---
Ah, the Home Lab—a geek's sanctuary and the best DIY project since the invention
of the potato-powered clock. Well, for me, this project has been a riveting
journey from a single node cluster managed by SystemD services to a flexible
3-node setup with Hashicorp Nomad running on Raspberry Pis. Grab a coffee or
something stronger, this story has it all: servers, code, and a good deal of
tinkering!

## The Setup and goals

Originally I started from a QNAP machine with 4 disks, and then I moved to
a set up with ZFS on one Raspberry Pi 4 Zero with 4GB of RAM. That was 
not enough for the workloads!

This time I decided to work with more hardware so that I can apply some solid 
principles. I want to:

* Run the workload in 3 Raspberry Pis for reliablity
* ZFS would still be used as filesystem for the disks
* NFS would be used so that the workload can access the disks no matter where 
  it runs.
* All the machines and services would be accessible via Tailscale
* Grafana Cloud would be used so that I don't have to host Prometheus, Loki
* Everything is following a 3-2-1 backup rules using Restic and ZFS

At the beginning I though that Kubernetes would have been a good solution
but the more I write YAML for the ansible playbooks to automate the process, the 
more I realised how unnecessarely overcomplicated K8S is.

## Nomad comes to rescue

I've opted for [Hashicorp's Nomad](https://www.nomadproject.io) over the 
Kubernetes for its simplicity, versatility, and lower cognitive overhead.
Nomad's single-binary nature makes it incredibly easy to manage and integrate,
unlike the complex architecture of Kubernetes.

At the beginning I thought that Nomad would work perfectly by itself. After 
all [Hashicorp announced that Consul is no longer necessary](https://www.hashicorp.com/blog/nomad-service-discovery) 
for service discovery. But I had issues with consistency in the cluster as well
as leader elections, so I had to introduce Consul.

With Consul I was able to:

* Increase stability in the Nomad configuration
* Enable proper service discovery
* Allows Traefik to self-configure to do proper reverse proxy

Though it is not necessary, as Traefik supports Nomad Services too, Consul makes
more sense to have.

In general I have noticed that Nomad is way quicker and responsive than my past
experiences with K8S (and k3s specifically). It is designed with semplicity and
much of the complexity baked in K8S are not needed. I just needed a solution
that is more advanced that manually setting SystemD services. That said, if 
there are features that Nomad is lacking, they are replaced by other solutions.

In general Nomad feels more [KISS](https://en.wikipedia.org/wiki/KISS_principle) 
than Kubernetes, and does one job, and it does it well. Replacing YAML with HCL
is easing a lot of steps. If you are considering Nomad, the following links
helped me setting it up:

* [A Kubernetes User's Guide to HashiCorp Nomad](https://www.hashicorp.com/blog/a-kubernetes-user-s-guide-to-hashicorp-nomad)
* [Nomad tips and tricks](https://danielabaron.me/blog/nomad-tips-and-tricks/)

## The hardware architecture

The hardware itself is very simple. It consist in these phisical machines:

* `storage0`: A Raspberry Pi 4 with 8GB of RAM is tasked with the lofty 
  responsibility of storage, running ZFS like a champ :flex: It's main focus
  is storage and it runs workloads that are requiring a reliable access to 
  the volumes.

* `compute0` and `compute1`: Now, here come the workhorses of the operation.
  Both Compute nodes are equipped with Raspberry Pi 4 but vary in RAM
  size: compute0 with 8GB and compute1 with 4GB. These are the daredevils that
  take on the workloads.

This cluster can be expanded easily, and does not have limits on how/what the 
machines should look like. Infact I am trying to abstract as much as possible
some constraint related to CPU architecture. Nomad provides easy templates that
allows me to download and run the right binary based on which machine is running
the job. This means that I don't care if it is an ARM, Intel, Linux or macOS,
as long as the Nomad Job supports it properly.

The Compute nodes are running any workload (mostly HTTP services) and are 
mounting disks using NFS. To acheive this I am very happy that Nomad is 
compatible with CSI, and there is a CSI plugin that works perfectly with NFS
and Nomad for my own use-case. Kudos to RocketDuck for making [this plugin
on GitLab](https://gitlab.com/rocketduck/csi-plugin-nfs).


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
not enough for the workloads! So I decided to change this setup and build with
some ground rules:

* Workload would run in 2 other Raspberry Pi
* A new Raspberry Pi with 8GB of RAM would take care of storage
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

I've opted for Hashicorp's Nomad over the Kubernetes for its simplicity,
versatility, and lower cognitive overhead. Nomad's single-binary nature makes it
incredibly easy to manage and integrate, unlike the complex architecture of
Kubernetes.

At the beginning I thought that Nomad would work perfectly by itself. After 
all [Hashicorp announced that Consul is no longer necessary] 
for service discovery. But I had issues with consistency in the cluster as well
as leader elections, so I had to introduce Consul.

With Consul I was able to:

* Increase stability in the Nomad configuration
* Enable proper service discovery
* Allows Traefik to self-configure to do proper reverse proxy

Nomad allows me to do a

## The hardware architecture

This is how the architecture looks like from a Storage Prospective:

{{< mermaid >}}
flowchart TB
  C0[Compute Node 0]
  C1[Compute Node 1]

  C0 <-- NFS --> S0
  C1 <-- NFS --> S0

  subgraph S0[Storage Node]
    direction TB
    ZFS[ZFS with raidz2-0] <--> Restic[Restic Backups]
  end
{{< /mermaid >}}

The Compute nodes are running any workload (mostly HTTP services) and are 
mounting disks using NFS. To acheive this I am very happy that Nomad is 
compatible with CSI, and there is a CSI plugin that works perfectly with NFS
and Nomad for my own use-case. Kudos to RocketDuck for making [this plugin
on GitLab](https://gitlab.com/rocketduck/csi-plugin-nfs).


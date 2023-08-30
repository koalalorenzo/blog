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

At the beginning I though that Kubernetes (K3S) would have been a good solution
but Nomad seems to be a better solution.


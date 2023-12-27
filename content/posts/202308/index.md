---
title: "Rebuilding my homelab with Nomad"
date: 2023-08-30T18:07:27+02:00
mermaid: true
tags:
  - update
---
Ah, the Home Lab—a geek's sanctuary and the best DIY project since the invention
of the potato-powered clock. This blog post is about my Home Lab, and how I
transformed it from a single node cluster managed by SystemD services to a 
flexible 3-node setup with Hashicorp Nomad running on Raspberry Pis. These are 
some notes from this experience.
<!-- more -->

Originally I started from a QNAP machine with 4 disks. There was nothing wrong 
with that setup except that QNAP was [riveting with bugs and broken security
issues][1]... and it was too easy: pre built software is nice but boring! 

So I moved to a set up with ZFS on one Raspberry Pi 4, 4 HDD and a lot of
patience. I even made a [HomeKit bridge for SystemD][2] That was right enough
for ZFS, but not enough for the workload that I had in mind. I wanted to run,
experiment and play with new _toys_ all the time and these 4 GB of RAM barely
managed ZFS and NFS.

[1]: https://arstechnica.com/information-technology/2023/02/thousands-of-qnap-devices-remain-unpatched-against-9-8-severity-vulnerability/
[2]: https://blog.setale.me/2023/07/23/Apple-HomeKit-and-Linux-SystemD/

## Some principles

For the next setup I decided to work with more hardware and stick to RPis so 
that I can apply some solid principles. I want to:

* Run the workload in 3 Raspberry Pis for reliablity
* ZFS would still be used as filesystem for the disks
* NFS would be used so that the containers can access volumes on demand.
* All the machines and services would be accessible via Tailscale
* Grafana Cloud would be used so that I don't have to host Prometheus, Loki, etc
* Everything is following a 3-2-1 backup rules using Restic and ZFS

At the beginning I though that Kubernetes would have been a good solution
but the more I write YAML for the ansible playbooks to automate the process,
the more I realised how unnecessarely overcomplicated K8S is.

## Nomad comes to rescue

I've opted for [Hashicorp's Nomad][3] over the 
Kubernetes for its simplicity, versatility, and lower cognitive overhead.
Nomad's single-binary nature makes it incredibly easy to manage and integrate,
unlike the complex architecture of Kubernetes.

At the beginning I thought that Nomad would work perfectly by itself. After 
all [Hashicorp announced that Consul is no longer necessary][4] 
for service discovery. But I had issues with consistency in the cluster as well
as leader elections, so I had to introduce Consul.

With Consul I was able to:

* Increase stability in the Nomad configuration
* Enable proper service discovery
* Allows Traefik to self-configure to do proper reverse proxy

Though it is not necessary, as Traefik supports Nomad Services too, Consul makes
more sense to have.

In general I have noticed that Nomad is way quicker and responsive than my past
experiences with K8S (and k3s specifically). It is designed with simplicity and
much of the complexity baked in K8S are not needed. I just needed a solution
that is more advanced then manually setting SystemD services. That said, if 
there are features that Nomad is lacking, they are replaced by other solutions.

In general Nomad feels more [KISS][5] 
than Kubernetes, and does one job, and it does it well. Replacing YAML with HCL
is easing a lot of steps. If you are considering Nomad, the following links
helped me setting it up:

* [A Kubernetes User's Guide to HashiCorp Nomad](https://www.hashicorp.com/blog/a-kubernetes-user-s-guide-to-hashicorp-nomad)
* [Nomad tips and tricks](https://danielabaron.me/blog/nomad-tips-and-tricks/)

[3]: https://www.nomadproject.io
[4]: https://www.hashicorp.com/blog/nomad-service-discovery
[5]: https://en.wikipedia.org/wiki/KISS_principle

## The hardware architecture

The hardware itself is very simple. It consists in these physical machines:

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
on GitLab][6], but sooner I found [the official k8s NSF CSI plugin][7] to
work out of the box and to be a little more versatile (_Like I can select
the NFS server for each volume_). You can see my Noamd Job specifications
[here][9] and [here][10] if you want to copy-paste it.

[6]: https://gitlab.com/rocketduck/csi-plugin-nfs
[7]: https://github.com/kubernetes-csi/csi-driver-nfs
[9]: https://gitlab.com/koalalorenzo/homelab/-/blob/63a5db0db39556edf5fecdb465cf2f1e42d42056/system/csi-nfs-controller.job.hcl
[10]: https://gitlab.com/koalalorenzo/homelab/-/blob/63a5db0db39556edf5fecdb465cf2f1e42d42056/system/csi-nfs-nodes.job.hcl

## Immutable Infrastructure

I have always been using Ansible for my HomeLab, but this time I had to divide
what Ansible was buildng and what Nomad would manage. Originally Ansible would
set up and deploy services/containers using podman and SystemD. With Nomad I
could still trigger Ansible to deploy the jobs/containers, but instead 
decoupling the OS from the contaienrs gives me the power of implementing 
some immutable infrastructure practices at home.

In this way if I have some issue with one node (_and trust me, it happened_),
or simply to run some upgrades I can just move temporarely the workload 
to another node, re build the underlying OS image, without worring about 
SystemD and various configurations.

For example, I wrote [this Ansible playbook][8] that allows me to reboot machines
on demand without causing downtime. It basically runs this comad to migrate 
the workload somewhere else:

```bash
  nomad node drain -enable -self -deadline 1m
```

It will wait for the jobs runnign in that node to move somewhere else and then
marks the node as not available for scheduling. Then It would reboot the machine
and mark itself as available once everything is ready, by running again:

```bash
  nomad node eligibility -enable -self
```

This is something basic in the cloud operations, but I find it very exciting 
that I can finally do it on my Raspberry Pis.

[8]: https://gitlab.com/koalalorenzo/homelab/-/blob/63a5db0db39556edf5fecdb465cf2f1e42d42056/nomad/reboot.yaml

## New capabilities = New challenges
Building the cluster and setting it up with Nomad and even Consul is very easy. 
Managing it seems to be also very easy, but I have been doing it for fun and 
only for barely less than a year. I am impressed by the stability but I am more
impressed by how a single binary carries features without overcomplicating the 
setup.

Some of these features, that are not part of the standard k8s experience, are 
out of the box. Besides being much ligher it offers different `drivers`
to run the workloads / jobs. I am referring mostly about the `exec` and 
`raw_exec` drivers that allow me to run any binary and workload, without 
the need of a container.

This comes with a price that many procedures needs to be rethought, but for 
example it fits perfectly my need of "_just run `restic backup` 
command on that cronjob_"

Rewriting most of docker compose examples to nomad jobs in HCL was both a 
challenge that made me cry of joy. Moving away from YAML to HCL it's pure 
happiness. The syntaxt feels more clear and manipulating it makes more sense:
Those are not just manifests, but piece of code that can be adjusted on the fly,
like using the templating system to automatically restart 
a workload when some other workload changes configuration.

For example my Blocky (DNS ad-blocker) setup, uses this template:

```yaml
{{ range service "redis" }}
redis:
  required: false
  address: {{ .Address }}:{{ .Port }}
{{ end }}
```

Nomad would then change the config file and resetart Blocky whenever the 
Redis service changes. If there is no Redis available, it would simple omit
those lines. The challenge here is just understanding the difference with 
k8s services, and how much complexity is removed from sepcifying an address
and a port. There are also other way to address this to be honest, but for my
use case this works the best.

## Some scheduler and client settings
To make sure that all the resources were in use in a reliable way, (ex: don't
put all your eggs in one basket) I had to change some of the settings of the
scheduler. Bin packing works fine, but in my case I can't scale horizontally
(_I could, but it requires me buying a new raspberry pi 4... if I could find
any!_). So instead I changed the code to balance the way jobs are scheduled:

```hcl
server {
  default_scheduler_config {
    scheduler_algorithm = "spread"
  }
  [...]
}
```

At the same time I wanted to reduce as much as possible the workload running on
`storage0` (so that it focuses mostly on backups, volumes and ZFS shennanigaz).
I applied this line of code to define a `node_class`:

```hcl
client {
  node_class = "<storage or compute>"
  [...]
}
```

Then inside my Nomad Job, I can set the affinity, so that the scheduler can
prefer the `compute` nodes:

```hcl
job "something" {
  affinity {
    attribute = node.class
    value     = "compute"
    weight    = 90
  }
  [...]
}
```

I decided to use the node class instead of other node labels. Conceptually
this is not differeht thant k8s affinity and anti-affinity rules. A handy
feature that I started using instantly is [assigning priorities][priority]
to Nomad Jobs. This tells the scheduler what to run if there is not much
availability of resources or in case of other situations. For example I want
almost always to run Traefik nodes to redirect HTTP and HTTPs traffick to
the right containers, or NSF-CSI containers to avoid issues with Storage.

```hcl
job "something-important" {
  priority = 95
  [...]
}
```

## Simplifying networking setup
Some thoguhts about network setup and port allocation over virtual networks.

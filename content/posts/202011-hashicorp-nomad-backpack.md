---
title: "Backpack: hashicorp nomad jobs packages"
date: 2020-11-12T19:12:20+01:00
draft: false
authors:
  - Lorenzo Setale
tags:
  - hashicorp
  - nomad
  - template
  - helm
  - backpack
  - golang
  - development
  - devops
  - sre
thumbnail: /posts/202011/gopherswrench.jpg
---
I recently decided to run at home a Hashicorp Nomad cluster with my Raspberry 
Pi. When I was using, I found myself writing a significant amount of HCL files 
than I expected, and I have been missing Helm's simplicity.

I have been working with Kubernetes for a while now. During this time, I had to 
install, configure, and distribute some apps using Helm. For me, it is a 
de-facto standard when it comes to deploy and maintain apps that otherwise would
require a way bigger list of YAML files. Can we do the same for Nomad Jobs's 
definitions in HCL?

<!--more-->
![Go Gophers at work](/posts/202011/gopherswrench.jpg#center)

So I did it for pure fun, and during my spare time: I made Nomad's Backpack! 😀 
I decided to keep things as similar as possible to Helm but improve on it too,
all based on my personal experience.

## A Backpack is like a chart
I am lazy; therefore, I don't want to learn a new templating language: I started 
working around the same concept to make it easy to understand. For example, the
things that are I kept similar are:

* Uses the same *Go templates*
* The default configuration is a *YAML* file
* All lives under a single go binary
* It is easy to create, test, and deploy new packs

For example, to get started you can create a boilerplate directory structure:

```bash
backpack create my-app
```

This comand just created a directory `test-0.1.0` with `values.yaml` containing 
the default values passed to the Go templates.

## A Backpack is not just YAML

But there were a few things that I was not happy about and that I wanted to 
change. My big personal frustration was related to **documentation**. Often when 
there is a new version of a helm chart, the documentation for specific variables
is lost, not synced, or hard to understand. I often found myself deploying 
DataDog agents, but the version I was using was not using the same values 
defined in the documentation. 

To solve this issue, I have decided to package the documentation and the 
templates, and the values altogether. This change makes sure that the version 
I am reading is the same I am configuring and deploying.

```bash
backpack unpack docs https://backpack.qm64.tech/examples/redis-6.0.0.backpack
```

This command just created a directory `redis-6.0.0` containing only the Markdown
files for the documentation. 

Another feature that I wanted to improve on is that Helm chart focuses mostly on
Kubernetes as a Docker-first platform. In Hashicorp Nomad, this is slightly 
different.  The Job doesn't have to be necessarily a docker container! 
For example, it can be a binary downloaded on the fly with the architecture. 
An app that would support this is redis: you can select the Job driver to be a 
docker container or a chroot-ed binary.

```bash
backpack run https://backpack.qm64.tech/examples/redis-6.0.0.backpack -f values.yaml
```

## Things I want to work on 

There are a few things I want to work on but had little time. I want to 
implement the packages and repository with [IPFS](https://ipfs.io/) in mind to 
avoid packages disappearing. I wish Backpack was smarter and capable of reading 
the cluster configuration to pick up automatically things like the job drive to 
use for the template, or like the service tags to implement to configure 
traefik or fabio-lb. I would love to pack multiple containers, apps, and tools,
solve issues like dependency management and more... 

For now, I will work on it in my spare time. I have released the source code on 
[GitLab](https://gitlab.com/Qm64/backpack), and if you want to help feel free
to ask a question on the 
[Matrix chatroom](https://matrix.to/#/#qm64:matrix.org?via=matrix.org) or leave
a comment to this post!

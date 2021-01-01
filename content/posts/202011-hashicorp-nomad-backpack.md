---
title: "Backpack: helm charts but for Hashicorp Nomad"
date: 2020-11-12T19:12:20+01:00
draft: false
tags:
  - Qm64
  - project
  - hashicorp
  - nomad
  - template
  - helm
  - backpack
  - golang
  - development
  - devops
  - SRE
thumbnail: /posts/202011/gopherswrench.jpg
aliases: 
  - /posts/202011-hashicorp-nomad-backpack
---
I recently decided to replace my k8s home cluster with a **Hashicorp Nomad**
cluster on my 3 Raspberry Pis. When I was using it, I found myself writing a
significant amount of HCL files, and I have been missing Helm's simplicity.

As an SRE, I have been working with Kubernetes for a while now. During this time,
I had to install, configure, and distribute some apps using Helm. For me, it is
a de-facto standard when it comes to deploy and maintain apps that otherwise
would require a way bigger list of YAML files. Can we do the same for Nomad
Jobs's definitions?

<!--more-->
![Go Gophers at work](/posts/202011/gopherswrench.jpg#center)

Yes, we can! For pure fun and during my spare time, I made **Backpack** for Nomad!
😀 I decided to keep things as similar as possible to Helm but improve on it
too, all based on my personal experience.

```bash
# Please check the README.md as this might be outdated! 😉
go get -v gitlab.com/Qm64/backpack
cd $GOPATH/src/gitlab.com/Qm64/backpack/
make install
# Check that it works:
backpack help
```

_Hint_: I left some _TL;DR_ in the [README.md](https://gitlab.com/Qm64/backpack/-/blob/master/README.md)
to quick start Nomad and test out backpack! 😉 Also note, that this article
is written on version 0.1.0... things might change.

## Backpack is like Helm
When I started writing the code of Backpack, I had to keep in mind that this is
for myself or people like me... I am lazy 😅 therefore, I don't want to learn a
new templating system: I would find annoying to have to learn a new way when I
have spent the past 5 years writing Helm charts! Instead, I decided to keep some
things _similar_:

* Backpack Uses the same **Go templates** and extra functions[^templates]
* The default configuration/values is a **YAML** file[^format]
* All done with a single Go binary
* Multiple workloads can be packed together in a _Pack_[^equivalent]
* It is easy to create, test, and deploy new packs[^binhelp]

[^templates]: I am using go templates with [Sprig](https://github.com/Masterminds/sprig)
  as Helm charts.

[^format]: YAML might not be the most loved format, I do believe I can adjust
  the code to support multiple human-readable formats 🤔

[^equivalent]: a _Pack_ is the equivalent of an "Helm Chart", open for suggestion
  if the name is not following the travelling theme 😜 

[^binhelp]: I think the core is to make it easy: `backpack help` might do the
  trick!

To get started you can create a boilerplate directory structure:

```bash
backpack create my-app
```

This command just created a directory `my-app-0.1.0` with `values.yaml`
containing the default values passed to the Go templates.

## A Backpack is not just YAML

But there were a few things that I was not happy about and that I wanted to
change. My big personal frustration was related to **documentation**. Often when
there is a new version of a helm chart, the documentation for specific variables
is lost, not synced, or hard to understand. 🙄 I often found myself deploying
DataDog agents, but the version I was using was not using the same values
defined in the documentation.

![reading docs](/posts/202011/reading.gif)

To solve this issue, I have decided to package the documentation and the
templates, and the values altogether. This change makes sure that the version
I am reading is the same I am configuring and deploying.

```bash
backpack unpack docs https://backpack.qm64.tech/examples/redis-6.0.0.backpack
```

This command just created a directory `redis-6.0.0` containing only the Markdown
files for the documentation. 😎 No more googling, or searching on github commits
history. It is right there, next to the code!

Another feature that I wanted to improve on is that Helm chart focuses mostly on
Kubernetes as a Docker-first platform. In Hashicorp Nomad, this is slightly
different.
[A Job doesn't have to be necessarily a docker container](https://www.nomadproject.io/docs/drivers)!
It can be a binary downloaded on the fly[^nomadbinary]. An app that
would support this is [FabioLB](http://fabiolb.net/): you can select the Job 
driver to be a docker container or a chroot-ed binary[^jobdriver]. I already
wrote a pack for it! 😉

[^jobdriver]: This is still a work-in-progress feature. I just need to manually
  implement it in every template for now. Please check the documentation of 
  the pack to know what drivers are supported!

[^nomadbinary]: Nomad can dowload the right binaries, with the right CPU 
  architecture (ex: amd64, armhf, arm64...) of the machine and the right OS 
  (macOS, Linux...). All is done with variables: pure magic 😍

```bash
# Deploy FabioLB using Docker driver for Nomad
echo "driver: docker" > values.yaml
backpack run https://backpack.qm64.tech/examples/fabiolb-1.5.14.backpack -v values.yaml
# Now Nomad will download the right docker image and start Fabio from there:
nomad ui fabiolb

# Switch to raw_exec (use exec for chroot, check driver docs)
echo "driver: raw_exec" > values.yaml
backpack run https://backpack.qm64.tech/examples/fabiolb-1.5.14.backpack -v values.yaml
# Now Nomad will download the right binaries (CPU and Platform) and start Fabio:
nomad ui fabiolb
```


## Future plans for the project

This is just a starting point. I made this for myself, but I other poeple could
find it useful as I do! 🤞

There are a few things I want to work on but had little time. I want to
implement the packages and repository with [IPFS](https://ipfs.io/) in mind to
avoid packages disappearing. I wish Backpack was smarter and capable of reading
the cluster configuration to pick up automatically things like the job drive to
use for the template, or like the service tags to implement to configure
[traefik](https://learn.hashicorp.com/tutorials/nomad/load-balancing-traefik)
or [fabio-lb](https://fabiolb.net). I would love to pack multiple containers,
apps, and tools, solve issues like dependency management and more...

![I will do that later](/posts/202011/karenwalker-later.gif#smallSquare)

For now, I will work on it in my spare time. I have released the source code on
[GitLab](https://gitlab.com/Qm64/backpack), and if you want to help feel free
to ask a question on the
[Matrix chatroom](https://matrix.to/#/#qm64:matrix.org?via=matrix.org) or leave
a comment to this post!

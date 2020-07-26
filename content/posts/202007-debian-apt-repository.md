---
title: "Building a Debian Repository - DevOps Style"
date: 2020-26-01T20:41:28+01:00
draft: false
authors:
  - Lorenzo Setale
tags:
  - debian
  - linux
  - devops
  - ubuntu
  - dpkg
  - apt
  - 
thumbnail: /posts/202005/network.png
---

Honestly, I am writing this post feeling a little bit reluctant about it. In a 
word filled with Containers, PaaS, and SaaS, it seems weird to talk about how we
can automate the creation of Debian packages and APT repositories. Nonetheless, 
I still some custom Debian packages for my Raspberry Pi as some projects are not
packaging them.

This blog post is about my experiments using GitLab CI/CD pipelines to build 
packages and publish a Debian Repository.

# A little bit about distributing Debian packages

Debian packages (and APT repositories) are useful for distributing and keeping 
Debian-based Operative Systems up to date. Adding software via apt install is 
cleaner than download binaries or using ad-hoc processes to manage versions. 

Not using a Debian repository is understandable: somebody has to maintain it and
keep it updated. That takes time, and it is not always easy to do. I think 
nobody likes this process as it is not fun as writing code! So what if I write 
some code to do that for me?

# What do I want to do?
The goals for this project are:

1. Automate the building of the packages
2. Build the repository automatically as well
3. Use the GitLab CI/CD pipeline to do everything periodically.
4. Use GitLab Pages to host the static website with the repository.

# Let's do it!

In this post,  I will pack IPFS Go binaries in a Debian package. Then  I will 
distribute this package in a repository. This can be applied to a set of other 
projects that are only publishing binaries and no package.

## Building a .deb file
Build a Debian package is a complex process, but I can automate that in 
different ways. There are various articles/guides that you can find talking 
about this. Since I use GitLab CI/CD pipelines, I use a docker container and 
`dpkg-buildpackage` to build the packages.

To do that, I need to create a set of files in specific directories. To automate
this process, I am creating a "template" that scripts will modify with the 
following structure:

You can access the files here. Those files are defining a few things:
- The changes from one version to another
- The package details (Name, Version, Maintainer, Architecture, etc.)
- Files to install (where to decompress them)
- The system services to install.

The command in the Makefile will replace some variables like `${VERSION}` or 
`${DATE}` and build the package as a whole:

## Building the repository
Now that I have one package (or more than one), I need to build a repository. 
All the script has to do is move all the `.deb` files in a directory, make the 
repository, and digitally sign the data.

I am using `apt-ftparchive.` It requires a configuration file similar to this:

```
```

Then all I have to do is to instruct the Makefile to use it to build the 
database, compress it in different formats:

```
```
All it is left to do is instruct the Pipeline to run the commands, then upload 
the repository (saved in the `pages` directory) and publish the files to GitLab 
Pages:

```
```

I previously configured GitLab Pages, but if you are curious, you can follow 
this guide here. (Spoiler alert: change the settings, and push the `/pages` 
artifacts directory 😉 )

All the source code for this is available here. You can see that I am building 
more than one package. Feel free to open a PR if you want to add a new software 
there!

# Conclusions
Building packages from static binaries was more pleasant than expected. Most of 
the PaaS and SaaS solutions that we use to build and distribute software are 
moving me away from the "Ops" part of DevOps. With the promise of simplifying, I
buy into black boxes made by big companies that will take care of "that" for me. 
Distributing packages is one of those things that I still have to take care of 
even if I am using Immutable Infrastructure or if I am using Docker Containers 
based on Debian/Ubuntu.

There is something that I have ignored on purpose: GPG Signatures! It is 
strongly suggested (if not required) to sign a few files. Digital signatures are 
present because HTTPs is not the default transport protocol used. Instead, GPG 
covers HTTP, FTP, and other methods to distribute files (does anybody remember 
when repositories were on CD/DVDs?). But don't panic! It is a simple process. 
In a pipeline, it is required to store that GPG key safely in the env 
configuration or inside something like Hashicorp Vault. 

Honestly speaking, I could have used Launchpad to distribute my packages, but I 
wanted to have more fun 😀

---
title: "Using a GitLab to build a Debian Repository"
date: 2020-08-02T22:40:28+01:00
draft: false
tags:
  - Qm64
  - project
  - debian
  - linux
  - devops
  - ubuntu
  - dpkg
  - apt
  - gitlab
  - devops
  - SRE
  - pipeline
  - ipfs
thumbnail: /images/202008/repo.gif
aliases:
  - /images/202008-debian-apt-repository
---

I have the feeling that a blog post about distributing packages is needed. 😮
In a word filled with Containers, PaaS, and SaaS, it seems weird to talk
about how we can automate the creation of Debian packages and APT repositories.
Nonetheless, even if this appears to be a forgotten step for operations, some
projects are not distributed over Debian packages, 👷‍♂️ and I need them for my
Raspberry Pi! 😜 
<!--more-->

![Debian package](/images/202008/debian-pkg-icon.png#smallSquare#noborder)

## A little bit about distributing Debian packages

[Debian packages](https://en.wikipedia.org/wiki/Deb_%28file_format%29)
(and [APT repositories](https://en.wikipedia.org/wiki/APT_(software)) are useful
for distributing apps and keeping Debian-based Operative Systems up to date.
Adding software via apt install is cleaner than download binaries or using ad-hoc
processes to manage versions.

![Debian package](/images/202008/repo.gif#center)

Not using a Debian repository is understandable: somebody has to maintain it and
keep it updated. That takes time, and it is not always easy to do: open source
software is updated every day! I think nobody likes this process as it is not
fun as writing code! So what if I write some code to do that for me and automate
the building of a repository?

## What do I want to do?
The goals for this project are:

1. Automate the building of the packages
2. Build the repository automatically as well
3. Use the GitLab CI/CD pipeline to repeat the process **periodically**.
4. Use GitLab Pages to host the static website with the repository.

## Let's do it!

In this post,  I will pack [IPFS Go binaries](https://dist.ipfs.io/#go-ipfs) in
a Debian package. Then  I will distribute this package in a repository.
This can be applied to a set of other projects that are only releasing binaries
but no easy-to-install packages.

### Building a .deb file
Build a Debian package is a complex process, but I can automate that in
different ways. There are various articles/guides that you can find talking
about this. Since I use GitLab CI/CD pipelines, I use an Ubuntu docker container
and `dpkg-buildpackage` to build the packages.

To do that, I need to create a set of files in specific directories. To automate
this process, I am creating a "template" that scripts will modify with the
following structure:

![Debian Source file tree](/images/202008/source-tree.png#bigSquare#noborder)

You can have a better look [the files here](https://gitlab.com/Qm64/apt/-/tree/master/source).
Those files are defining a lot of things, including:

- The changes from one version to another
- The package details (Name, Version, Maintainer, Architecture, etc.)
- Files to install (where to decompress them)
- The system services to install.

To easily change things like the version or the architecture, I made customized
the files as _templates_. The commands in the Makefiles will replace some
variables like `${VERSION}` or `${DATE}` and build the package. For
example:

```makefile
_prepare_ipfs_deb: _unpack_ipfs
	mkdir -p build/deb/${DEB_ARCH}/ipfs-${IPFS_PKG_VERSION}
	cp -aR source/ipfs.deb/* build/deb/${DEB_ARCH}/ipfs-${IPFS_PKG_VERSION}/
	chmod +x build/deb/${DEB_ARCH}/ipfs-${IPFS_PKG_VERSION}/debian/rules
	# Updates details of the package
	sed -i 's/$${VERSION}/${IPFS_PKG_VERSION}/' build/deb/${DEB_ARCH}/ipfs-${IPFS_PKG_VERSION}/debian/control
	sed -i 's/$${DEB_ARCH}/${DEB_ARCH}/' build/deb/${DEB_ARCH}/ipfs-${IPFS_PKG_VERSION}/debian/control
	# Updates the pseudo-changelog
	sed -i 's/$${VERSION}/${IPFS_PKG_VERSION}/' build/deb/${DEB_ARCH}/ipfs-${IPFS_PKG_VERSION}/debian/changelog
	sed -i 's/$${DATE}/$(shell date -R)/' build/deb/${DEB_ARCH}/ipfs-${IPFS_PKG_VERSION}/debian/changelog
	# Move the binary.
	cp -aR build/source/go-ipfs/${ARCH}/go-ipfs build/deb/${DEB_ARCH}/ipfs-${IPFS_PKG_VERSION}/
.PHONY: _prepare_ipfs_deb
```

You can read the full scripted code [this file](https://gitlab.com/Qm64/apt/-/blob/master/makefiles/ipfs.mk).

### Building the repository
Now that I have one package (or more than one), I need to build a repository.
All the script has to do is move all the `.deb` files in a directory, make the
repository, and digitally sign the data.

I am using `apt-ftparchive`. It requires a configuration file similar to this:

```ini
APT::FTPArchive::Release::Origin "Qm64 OU";
APT::FTPArchive::Release::Label "Qm64 Debian Repository";
APT::FTPArchive::Release::Suite "stable";
APT::FTPArchive::Release::Codename "apt";
APT::FTPArchive::Release::Architectures "noarch amd64 arm64 i386 armhf";
APT::FTPArchive::Release::Components "main";
APT::FTPArchive::Release::Description "Qm64 Debian Repository for IPFS";
```

Then all I have to do is to instruct the [Makefile to use](https://gitlab.com/Qm64/apt/-/blob/master/makefiles/apt_repository.mk)
it to build the database, compress it in different formats. The code is very
short:

```makefile
repository_apt:
	apt-ftparchive -c ../Releases.conf packages apt > apt/Packages
	cat apt/Packages | gzip -9c > apt/Packages.gz
	bzip2 -kf apt/Packages
	apt-ftparchive -c ../Releases.conf release apt > apt/Release
.PHONY: repository_apt
```

All it is left to do is instruct the Pipeline to run the commands and upload
the repository (use the `pages` job) and publish the files to GitLab Pages:

```yaml
pages:
  stage: release
  script:
    - make deb_ipfs_amd64 collect_deb_packages repository_apt
    - mv ./dist ./public
  artifacts:
    paths:
    - public
    expire_in: 6 weeks
```

I previously configured [GitLab Pages](https://docs.gitlab.com/ee/user/project/pages/),
but if you are curious, you can follow [this guide here](https://about.gitlab.com/stages-devops-lifecycle/pages/). 😉

(_Otional_) The last thing to do is to set up a Gitlab CI/CD to run this
pipeline periodically, so that my registry will build the latest package. This
step is very easy but it is done on the website. I found this
[documentation here](https://gitlab.com/help/ci/pipelines/schedules) very useful.

All the source code for building the packages and the APT/Debian repository is
[available here](https://gitlab.com/Qm64/apt).
You can see that I am building more than one package. Feel free to open a PR if
you want to add a new software there! 🥰

## Conclusions
Honestly speaking, I could have used [Launchpad](https://launchpad.net) to
distribute my packages... or I could have just waited
[GitLab to work on the Debian Repository](https://gitlab.com/gitlab-org/gitlab/-/issues/5835)
implementation... but I wanted to have fun and complicate my life! 🤪

![Make things so complicated](/images/202008/make-things-complicated.gif)

Building automatically packages from static binaries is useful as it "removes"
a tedious process from my daily chores 😉. Most of the PaaS and SaaS solutions
that we use to build and distribute software are moving me away from the "Ops"
part of DevOps. With the promise of simplifying, I _buy_ black boxes made by
other companies that will take care of "that" for me 😍. The whole cloud computing
is based on this compromise. I love it, but I miss some of the manual control 
sometimes. This project made me feel better a little more in control of my OS.

That said there are cases where even a "black box" where we need to manage Debian
Repositories. Distributing packages is one of those things that I still have to
take care of even if I am using Immutable Infrastructure or if I am using Docker
Containers based on Debian/Ubuntu. The world evolved but we still need some 
components there!

**Note** that there is something that I have ignored on purpose: *PGP/GPG Signatures*!
Digital signatures are present because HTTPs is not the default transport 
protocol used. Instead, PGP/GPG increases the security for HTTP, FTP, and other 
methods to distribute files! 😎 (Does anybody remember when repositories were on
CD/DVDs?). But don't panic! This process can be automated too, just remember
to use something like [Hashicorp Vault](https://qm64.tech/images/202003-immutable-infrastructure-vault/) 
to store the secret PGP Key!

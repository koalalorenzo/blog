---
title: "Using a GitLab to maintain a custom Debian Repository"
date: 2020-07-26T20:41:28+01:00
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
  - gitlab
  - devops
  - sre
  - pipeline
thumbnail: /posts/202007/repo.gif
---

Honestly, I had the feeling that a blog post about distributing packages is
needed. In a word filled with Containers, PaaS, and SaaS, it seems weird to talk
about how we can automate the creation of Debian packages and APT repositories.
Nonetheless, even if this appears to be a forgotten step for operations, some
projects are not distributed over Debian packages, and I need them for my
Raspberry Pi!

![Debian package](/posts/202007/debian-pkg-icon.png#small)

# A little bit about distributing Debian packages

[Debian packages](https://en.wikipedia.org/wiki/Deb_%28file_format%29)
(and [APT repositories](https://en.wikipedia.org/wiki/APT_(software)) are useful
for distributing and keeping Debian-based Operative Systems up to date. Adding
software via apt install is cleaner than download binaries or using ad-hoc
processes to manage versions.

![Debian package](/posts/202007/repo.gif#center)

Not using a Debian repository is understandable: somebody has to maintain it and
keep it updated. That takes time, and it is not always easy to do: open source
software is updated every day! I think nobody likes this process as it is not
fun as writing code! So what if I write some code to do that for me and automate
the building of a repository?

# What do I want to do?
The goals for this project are:

1. Automate the building of the packages
2. Build the repository automatically as well
3. Use the GitLab CI/CD pipeline to repeat the process **periodically**.
4. Use GitLab Pages to host the static website with the repository.

# Let's do it!

In this post,  I will pack [IPFS Go binaries](https://dist.ipfs.io/#go-ipfs) in
a Debian package. Then  I will distribute this package in a repository.
This can be applied to a set of other projects that are only publishing binaries
and no package.

## Building a .deb file
Build a Debian package is a complex process, but I can automate that in
different ways. There are various articles/guides that you can find talking
about this. Since I use GitLab CI/CD pipelines, I use an Ubuntu docker container
and `dpkg-buildpackage` to build the packages.

To do that, I need to create a set of files in specific directories. To automate
this process, I am creating a "template" that scripts will modify with the
following structure:

![Debian Source file tree](/posts/202007/source-tree.png#center)

You can access the files here. Those files are defining a few things:

- The changes from one version to another
- The package details (Name, Version, Maintainer, Architecture, etc.)
- Files to install (where to decompress them)
- The system services to install.

The command in the Makefile will replace some variables like `${VERSION}` or
`${DATE}` and build the package as a whole:

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
	# Move the source here
	cp -aR build/source/go-ipfs/${ARCH}/go-ipfs build/deb/${DEB_ARCH}/ipfs-${IPFS_PKG_VERSION}/
.PHONY: _prepare_ipfs_deb
```

## Building the repository
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

Then all I have to do is to instruct the Makefile to use it to build the
database, compress it in different formats. Note that it will analyze

```makefile
repository_apt:
	cd dist; \
	apt-ftparchive -c ../Releases.conf packages apt > apt/Packages ;\
	cat apt/Packages | gzip -9c > apt/Packages.gz ;\
	bzip2 -kf apt/Packages ; \
	apt-ftparchive -c ../Releases.conf release apt > apt/Release
.PHONY: repository_apt
```

All it is left to do is instruct the Pipeline to run the commands, then upload
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

I previously configured GitLab Pages, but if you are curious, you can follow
this guide here. (Spoiler alert: change the settings, and push the `/pages`
artifacts directory 😉 )

All the source code for this is available here. You can see that I am building
more than one package. Feel free to open a PR if you want to add a new software
there!

The last thing to do is to set up a Gitlab CI/CD to run this pipeline
periodically, so that my registry will build the latest package. This
step is very easy but it is done on the website. I found this
[documentation here](https://gitlab.com/help/ci/pipelines/schedules) very useful.

# Conclusions
Building automatically packages from static binaries was fun as it "removes"
a tedious process from my daily chores 😉. Most of the PaaS and SaaS solutions
that we use to build and distribute software are moving me away from the "Ops"
part of DevOps. With the promise of simplifying, I buy into black boxes made by
big companies that will take care of "that" for me.

Distributing packages is one of those things that I still have to take care of
even if I am using Immutable Infrastructure or if I am using Docker Containers
based on Debian/Ubuntu. It is not done like 10 years ago, but it can be useful.

Note that there is something that I have ignored on purpose: *GPG Signatures*!
It is strongly suggested (if not required) to sign a few files. Digital
signatures are present because HTTPs is not the default transport protocol used.
Instead, GPG covers HTTP, FTP, and other methods to distribute files (does
anybody remember when repositories were on CD/DVDs?). But don't panic! It is a
simple process. In a pipeline, it is required to store that GPG key safely in
the env configuration or inside something like Hashicorp Vault.

Honestly speaking, I could have used [Launchpad](https://launchpad.net) to
distribute my packages... or I could have just waited
[GitLab to work on the Debian Repository](https://gitlab.com/gitlab-org/gitlab/-/issues/5835)
implementation... but I had fun anyway!
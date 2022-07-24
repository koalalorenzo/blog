---
title: "Steam Deck and Overlay FS"
date: 2022-06-21T18:05:41+01:00
tags:
  - videogames
  - steam deck
  - steam
  - linux
  - overlayfs
  - raspberrypi
  - ansible
  - immutable infrastructure
---

<!--more-->

# Immutable part
The Steam Deck uses an immutable filesystem: as deeply described in
[this article](https://www.svenknebel.de/posts/2022/5/2/), the root filesystem
is mounted as read only, while other directories are mounted as OverlayFS, and
the home directory is `read/write` allowing some persistency.

I have seen this design in the past in ChromeOS: the root directory (`/`) is
mounted as read only and user's configurations, apps and files are stored in a
different partition.

Apple also applies a similar technique with APFS Snapshots in macOS:

{{< image src="macos-utility-disk.webp" caption="macOS utility showing update snapshot mounted as read only on root">}}

# I use OverlayFS on my Raspberry Pi
In the past I have struggled a lot on upgrades that forced me to re-install
a brand new version of GNU/Linux on my device. Even if I can't fully solve it
with OverlayFS, it helps by allowing me to test some upgrades before actually
ruining my setup. A simple reboot will revert all the changes.

![](off-and-on.webp)

The way OverlayFS helps by doing something simple: don't write the changes to
disk, write them into another device, in my case write them to memory.

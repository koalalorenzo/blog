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

# OverlayFS on Raspberry Pi
In the past I have struggled a lot on upgrades that forced me to re-install
a brand new version of GNU/Linux on my device. Even if I can't fully solve it
with OverlayFS, it helps by allowing me to test some upgrades before actually
ruining my setup. A simple reboot will revert all the changes.

![](off-and-on.webp)

OverlayFS in my case does something simple: don't write the changes to
disk, write them into another device, in my case write them to memory.

To enable OverlayFS I initially followed [this guide], but since Ubuntu has
an easy to use package to enable and disable OverlayFS, I went that direction.
I wrote a simple [ansible playbook](https://gitlab.com/koalalorenzo/playbooks),
allowing me to turn it on and off on demand with a single command:

```yaml
---
- name: Turn ON OverlayFS on root
  hosts: all
  become: yes
  become_user: root
  become_method: sudo
  gather_facts: yes

  handlers:
    - name: Reboot
      reboot:
        reboot_timeout: 300
        post_reboot_delay: 30
        pre_reboot_delay: 15

  tasks:
    - name: "Install OverlayFS"
      package:
        name: overlayroot
        state: present
      when: ansible_distribution == 'Ubuntu'
      notify: Reboot

    - name: Set OverlayFS on root config (No recursive, with swap)
      lineinfile:
        path: /etc/overlayroot.conf
        regexp: '^overlayroot='
        line: 'overlayroot="tmpfs:swap=1,recurse=0"'
        state: present
      when: ansible_distribution == 'Ubuntu'
      notify: Reboot
```

This playbook installs `overlayroot` package and adds a line in
`/etc/overlayroot.conf` containing:

```bash
overlayroot="tmpfs:swap=1,recurse=0"
```

Saying that we want to write the root changes on memory, enabling swap and
preventing all the other filesystem under `/` to be mounted with the same
option recursively. This is necessary for me as my persistent data is stored
in my OpenZFS setup under `/data`.

# How the Steam Deck does it?
The decision of using read only root is a good decision for a product like the
Steam Deck. Tinkering with the OS and then running an upgrade would probably
cause bigger issues and ruining the experience as well as increase drastically
the amount of support cases.

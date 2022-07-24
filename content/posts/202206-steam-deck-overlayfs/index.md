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
A few months ago I have received my Steam Deck, the first iteration of a
super powerful portable Linux gaming console capable of running any Windows
gaming. Taken by my unresistable desire to tinker with it, I noticed that
it uses a read-only root and overlay fs to guarantee the best experience to
all the users. This is smart! So I have decided to do something similar on my
Raspbery Pi running my NAS to test upgrades before actually upgrading.

<!--more-->

{{< image src="feature.webp" class="square">}}

# The benefits of Immutalbe Infrastructure without VMs


# Not the first player
The Steam Deck uses an immutable filesystem: as deeply described in
[this article](https://www.svenknebel.de/posts/2022/5/2/), the root filesystem
is mounted as read only, while other directories are mounted as OverlayFS, and
the home directory is `read/write` allowing some persistency.

I have seen this design in Embedded Linux and in ChromeOS: the root directory
(`/`) is mounted as read only and user's configurations, apps and files are
stored in a different partition.

Apple also applies a similar technique with APFS Snapshots in macOS:

{{< image src="macos-utility-disk.webp" class="big" caption="macOS Disk Utility showing update snapshot mounted as read only on root">}}

# OverlayFS on Raspberry Pi
In the past I have struggled a lot on upgrades that forced me to re-install
a brand new version of GNU/Linux on my device. Even if I can't fully solve it
with OverlayFS, it helps by allowing me to test some upgrades before actually
ruining my setup. A simple reboot will revert all the changes.

![](off-and-on.webp)

OverlayFS in my case does something simple: don't write the changes to
disk, write them into another device, in my case write them to memory.

To enable OverlayFS I initially followed
[this page](https://raspberrypi.stackexchange.com/questions/124628/raspbian-enable-disable-overlayfs-from-terminal),
but since Ubuntu has an easy to use package to enable and disable OverlayFS,
I went that direction. I wrote a simple
[ansible playbook](https://gitlab.com/koalalorenzo/playbooks), allowing me to
turn it on and off on demand with a single command:

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
Using a read only root is a good decision for a product like the Steam Deck.
Tinkering with the Operative System and then running an upgrade will probably
cause bigger issues and ruining the user experience, as well as increase
the amount of support cases where it was just the user fault.

What I love of the Steam Deck though, is that you still can tinker with it
if you want! It is your own machine and you can still change everything about
it.

I decided to keep the settings as it is as I am highily satisfied with using
Flatpack apps and keeping my custom scripts only in the home directory.
Firefox is there, Bitwarden is there and even Emulators are there!

Using this technique, I would say that Valve applied some principles of
immutable infrastructure on bare metal OS (without VMs) and gaining all the
benefits. 👏 Good job Valve! 👏

# Go buy a Steam Deck now!
Since I got my Steam Deck I never picked up my Nintendo Switch, and most
_mouse and keyboard only_ games are super playable: Plug your mouse, keyboard
and screen (with a usb-c dongle) and you are good to go!

I am super happy with it: I never had a single issue with it that was not
fixed with a reboot. I am shocked how Wine and Proton have pushed gaming on
Linux this far. 10 years ago this would have been a dream.

I unsubscribed from Google Stadia (even though I love Google way to do Cloud
Gaming) in favor of plugging my Steam Deck to my TV. If you are undecided
[go ahead and buy one](https://steamdeck.com/)!

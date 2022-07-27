---
title: "Steam Deck and Overlay FS"
date: 2022-06-27T08:46:42+01:00
tags:
  - videogames
  - steam deck
  - linux
  - overlayfs
  - raspberry pi
  - ansible
  - immutable infrastructure
---
A few months ago, I received my Steam Deck, the super powerful portable Linux
gaming made by Valve, the company behind Steam, and capable of playing Windows
games without Windows. Taken by my irresistible desire to tinker with it, I
noticed that it uses a read-only root and overlay fs to guarantee the best
experience for all the users. This is so Smart! So I have decided to do
something similar on my Raspberry Pi running my NAS to test upgrades before
actually upgrading.

<!--more-->

{{< image src="feature.webp" class="square">}}

# The benefits of Immutable Infrastructure without VMs
After downloading a lot of games, I ventured on exploring Desktop Mode: my Steam
Deck transformed from a Gaming Console into a powerful KDE Desktop Machine.
Under Steam Deck OS, there is a fork of Arch Linux, but when I tried to run
`pacman` from the terminal to install upgrades, I ran into issues:

{{< image src="pacman.webp" class="square">}}

I already [wrote about Immutable Infrastructure]({{< ref "202003-immutable-infrastructure-vault" >}})
in the past. Valve's approach is similar and provides the same benefits: being
able to revert to a stable version of the OS after a faulty upgrade.
I could not run the upgrades manually.

I can't change things, but that is fine as the persistency is elsewhere, and the
main OS is immutable.

It is immutable because there are two partions for the root/main OS. One for the
current booted system and another one for backup. During any upgrades the
changes are applied to a different partition/snapshot and the system boots into
that one. If the boot fails, it will revert to the old partition instead.

# Not the first player
The Steam Deck uses an immutable filesystem: as deeply described in
[this article](https://www.svenknebel.de/posts/2022/5/2/), the root filesystem
(`/`) is mounted as read-only with BTRFS, while other directories are mounted
as OverlayFS, and the home directory is read/write, allowing some persistency.

I have seen this design in Embedded Linux, Andoird, and ChromeOS: the user's
configurations, apps, and files are stored in a different partition,
while the core OS is read-only.

Apple also applies a similar technique with APFS Snapshots in macOS:

{{< image src="macos-utility-disk.webp" class="big" caption="macOS Disk Utility showing update snapshot mounted as read-only on the root path">}}

# OverlayFS on Raspberry Pi
In the past, I have struggled a lot with upgrades that forced me to format and
reinstall everything from scratch. Even if I can't fully solve the issue,
OverlayFS helps by allowing me to test some upgrades before ruining my
setup: A simple reboot will revert all the changes. _How?_

![](off-and-on.webp)

OverlayFS does something simple: don't write the changes to the disk. Write them
into another device; in my case, write them to memory.

To enable OverlayFS, I initially followed
[this page](https://raspberrypi.stackexchange.com/questions/124628/raspbian-enable-disable-overlayfs-from-terminal),
but since Ubuntu has an easy-to-use package to enable and disable it,
I went in that direction. I wrote a simple
[Ansible playbook](https://gitlab.com/koalalorenzo/playbooks/-/blob/0346c468717404d7358522f7bdb839ed1f8e30a4/common/overlay-on.yaml),
allowing me to turn it on and off on demand:

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

This playbook installs the `overlayroot` package and adds a line in
`/etc/overlayroot.conf` containing:

```bash
overlayroot="tmpfs:swap=1,recurse=0"
```

_What does it do?_ Simple: Write the root changes on memory (`tmpfs`), enable
swap, and prevent all the other filesystems from being mounted as OverlayFS.
The recursive mount is disabled as I need persistency in my OpenZFS setup
mounted under a different path.

I could have used [btrfs](https://en.wikipedia.org/wiki/Btrfs) or
[OSTree](https://ostreedev.github.io/ostree/), but I did not want to complicate
too much handling snapshots. I just wanted to unplug the power and plug it back
again in case of disaster. _Maybe another post?_ 😏

# You can still install apps
Using a read-only root is a good decision for a product like the Steam Deck.
Tinkering with the Operative System and then running an upgrade will probably
cause bigger issues, ruin the user experience, and increase the number of
support cases where it was just the user's fault.

I love the Steam Deck because you can still tinker with it if you want!
It is your machine, and you can still change everything about it.

I decided to keep the settings as I am delighted with using Flatpack apps and
keeping my custom scripts only in the home directory. Firefox is there,
Bitwarden is there, and even Emulators are there!

Using this technique, I would say that Valve applied some principles of
immutable infrastructure on bare metal OS (without VMs) and gained all the
benefits.

👏 Good job, Valve! 👏

# Go buy a Steam Deck... NOW!
Since I got my Steam Deck, I never picked up my Nintendo Switch, and most
_mouse and keyboard-only_ games are super playable: Plug your mouse, keyboard
and screen (with a USB-c dongle) and you are good to go!

I am shocked how Wine and Proton have pushed gaming on Linux this far. I am
super happy with it: I never had a single issue that a reboot couldn't fix.
Ten years ago, this would have been a dream: Portable Windows games without
Windows, on Linux.

I am able to play games that I have never played because my only Operative
Systems were macOS and Gnu/Linux

I unsubscribed from Google Stadia (even though I love Google's way of doing
Cloud Gaming) in favor of plugging my Steam Deck into my TV. If you are
undecided, [go ahead and buy one](https://steamdeck.com/)!

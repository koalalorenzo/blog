---
layout: post
author: koalalorenzo
comments: true
date: 2016-08-30 12:13:10+02:00
title: "A month with Google ChromeOS"
tags:
- old blog
- software development
- chromeos
- chromebook
- google
- linux
- thoughts

---
A month ago I have ordered, as a backup device, a **Chromebook**. I was watching videos on [youtube](https://www.youtube.com/watch?v=vxqQXH2ecpI) and I have selected the **ASUS Chromebook Flip** without thinking much. It is powerful, _cute_, convertible, the screen is not _that bad_ and the keyboard is meh... you can get used to its size. The main problem was not the hardware: after a month with Google ChromeOS, as a developer, I am really disappointed. I was expecting a device to work, and instead I got something to play cat videos.

First of all **ChromeOS is not designed for developers**... and even if people are trying to sell Nitrous or Cloud9... It was not working for me. You can [not change the hostname](https://bugs.chromium.org/p/chromium/issues/detail?id=126802), you can [not browse the](https://bugs.chromium.org/p/chromium/issues/detail?id=611631) [.local/mDNS domains](https://bugs.chromium.org/p/chromium/issues/detail?id=405925). The alternative is anyway there: it is possible to switch to developer mode and install a chrooted environment (called Crouton). In this way you can use a new environment under _Google's version of the Linux kernel_ to run your code/software/distro. Sounds cool and it is, but the way it works is kinda annoying, considering that Google Chrome will be always in the background running and eating memory... to avoid or make it work better you will spend more time than actually writing code.

Install things, compile, use the termianl... this is fun... and yes, again, it is! right? not in this specific case: the ASUS Chromebook Flip uses an **ARM chip** (RocketChip) which is a pain in the ass since not everybody is providing binary ([_btw, Blockstream's Bitcoin has ARM builds now!_](https://bitcoin.org/en/release/v0.13.0#linux-arm-builds)). Instead **Intel-based** Chromebooks have more software and GNU/Linux distributions, there are more projects and are not supporting ARM (I have failed compiling both Atom and VSCode).

I have even tried to run Linux and Android Apps on the beta channel... and I got more **kernel panics** and **frustrating** problems that I have decided that this is not for me. **I need to get shit done**! Considering all the things that I have done on this device, I was just able to write this blog post, but I need to borrow a Mac to publish it :-(

I have read that people with intel-based Chromebooks are happier than me, probably that is the main issue, but the fact that [we will no-longer see an active interest in Chrome Apps](http://blog.chromium.org/2016/08/from-chrome-apps-to-web.html), the fact that we have now [Android Apps support](http://www.chromium.org/chromium-os/android-apps), shows me that ChromeOS, as we know it, **is dying as a failed project**. I wish it will get better, since for now, I can only use it to play stupid videogames, use only google products/apps and play cats videos.


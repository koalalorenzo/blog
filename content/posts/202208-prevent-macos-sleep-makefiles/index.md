---
title: "How to prevent your Mac from sleeping in a Makefile"
date: 2022-08-12T12:47:03+02:00
draft: false
tags:
  - how to
  - makefile
  - software development
---
Often I find myself using third-party software like Caffeine or Amphetamine to
keep my Mac awake while running some specific commands. Sometimes it is because
I am running backups, sometimes it is because I am compiling something.
I found out that macOS comes pre-installed with `caffeinete` command... this
post is about how to integrate it in your Makefile so that when you are running
any command there, it will prevent your Mac from sleeping!

<!--more-->

## The command: caffeinate
This command comes pre-installed in any mac 🤯 This makes my life way easier
because I would not have to [brew](https://brew.sh) anything. This is how I am
going to use it:

```bash
caffeinate -i ${COMMAND}
```
This will prevent the system from sleeping while the `${COMMAND}` is running.

I am using the `-i` flag to prevent the system from idle sleeping, while I could
also use `-d` to prevent the display from sleeping. You can get more options
from a quick check in the manual (`man caffeinate`). I prefer to allow the
display to _sleep_, so that I can save some energy.

{{< image src="man-caffeinate.feature.webp" class="big">}}


## Using it with Make
When writing a Makefile, I usually writhe commands directly. Like so:

```makefile
%.out:
	command $*
	other-command $*
```

What we could do to prevent sleep or hibernation is to use `caffeinate` before
every command, like so:

```makefile
%.out:
	caffeinate -i command $*
	caffeinate -i other-command $*
```

But this might not be good-looking... and the senior gods of the
[DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) religion might
cause your next live demo to fail! To make it better, I decided to use `SHELL`
variable so that every command will be passed to `caffeinate` and `bash`.
It will look something like this:

```makefile
SHELL := caffeinate -i bash

%.out:
	command $*
	other-command $*
```

Sadly, this Makefile will not be portable, as caffeinate is available on macOS
but not necessarily everywhere. So here is a simple condition to check if the
binary is available, and then overwrite the default shell used by Make:

```makefile
# Prevent the system from idle sleeping, only on macOS
ifeq ($(shell uname -s),Darwin)
SHELL := caffeinate -i bash
endif

%.out:
	command $*
	other-command $*
```

There is a catch though: `caffeinate` on macOS works differently than the
[package available here](https://manpages.ubuntu.com/manpages/jammy/man1/caffeinate.1.html),
and that might cause issues as the flags are different. 🤔
Therefore, instead of checking if `caffeinate` command is available like this:

```makefile
ifneq (,$(shell which caffeinate))
```

I have decided to check if the kernel/OS running is macOS/Darwin. There is space
for improvements here!

I have implemented this in my
[Ansible Playbooks](https://gitlab.com/koalalorenzo/playbooks), as I was always
finding myself struggling with having to restart commands just because I forgot
to prevent my Mac from sleeping.
Now I got it fixed with just 3 lines of code! 🥰


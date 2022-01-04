---
author: koalalorenzo
comments: true
date: 2015-04-03 17:24:37+00:00
layout: post
slug: docker-aliases-i-dont-install-tools-on-my-mac
title: 'Docker + aliases: I don''t install tools on my Mac'
wordpress_id: 18572
tags:
- old blog
- docker
- mac
- hacking
- tools
- os x
- devleop
- devops
- scale
- work
- how to

---

I really care about **keeping the OS clean** and _untouched_. Sometimes, when I have to develop using specific softwares and tools, I have to **modify** core and **important** sections of the system on my **Mac** or **PC**, and this can create some problems with **package managers** (like homebrew for Mac OS X; or like APT, pacman or yum for GNU/Linux)...

![](cover_docker.webp)

**For example**, few months ago I installed node.js on my Mac using the official package. When I started using [homebrew](http://brew.sh), I had problems with the command line and the configuration. I even had the same problem when I was not using a virtual environment with Python 2.7 and 3.4... So I was forced to fix all the files/links manually with the super user... and I don't like that: it is like corrupting my OS...<!-- more -->

Few **years ago**, I was using **chroot** and **virtual environments**, and it was really painful to configure and setup, losing time that I could spend to do other things, _like watching videos of kittens_.

**Now** instead I use **Docker** to set-up containers with the tool/comand I need without big pain (Except the first download of the appropriate container that is taking some minutes). Now, for example, to use **NodeJS** I use this command:


```shell
docker run -it --rm -v $(pwd):/pwd -w /pwd node node
```


With this command, I will create a **temporary** docker **container**, mounting the current directory into _/pwd_ and running the command _node_ from that directory... but it is not enough. I usually prefer to **replace** node **bash** **command** with the "_docker_" one. To do so I added this line at the bottom of the file in _~/.bash_profile_ to create an alias:


```shell
alias node="docker run -it --rm -v `pwd`:/pwd -w /pwd node node"
```


I've found **really useful**. During the initial run if not present Docker will **download** the image required, and after that it will be really fast. I have done the same for npm and coffeescript noticing how much this could help me to work and maintain several environments without big problems.

For this reason, I've created a [new repository on GitHub](http://github.com/koalalorenzo/docker-aliases) to collect all my aliases based on the tools I am using... and if you are using already something like that, please help me to share it with a **pull request**! :-)

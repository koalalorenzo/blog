---
title: "Apple HomeKit and Linux SystemD"
date: 2023-07-21T21:13:27+01:00
tags:
  - go
  - apps
---
If you've ever dreamt of controlling your Linux applications or running commands
directly from your iPhone, I've got some exciting news for you. I've been
tinkering around and have come up with a solution that bridges the gap between
Apple HomeKit and SystemD services. Let me introduce you to my latest creation:
[hk-svcs-bridge](https://gitlab.com/koalalorenzo/hk-svcs-bridge)...

<!-- more -->

## The Inspiration Behind the Project

The idea was born out of sheer convenience. Imagine this: you're settling down
for a movie night. With a simple command to Siri or a press of a button, the
lights dim, your Apple TV springs to life, and the Jellyfin Docker/Podman
service starts running in the background. _Sounds like magic, right?_ That's
precisely what I aimed to achieve: a Linux daemon, crafted in Go, mapping SystemD 
services and commands to Apple Home (HomeKit) buttons.

## Setting Up the hk-svcs-bridge

For those eager to integrate their Linux systems with Apple HomeKit, setting up
the `hk-svcs-bridge` is straightforward. You can directly download the
pre-compiled binaries from the [releases page on
GitLab](https://gitlab.com/koalalorenzo/hk-svcs-bridge/-/releases).  The project
supports multiple CPU architectures, ensuring compatibility with a range of
devices, including the Raspberry Pi!

For Ubuntu/Debian users, especially those using a Raspberry Pi, here's a quick
way to get started:

```bash
# Please check the GitHub Page for newer versions if those are available! 
wget https://gitlab.com/koalalorenzo/hk-svcs-bridge/-/jobs/4061805600/artifacts/file/build/hk-svcs-bridge_0.1.4-beta-0_armhf.deb
sudo apt install ./hk-svcs-bridge_0.1.4-beta-0_armhf.deb ````
```

If your device architecture isn't directly supported by the provided binaries,
don't worry! You can always compile the project from the source code, ensuring
maximum flexibility.

Once installed, you'll need to set up your configuration. Create a `config.yaml`
file and populate it with your desired settings. Here's a sample configuration:

```yaml
# Your Bridge name:
name: Home Server Pi
# The Pairing Code that you'll need to add on your iPhone
pairing_code: "42042042"

services:
- name: nginx
- name: "Media Server" 
  on_cmd: "docker start jellyfin"
  off_cmd: "docker stop jellyfin"
  check_cmd: "docker inspect --format='{{.State.Running}}' jellyfin"
```

Save this configuration to `/etc/hk-svcs-bridge.yaml`. After saving the
configuration, you'll need to restart the systemd service for the changes to
take effect:

```bash 
sudo systemctl daemon-reload 
sudo systemctl enable hk-svcs-bridge 
sudo systemctl restart hk-svcs-bridge 
```

Once you've successfully set up the hk-svcs-bridge on your Linux system,
integrating it with your iPhone is a straightforward process. Begin by opening
the Home app on your iPhone. Tap on the '+' icon located at the top right corner
and select "Add Accessory." and select the Bridge and use the
`pairing_code` to add it. 

After finishing the setup, this configuration will introduce two buttons in
the Home app: one for _NGINX_ and another for the _Media Server_.

## It was fun
The journey of creating this bridge was both challenging and rewarding. It's
always a pleasure to craft solutions that make life a tad bit easier and more
connected. If you're as excited as I am about this project, feel free to dive
into the source code and explore its potential.

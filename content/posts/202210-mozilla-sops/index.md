---
title: "How to encrypt safely your secrets"
date: 2022-10-28T9:40:48+02:00
tags:
  - secrets
  - devops
  - sre
  - security
---
Managing secrets in Git repositories has been one of the biggest issue when
I write code. In the past I have used multiple solutions to handle this but only
a few have been successfull and some have proved more complicated and costly
than expected. Recently though I have been looking for a solution that would
work and be good enough to satisfy my needs, and I discovered Mozilla SOPS.

<!-- more -->

## What I have tried in the past and did not work
When it comes to manage secrets in code on Git repositories, things might get
a little out of control. This is why when picking what solution to use I had
in mind these:

* A way to authorize multiple users for easy software developments
* Easy way to rollout or rotate the secrets
* configuration and permissions defined "as code"


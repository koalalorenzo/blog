---
title: "How to encrypt safely your secrets"
date: 2022-10-28T9:40:48+02:00
tags:
  - secrets
  - devops
  - sre
  - security
---
I recently switched from git crypt to Mozilla SOPS, on my ansible playbooks
repository for these reasons:

- Support for GPG and Yubikey
- Support for Google Cloud Platform
- Easier way to rollout secrets and rotate them
- No need for hosting services like Hashicorp Vault
- Granula permission "as code"

<!-- more -->

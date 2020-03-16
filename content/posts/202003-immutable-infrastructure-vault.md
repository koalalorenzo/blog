---
title: "Using Immutalbe Infrastructure with AWS, Terraform, Packer and Vault"
date: 2020-03-12T21:41:28+01:00
draft: true
authors:
  - Lorenzo Setale
tags:
  - hashicorp vault
  - infrastructure 
  - immutable infrastructure
  - packer
  - terraform
---

One of the most useful tools that I found and I love to keep alive is 
Hashicorp Vault. Generating most of the secrets when possible, especially when
playing with automation and with external providers, it gives a layer of 
security and reduces some risks.

Deploying such a service requires it to be always available and fully tested
before deploying a new versin. Some practices from Immutable Infrastructure 
can help to acheive this DevOps dreams.
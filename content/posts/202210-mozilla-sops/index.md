---
title: "Handling secrets when working alone"
date: 2022-10-28T9:40:48+02:00
tags:
  - secrets
  - devops
  - sre
  - security
  - Today I Leanred
---
Managing secrets in Git repositories has been one of the biggest issues when
I write code. I have used multiple solutions based on the complexity and how 
many things I have to do in case of leaks. I was looking for a solution that 
would work and be good enough for my simple Ansible Playbooks, and I stumbled
upon the Mozilla SOPS.

<!-- more -->

## What I have tried in the past and did not work this time 

Things might get out of control when it comes to managing secrets in code on
Git. Nobody wants to store secrets in plain text, so there are different tools 
for different ways of handling them. It can be a static password or API Token, 
or sometimes it is a certificate or sensitive data: we want to make sure that 
only people and workloads that are authorized and authenticated can access our 
secrets.

### For serious projects: HashiCorp Vault

My favorite way of dealing with secrets is generating them every time they are 
needed. HashiCorp Vault is a perfect cloud-agnostic tool for that! It ensures 
TTL, Authorization and Authentication even when Cloud Providers or tools can't 
provide it (ex: Databases, Service Account tokens) and has a nice way to deal 
with authentication and authorization.

Vault is simple enough, but an overkill for projects like mine. In my case, I 
am using some basic  Ansible Playbooks, and have a Vault instance available at 
any time just for a personal script is a bad idea: It is a slippery slope to 
wasting time maintaining, upgrading and safeguarding a server for something 
that can be simplified. When working alone, HashiCorp  Vault can be over 
engineering and I would prefer to use something simpler like git-crypt.

### For local only: git crypt
A way that I have explored in the past was with git-crypt. It is a smart way to
encrypt and decrypt a file: It uses GPG/PGP keys and git filters to 
transparently manage secrets. Once initialize, it feels like if it is not 
there: files are stored locally in plain text, and encrypted right before 
commits.

With git crypt, could argue that the files are encrypted and safe in the 
history, but if the encryption keys are compromised, any effort to keep 
everything safe is valiant. 

One of this limit is that it works only with a static encryption key or GPG 
Keys. All of those are not good when it comes to automation, as they require 
tools to have static and long-living keys lying around: For example, using it in
GitHub Action might require you to create a static GPG Key dedicated for the 
workflow and that is a pain to deal with… In that case, we need something more 
complex, like HashiCorp Vault… or other cloud solutions.

### Best of all: Mozilla SOPS
You might be saying: Hey, there is an infinite loop in your blog post! This is 
the paragraph where we break that loop and share something that sits in the 
middle between git-crypt and HashiCorp Vault.

Mozilla SOPS sits in the middle. The way it works is similar to git-crypt, but 
the data is encrypted and stored in a way so that multiple entities can decrypt, 
including PGP Keys, HashiCorp Vault, age, and Cloud KMS solutions.

Every file will be encrypted with its key, and keys can be rotated if needed 
(though remember the old version will stay in git history!). The file will not 
be decrypted like git-crypt does out of the box, and some scripting might be 
needed.

It works better than expected. It easily works with GPG with my YubiKey: 
Ansible automatically decrypts the files required when my key is in my Mac. 
When it comes to integrating it with GitHub or GitLab, it can be glued together 
with HashiCorp Vault or any Cloud KMS solution (there are plenty of docs)

## Mozilla SOPS and Ansible
Mozilla SOPS and Ansible
On macOS, installing it is easier than expected and setting it up is also super 
straightforward:

```bash
brew install sops
```


---
title: "Handling Secrets should not be complicated: Mozilla SOPS"
date: 2022-11-30T09:22:48+02:00
tags:
  - secrets
  - devops
  - sre
  - security
  - Today I Learned
mermaid: true
---
Managing secrets in Git repositories has been one of the biggest issues when
I write code. I have used multiple solutions based on the complexity and how
many things I have to do in case of leaks. I was looking for a solution that
would work and be good enough for my simple Ansible Playbooks, and I stumbled
upon the Mozilla SOPS: something that makes handling secrets not complicated
when working alone on simple projects.

<!--more-->

## What I have tried in the past and didn't work this time

Things might get out of control when it comes to managing secrets in code on
Git. Nobody wants to store secrets in plain text, so there are different tools
for different ways of handling them. It can be a static password or API Token,
or sometimes it is a certificate or sensitive data: we want to make sure that
only people and workloads that are authorized and authenticated can access our
secrets.

### For serious projects: HashiCorp Vault

My favorite way of dealing with secrets is generating them every time they are
needed. [HashiCorp Vault]({{< ref "202003-immutable-infrastructure-vault" >}})
is a perfect cloud-agnostic tool for that! It ensures  TTL, Authorization and
Authentication even when Cloud Providers or tools can't provide it (ex:
Databases, Service Account tokens) and has a nice way to deal with
authentication and authorization.

Vault is simple enough, but an overkill for projects like mine. In my case, I
am using some basic  Ansible Playbooks, and have a Vault instance available at
any time just for a personal script is a bad idea: It is a slippery slope to
wasting time maintaining, upgrading and safeguarding a server for something
that can be simplified. When working alone, HashiCorp  Vault can be over
engineering and I would prefer to use something simpler like git-crypt.

### For local only: git crypt
A way that I have explored in the past was with
[git-crypt](https://github.com/AGWA/git-crypt).  It is a smart way to encrypt
and decrypt a file: It uses GPG/PGP keys and git filters to transparently
manage secrets. Once initialize, it feels like if it is not there: files are
stored locally in plain text, and encrypted right before commits.

With git-crypt, could argue that the files are encrypted and safe in the
history, but if the encryption keys are compromised, any effort to keep
everything safe is valiant. The reason is that git-crypt uses GPG keys to
share a common encription key used to encrypt everything it tracks:

{{< mermaid >}}
graph TD
    C[Clear File]
    GPG1[GPG Key 1]
    GPG2[GPG Key 2]
    EK[static encription key]
    E[Encrypted File]

    C ---> git-crypt
    git-crypt --> E

    GPG1 --Decrypts--> EK
    GPG2 --Decrypts--> EK
    EK --Used to encrypt--> git-crypt
{{< /mermaid >}}

One of the limits is that it works only with a static encryption key or GPG
Keys. All of those are not good when it comes to automation, as they require
tools to have static and long-living keys lying around. For example, using it in
GitHub Action might require you to create a static GPG Key dedicated for the
workflow and that is a pain to deal with! In that case we need something more
complex, like HashiCorp Vault… or other cloud solutions.

### Best of all: Mozilla SOPS
You might be saying: _Hey, there is an infinite loop in your blog post: don't use
Vault, use git-crypt; don't use git-crypt use vault!_ :laughing:
This is the paragraph where we break that loop and share something that sits in the
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
I use [Ansible](https://www.ansible.com) with countless variables to configure
and populate files and settings. Ansible can load these variables from an
encrypted SOPS file.

On macOS, installing it is easier than expected and setting it up is also super
straightforward:

```bash
brew install sops
```

There are plenty of ways to install it on Linux too in the
[official docs](https://github.com/mozilla/sops#download). You can then add
your GPG/PGP Keys to the `.sops.yaml` file in the root of your repository like
this:

```yaml
creation_rules:
  - pgp: "73880ECAF69EC2ED44CE5889502BFB12D0B5295F"
````

where `73880ECAF69EC2ED44CE5889502BFB12D0B5295F` is the PGP Key Fingerprint that
will be used to encrypt. You can also add other keys
[from different solutions](https://github.com/mozilla/sops#using-sops-yaml-conf-to-select-kms-pgp-for-new-files),
including a transit key from Hashicorp Vault, AWS KMS, or GCP KMS. :muscle:
The file (or the YAML values) are encrypted multiple times with each key/tool
provided:

{{< mermaid >}}
graph TD
    C[Clear File]
    GPG[GPG Key]
    SOPS
    KMS
    V[Hashicorp Vault]
    E[Encrypted File]

    C ---> SOPS
    SOPS --> E
    GPG --> SOPS
    KMS --> SOPS
    V --> SOPS
{{< /mermaid >}}

Then you can create a new YAML file containing the variables that we can use in
our playbooks with this command:

```bash
sops filename.sops.yaml
```

It will open an editor where you can set your key: value that will be loaded as
variables. You can use this command also to edit in the future as long as you
have access to a way to decrypt the file.

{{< image src="mozilla-sops.feature.webp" class="big">}}

After that, You can load the SOPS file and use the values as
variables with
[community.sops.load_vars](https://docs.ansible.com/ansible/latest/collections/community/sops/load_vars_module.html)
and use them in the Ansible playbook like this:

```yaml
tasks:
  - name: Load encrypted credentials
    community.sops.load_vars:
      file: filename.sops.yaml
  - name: Print the secret value
    ansible.builtin.debug:
      msg: "Secret value is {{ lumpy_space_password }}"
```

When your playbook will run, Ansible will try to decrypt based on the available
methods. In my case, it will prompt my PIN code for my YubiKey to decrypt the
secrets using GPG.

I strongly suggest to read the
[README file](https://github.com/mozilla/sops#readme)
for more information on how to use it with binary files, how to rotate keys
and integrating it with different software. :wink: I really believe that this
little software written in Go makes managing secrets less complicated

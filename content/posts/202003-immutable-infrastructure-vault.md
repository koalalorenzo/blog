---
title: "Exploring Immutalbe Infrastructure"
date: 2020-03-12T21:41:28+01:00
draft: false
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
security and reduces some risks. Deploying such a service requires it to be 
always available and fully tested before deploying a new versin. I am 
investigating to know if Immutable Infrastructure is the key to make this possible.

![Hashicorp Vault Logo](/posts/202003/vault-logo.svg#center)

I have shared here the git repository with some explaination and examples. 
It is ready for usage but I strongly suggest to go through the comments and the 
code before running commands.

## The goals

My goals for this project are basic and could be extended to almost any 
workload. I want to explore Immutable  Infrastructure to make sure that:

* The VMs have better security
* The configuration is always correct (no drifts)
* Humans are not involved for most of the things (so no _human errors_[^human-error]) 
* There is no or very limited downtime during upgrades [^downtime-unseal]
* Scaling is easy and automated [^aws-kms]

Using immutable infrastructure brings also other benefits and requires a 
different mindset compared to classic Ops methodologies, but for now I will
focus only on these benefits as goals for the project.

[^downtime-unseal]: Due to the nature of Vault, we need to unseal it manually. 
The service will be reacable but the secrets will be locked. This can be 
automated[^aws-kms] with no downtimes

[^human-error]: Unless the human error is written down as a script 😅

[^aws-kms]: Vault requires some manual operation (unsealing). anyway it is 
possible to explore a feature that will 
[automatically unseal by using AWS KMS](https://learn.hashicorp.com/vault/operations/ops-autounseal-aws-kms) 
(or similar on GPC / Azure) Due to time constraints I am not exploring this 
feature that is required for autoscaling. In anycase if this was a simpler 
project it would have not been a problem

## A little about Immutable Infrastructure
_If you are familiar with docker containers on k8s this will be easy!_ 😜 

One of the biggest DevOps concepts that I have fell in love is _Pets VS Cattle_.
Shortly the is that instead of maintaining machines alive (as Pets 🐶), and 
upgrading them constantly, VMs are killed **periodically** and replaced with new 
updated versions (like cattle 🐮).

![Photo by Annie Spratt](/posts/202003/annie-spratt-cows.jpg#center)

I believe that Immutable Infrastructure starts from there and expands it a 
little by **forcing VMs to be stateless**, and limiting 
_if not forbidding_, changes to these machines (ex: No SSH, No human error).

Basically servers are never modified after they are deployed. If there are 
errors or changes to be applied, a new VM Image is created, tested and then 
it will replace the old one. Load balancers and blue/green deployments can 
help to reduce or avoid any the downtime.

## The process

The first thing I want to start working on is building the images. To keep this 
cloud agnostic I am using Packer and Ansible. Then we will deploy on
AWS (as an exmaple) the image using Terraform. We will use Cloudflare to manage
the DNS records. 

After the deployment is done Vault needs to be initialized, this is one-time
process that is done manually and we will ignore. Note that the repository
contains also some terraform configuration for Vault's internal configuration
used by Qm64. For the post-deploy procedure I strongly suggest to read 
[Vault's official documentation](https://learn.hashicorp.com/vault/getting-started/deploy#initializing-the-vault)

### Building the image

Building the images is quiet easy, but it requires some attention: this is
an automated process that forces me to **not include any secret or specific 
configuration**. Since this image can be deployed multiple times at the same 
time, it can't be tailored to as if it was a _pet_. 

If you follow the instruction on the [README file]() you will build an Image 
(make a new AWS AMI) that is ready to be deployed, but you can use alos other
providers.

```shell
cd ./packer/
make build -e BUILD_PLATFORM=amazon-ebs
```

This will call Packer and create a temporary VM on AWS, it will be used to run
some ansible playbooks against it and install Vault. After that it will stop
the machine, create a snapshot and AMI and then terminate the VM.
Once it is done it will output the AWS AMI (or image name based on the platform) 
that we will use on the next step.

### Deploying Vault

For this step I have decided to use Terraform


### Vault Setup


## Conclusion

While exploring it, I have discovered that some of these goals are actually
harder than I thoguht. The process required a lot of tools, but after a little 
the beneifts are clear and I will keep using this to deploy Nomad, Consul and 
other components. This is for sure an SRE or DevOps project as it requires more
infrastructure knowledge and tools that are not required by developers, even if 
this gives space to deploy VMs instead of docker containers.

As a result, I am running a Qm64's instance of Hashicorp Vault, that allows
me to publicly expose the repository and remove every secret from the code.

I could have simplified it, I might in the future but
due to time constraints I limited myself to not implementing some features:

* Auto unseal[^aws-kms] and a Cluster setup you gain:
   * ability to autoscale the Vault cluster if needed
   * No human required to unseal vault
* Load balancer to reduce downtime instead of relying on DNS propagation
* Cloud Agnostic: we can build multiple platform at the same time for a real 
  solution that is not vendor locked and maybe also multi cloud.
* Rollback: I wanted to make an example to rollback to a previous version in
  case something goes wrong while upgrading to a new AMI/Image.


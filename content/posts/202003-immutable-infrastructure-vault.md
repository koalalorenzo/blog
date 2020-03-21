---
title: "Exploring Immutalbe Infrastructure with Vault"
date: 2020-03-12T21:41:28+01:00
draft: false
authors:
  - Lorenzo Setale
tags:
  - hashicorp vault
  - infrastructure 
  - immutable infrastructure
  - packer
  - infrastructure as code
  - terraform
---

During the last year I have been curious about Immutable Infrastucture.
After researching I have been applying some of these concept already to 
stateless docker containers, and I wanted to make a practical project with it. 
So I thought about exploring Immutable Infrastructure with [Hashicorp Vault](https://www.vaultproject.io).

![Hashicorp Vault Logo](/posts/202003/vault-logo.svg#center)

I have shared a [git repository](https://gitlab.com/Qm64/vault/-/tree/blogpost-202003-immutable-infra) 
with some explaination and examples. It is not ready for usage and I strongly 
suggest to go through the comments and the code before running commands!

## The goals
Vault is one of those services that you don't want to run in a workload that 
can saturate the CPU usage: you need it to be in its own safe and protected
VM. For this reason I believe it is one of the perfect candidates to explore
Immutable Infrastructure.

My goals for this project are basic and could be extended to almost any 
service/project. I want to explore Immutable  Infrastructure to make sure that:

* The Virtual Machine has a reduced attack surface
* The Virtual Machine doesn't have more workloads/services (it runs just Vault)
* The configuration is always correct (no drifts between machines)
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
_If you are familiar with stateless workloads on docker/k8s this will be easy!_ 😜 

One of the biggest DevOps concepts that I fell in love  with is _Pets VS Cattle_.
Shortly the is that instead of maintaining machines alive (as Pets 🐶), and 
upgrading them constantly, VMs are killed **periodically** and replaced with new 
updated versions (like cattle 🐮).

![Photo by Annie Spratt](/posts/202003/annie-spratt-cows.jpg#center)

I believe that Immutable Infrastructure starts from there and expands it a 
little by **forcing VMs to be stateless**, and limiting 
_if not forbidding_, changes to these machines (ex: No SSH, No human error).

![Immutable infrastucture](/posts/202003/ii.gif#center)

Basically servers are **never modified** after they are deployed. If there are 
errors or changes to be applied, a new VM Image is created, tested and then 
it will replace the old one[^bluegreen]. 

[^bluegreen]: This allow [Blue/Green deployments](https://en.wikipedia.org/wiki/Blue-green_deployment) 
even with VM and can help to reduce or avoid any the downtime.

## The process

The first thing I want to start working on is building the images. To keep this 
cloud agnostic I am using [Packer](https://packer.io) and 
[Ansible](https://ansible.com). Then I will deploy on AWS (as an exmaple) the 
image using [Terraform](https://terraform.io) and Cloud-Init to apply the 
initial configuration. We will use Cloudflare to manage the DNS records. 

_Note 1_: To ease most of the process I am using `make` (GNU Make) __a lot__, 
the main reason is that I can standardize the commands that I manually run during 
development with the one that are executed by Gitlab CI/CD pipeline.
Please have a look at the `Makefile`s to learn more!

_Note 2_: After the deployment is done Vault needs to be initialized, this is 
one-time process that is done manually and I will ignore. The repository I am sharing
contains also some terraform configuration for Vault's internal setup
used by Qm64. For the post-deploy procedure I strongly suggest to read 
[Vault's official documentation](https://learn.hashicorp.com/vault/getting-started/deploy#initializing-the-vault)

### Building the image

Building the images is quiet easy, but it requires some attention: this is
an automated process that forces me to **not include any secret or specific 
configuration**. Since this image can be deployed multiple times at the same 
time, it can't be tailored with a specific setup/IP/certificate as if it 
was a _pet_. 

To build the image Packer needs AWS credentials set up. As this process should 
be both automated as well manual (at least at the beginning). I am passing 
credentials via enviromental variables so that Make can use the one in my env
or if not present, it will generate the credentials using Vault (if deployed already).
Read more about the [env variables used by packer here](https://packer.io/docs/builders/amazon.html#environment-variables).

As described in the [README file](https://gitlab.com/Qm64/vault/-/tree/blogpost-202003-immutable-infra#packer-setup) 
I am able to build the image (AMI) by running:

```shell
make -c packer validate build -e BUILD_PLATFORM=amazon-ebs
```

This will call Packer and create a temporary EC2 Instance/VM, it will be used to 
run [some Ansible playbooks](https://gitlab.com/Qm64/vault/-/tree/blogpost-202003-immutable-infra/packer%2Fansible) 
in it and install Vault service. 

![Hashicorp Vault Logo](/posts/202003/packer.png#center)

After that it will stop the machine, create a snapshot and AMI and then 
terminate the instance. Once it is done it will output the AWS 
AMI (or image name based on the platform)  that we will use on the next step.

### Deploying Vault

For this step I have decided to use [Terraform](https://terraform.io). I could 
have manually implemented it or written a bunch of bash scripts with AWS CLI, 
but I want to keep this example cloud-agnostic. This steps requires a little 
knowledge related to terraform, please read the [official documentation](https://learn.hashicorp.com/terraform)
if you are not familiar with it.

Terraform needs some credentials and even in this case the current makefile is 
designed to work with both CLI and GitLab Pipeline, so it automatically gets 
the credentials via Vault[^chicken-egg] 😅. 
Since we don't have Vault deployed yet, we can pass the env variables manually. 
Please read the 
[README file](https://gitlab.com/Qm64/vault/-/tree/blogpost-202003-immutable-infra#before-we-start-about-credentials) 
to know more about this.

Terraform will require the AMI ID. we can provide it via variables (env var too): 
this could allow me to "chain" Packer with Terraform[^not-enough-time] or
simply to specify the Image (AMI) to use on the fly. 

[^not-enough-time]: But I was running out of time to do it 😅

For example the following command will show a planning to deploy `ami-0894b635d1bd24710`
image:

```shell
make -C infrastructure plan -e TF_VAR_vault_ami=ami-0894b635d1bd24710
```

This will just validate the current setup and show what will happen in AWS and 
Cloudflare if we apply the changes. Please refer to the source code and the
[README file](https://gitlab.com/Qm64/vault/-/tree/blogpost-202003-immutable-infra/infrastructure) 
to know more about this setup

### Deploying a new version

If we find out that there is an outdated kernel version or that there is a new
Vault version, what we need to do is to rebuild the image. For example:

```shell
make -c packer validate build -e BUILD_PLATFORM=amazon-ebs -e VAULT_VERSION=1.3.3
```

This will create a new image with vault 1.3.3 and the OS upgraded. Then we can 
use the image ID in Terraform and use workspaces to test it in a different 
environment to make sure it works. If we feel safe we can then deploy it:

```shell
make -C infrastructure plan -e TF_VAR_vault_ami=ami-01742db1d536b4980
```

I have noticed that this could cause some downtime, but I have built the 
terraform setup so that even witout a load balancer, it ensures that the
old VM is destroyed only when the new one is ready. 

If something seems broken, I can always re-deploy to the previous image and
rollback to the old version:

```shell
make -C infrastructure plan -e TF_VAR_vault_ami=ami-0894b635d1bd24710
```

## Automation
Due to lack of time I was able to automate using GitLab CI/CD Pipelines a set 
of tools and not being able to chain them.

For exmaple, I made possible to have the terraform setup automated so that 
after a Pull Request it will apply the changes. The Packer setup should
be automated to build periodically a new image so that Terraform can 
automagically [fillter the AMI IDs](https://www.terraform.io/docs/providers/aws/d/ami_ids.html#example-usage) 
and find the latest one[^not-enough-time].

## Conclusion
Is it worth it? **YES**, but not for every workload. 

I would use Immutable Infrastructure to deploy kuberentes minions, Nomad clients 
or Cockroach nodes, but afther this I will not replace docker containers with
VMs! The main reason is that it is not scaling quickly as when scaling 
vertically. Running upgrades of a full OS is defenetively way less efficient 
than simply upgrading to a different docker container. I would use Immutable 
Infrastructure to deploy Hosts of multi-tenants platforms, so that the services 
can scale vertically with a scheduler while the hosts can scale horizontally 
with the cloud provider and reduce downtimes.

While exploring it, I have discovered that some of my goals are actually
harder without IaC tools. The process required a lot of them, but after a little 
the beneifts are clear and I will keep using this to deploy and maintain Nomad, 
Consul and other components. I see SREs and DevOps Engineers having their life
simplified by using Immutable Infrastucture.

As a result, I have decided to keep running a Qm64's instance of Hashicorp Vault
this way. It allows me to publicly expose the repository and remove every secret 
from the code, and gives me a little more safety as I know nobody can SSH into it!

Honestly, I could have simplified it, I might in the future but
due to time constraints I limited myself to not implementing some features:

- Auto unseal[^aws-kms] and a Cluster setup you gain:
   - ability to autoscale the Vault cluster if needed
   - No human required to unseal vault
- Load balancer to reduce downtime instead of relying on DNS propagation
- Cloud Agnostic: we can build multiple platform at the same time for a real 
  solution that is not vendor locked and maybe also multi cloud.
- Rollback: I wanted to make an example to rollback to a previous version in
  case something goes wrong while upgrading to a new AMI/Image.


---
title: "Exploring Immutable Infrastructure with Vault"
date: 2020-03-21T13:41:28+01:00
draft: false
tags:
  - hashicorp
  - vault
  - infrastructure
  - immutable infrastructure
  - packer
  - infrastructure as code
  - terraform
  - gitlab
  - devops
  - SRE
---

During the last year, I have been curious about Immutable Infrastructure.
After researching, I noticed that I had been applying some of these concepts
already to stateless Docker containers, and I wanted to do a practical
project with it. So I thought about exploring Immutable Infrastructure and use
it to deploy [Hashicorp Vault](https://www.vaultproject.io). 
<!--more-->

{{< figure src="vault-logo.svg" caption="Hashicorp Vault Logo" class="center noborder">}}

I have shared a [git repository](https://gitlab.com/Qm64/vault/-/tree/blogpost-202003-immutable-infra)
with some explanation and examples. It is written with Qm64's needs in mind
and I strongly suggest to go through the comments, and the code before running
commands!

## A little about Immutable Infrastructure
_If you are familiar with stateless workloads on docker/k8s this will be easy!_ 😜

One of the most prominent concepts that I fell in love with is _Pets VS Cattle_.
Shortly the idea is that instead of maintaining machines alive (as Pets 🐶), and
upgrading them constantly, VMs are killed **periodically** and replaced with new
updated versions (like cattle 🐮 we don't care about them too much).

{{< figure src="cows.webp" class="center">}}

I believe that Immutable Infrastructure starts from there and expands it a
little by **forcing VMs to be stateless** and limiting,
_if not forbidding_, changes to these machines (ex: No SSH = way fewer changes).

{{< figure src="animated-immutable.webp" caption="Immutable Infrastructure" class="center">}}

Very basically, **servers are never modified** after they are deployed. If there
are errors or changes to be applied, a new VM Image is created, tested and then
it will replace the old one[^bluegreen].

[^bluegreen]: This allows [Blue/Green deployments](https://en.wikipedia.org/wiki/Blue-green_deployment)
  even with VM and can help to reduce or avoid any downtime.

## The goals
Vault is one of those services that you don't want to run in an environment that
has any other process: you need it to be in its own safe and protected
VM. For this reason I believe it is one of the perfect candidates to explore
Immutable Infrastructure and to move it out from docker.

My goals for this project are basic and could be extended to almost any
service/project. I want to explore Immutable Infrastructure to make sure that:

* The Virtual Machine has a reduced attack surface
* The VM doesn't have more workloads/services (it runs just Vault)
* I can test the VM before deploying it in production
* I can rollback quickly to previous versions when needed
* Humans are not involved for most of the things[^unseal] (so no _human errors_[^human-error] )
* ~~Scaling is easy and automated~~ [^aws-kms]

Using immutable infrastructure also brings other benefits and requires a
different mindset compared to "older Operations" methodologies. Still for now I
will focus only on these benefits as goals for the project.

[^unseal]: Due to the nature of Vault, we need to unseal it manually.
The service will be reachable but the secrets will be locked. This can be
automated[^aws-kms] ideally with a KMS solution.

[^human-error]: Unless the human error is written down as a script. 😅

[^aws-kms]: Vault requires some manual operation (unsealing). anyway it is
possible to explore a feature that will
[automatically unseal by using AWS KMS](https://learn.hashicorp.com/vault/operations/ops-autounseal-aws-kms)
(or similar on GPC / Azure) Due to time constraints, I am not exploring this
feature that is needed for autoscaling. In any case if this was a simpler
project it would have not been a problem.

## The process

The first thing I want to start working on is building the images. To keep this
cloud-agnostic I am using [Packer](https://packer.io) and
[Ansible](https://ansible.com). Then I will deploy on AWS (as an example) the
image using [Terraform](https://terraform.io) and Cloud-Init to apply the
initial configuration. We will use Cloudflare to manage the DNS records.

**Note 1**: To ease most of the process I am using `make` (GNU Make) __a lot__,
the main reason is that I can standardize the commands that I manually run
during development with the one that is executed by Gitlab CI/CD pipeline.
Please [read this to learn more](https://gitlab.com/Qm64/vault/-/tree/blogpost-202003-immutable-infra#before-we-start-about-credentials)!

**Note 2**: After the deployment is done, Vault needs to be initialized, this is
a one-time process that is done manually and I will ignore it. The repository I
am sharing contains also some terraform configuration for Vault's internal setup
used by Qm64. For the post-deploy procedure I strongly suggest to read
[Vault's official documentation](https://learn.hashicorp.com/vault/getting-started/deploy#initializing-the-vault)

### Building the image

Building the images is quite easy, but it requires some attention: this is
an automated process that forces me to **not include any secret or specific
configuration**. Since this image can be deployed multiple times at the same
time, it can't be tailored with a specific setup/IP/certificate as if it
was a _pet_.

To build the image Packer needs AWS credentials set up. This process can
be both automated as well manual (at least at the beginning). I am passing
credentials via environmental variables so that Make can use the one in my env
or if not present, it will generate the credentials using Vault (if deployed already).
Read more about the [env variables used by packer here](https://packer.io/docs/builders/amazon.html#environment-variables).

As described in the [README file](https://gitlab.com/Qm64/vault/-/tree/blogpost-202003-immutable-infra#packer-setup)
I am able to build the image (AMI) by running:

```shell
make -c packer validate build \
     -e BUILD_PLATFORM=amazon-ebs
```

This will call Packer and create a temporary EC2 Instance/VM, it will be used to
run [some Ansible playbooks](https://gitlab.com/Qm64/vault/-/tree/blogpost-202003-immutable-infra/packer%2Fansible)
in it and install Vault service.


{{< image src="packer.webp" caption="Packer building an instance on AWS" class="center">}}

After that, it will stop the AWS EC3 instance, create a snapshot and AMI and
then terminate it. Once it is done it will output the AWS
AMI (or image name, depending on the platform)  that we will use on the next step.

### Configuring and Deploying Images/Cattle
This is the core of the concept behind Immutable Infrastructure: Deploying
things! _Hurray!_ I am going to make the image/cattle _pretty_ usable! 🤣

{{< figure src="pretty_cattle.webp" caption="Example of a pretty usable cattle" class="center">}}

For this step I have decided to use [Terraform](https://terraform.io). I could
have manually implemented it or written a bunch of bash scripts with AWS CLI,
but I want to keep this example cloud-agnostic. This step requires a little
knowledge related to terraform, please read the [official documentation](https://learn.hashicorp.com/terraform)
if you are not familiar with it.

Terraform will require the AMI ID we created before. I can provide it via
variables (env var too): this could allow me to "chain" Packer with Terraform[^not-enough-time] or
simply to specify the Image (AMI) to use on the fly.

[^not-enough-time]: But I was running out of time to do it 😅 (Or maybe I am
  just lazy)

For example, the following command will show planning to deploy
`ami-0894b635d1bd24710` image:

```shell
make -C infrastructure plan
     -e TF_VAR_vault_ami=ami-0894b635d1bd24710
```

This will just validate the current setup and show what will happen in AWS and
Cloudflare if we apply the changes. Please refer to the source code and the
[README file](https://gitlab.com/Qm64/vault/-/tree/blogpost-202003-immutable-infra/infrastructure)
to know more about this setup

_What about configuration?_ Well, 😏 I have decided to inject the configuration
using [Terraform templates](https://www.terraform.io/docs/providers/template/d/cloudinit_config.html)
and [Cloud-init](https://cloud-init.io).

In this way, I can instruct Vault to point to the right S3 bucket or to use the
right domain, as well as to generate SSL certificates only on deploy time. 🔑
I am using an IAM Profile generated by Terraform to allow the EC2 instance to
read the s3 bucket without dealing with  keys and permissions or writing secrets
into Vault's configuration files. 😍 _I found this step the coolest part!!!_

### Deploying a new version
If we find out that there is an outdated kernel version or that there is a new
Vault version, what we need to do is to rebuild the image. For example:

```shell
make -C packer validate build \
     -e BUILD_PLATFORM=amazon-ebs \
     -e VAULT_VERSION=1.3.3
```

This will create a new image with Vault v1.3.3 and the OS upgraded. Then we can
use the image ID in Terraform and use workspaces to test it in a different
environment to make sure it works. If we feel safe we can then deploy it:

```shell
make -C infrastructure plan \
     -e TF_VAR_vault_ami=ami-01742db1d536b4980
```

I have noticed that this could cause minimal downtime, but I have built the
terraform setup so that even without a load balancer, it ensures that the
old VM is destroyed only when the new one is ready[^not-enough-time]. 🙃

If something seems broken, I can always re-deploy to the previous image and
rollback to the old version:

```shell
make -C infrastructure plan \
     -e TF_VAR_vault_ami=ami-0894b635d1bd24710
```

## Automation with GitLab
Due to lack of time I was able to automate using GitLab CI/CD Pipelines a set
of tools and not being able to chain them.

For example, it is possible to have the Pipeline automated so that after a
Merge Request is created, terraform will apply the changes to a new environment.
The Packer setup can be automated to build a new image periodically so that
Terraform can automagically
[fillter the AMI IDs](https://www.terraform.io/docs/providers/aws/d/ami_ids.html#example-usage)
and find the latest one[^not-enough-time].

The current automation takes care of renewing a Vault token that has specific
policies for GitLab CI/CD public pipeline runners, but every month it can build
a new Vault AMI _automagically_.

## Conclusion
Is it worth it? Have I achieved the goals? **YES** 🤔

The VM has limited attack surface by limiting the access to it as well as
locking it down as much as possible. I can test and validate new versions
and rollback to the previous version anytime if I need to. This is perfect for Vault!

Should I start using Immutable Infrastructure everywhere? _Maybe_...

I would use Immutable Infrastructure to deploy Kubernetes minions, Nomad clients
or Cockroach nodes, but after this I will not replace docker containers with
VMs! The main reason is that it is not scaling quickly as when scaling
vertically. Running upgrades of a full OS is definitely way less efficient
than simply upgrading to a different docker container. I would use Immutable
Infrastructure to deploy Hosts of multi-tenants platforms so that the services
can scale vertically with a scheduler while the hosts can scale horizontally
with the cloud provider and reduce downtimes.

While exploring it, I have discovered that some of my goals are actually
harder without IaC tools. The process _requires_ automation, but after a little,
the benefits are clear, and I will keep using this to deploy services when
required but not always. I see SREs and DevOps Engineers having their life
simplified by using Immutable Infrastructure on their platforms but not more than
that.

{{< figure src="mission_accomplished.webp" class="center">}}

That said, I think I learned what is really important: prevent humans from
making mistakes by automating the hell out of it. 🤪

## Useful links
If you want to explore more, you can read the following articles:

- [What is Mutable vs. Immutable Infrastructure?](https://www.hashicorp.com/resources/what-is-mutable-vs-immutable-infrastructure) by Hashicorp
- [Why should I build Immutable Infrastructure?](https://blog.codeship.com/immutable-infrastructure/) by CodeShip
- [What Is Immutable Infrastructure](https://www.digitalocean.com/community/tutorials/what-is-immutable-infrastructure) by DigitalOcean

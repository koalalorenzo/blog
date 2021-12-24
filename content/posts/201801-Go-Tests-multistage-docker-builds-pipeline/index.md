---
layout: post
author: koalalorenzo
comments: true
date: 2018-01-06 16:15:30+02:00
title: "Go tests, multistage docker builds, pipeline"
categories:
- Thoughts
- Work
- How To
tags:
- old blog
- coding
- software development
- continuous integration
- develop
- GitLab
- pipeline
- testing
- docker
- go
images: ["/images/202011/gopherswrench.webp"]
thumbnail: /images/202011/gopherswrench.webp
---
During the last year I have learned how important it is to build, test and
deploy using always the same docker container as well as reducing its size.
As I have not  found anything online, I want to remember and share it: I am
testing my go packages with a multistage docker build inside my pipeline on
GitLab. <!-- more -->

## The odd way of testing go docker containers
Especially when implementing CI best practices, I have seen projects running
tests in different ways:

1. Before building 😨
2. When building the container  🙄
3. After building 😅

Being kind: there is no right nor wrong approach *Lorenzo*, but as the project
grows you need to run different kind of tests, not just unit tests. This leads
to run some containers together, spinning up dependencies *etc etc*.  *Remember
that thing called “micro services”?*

The lazy inner developer hidden in me, is always trying to run all the tests
when building the containers... and the other lazy one instead, decides to add
binaries together with the source code, so that this container can be tested
during a second task of our pipeline... but no, this is not optimal.

Adding the vendor directory, the source code and all the tests into your
container is not what I would suggest to do. The result is a big container, and
the risk source code exposure. We can avoid that! 😎

## Building binaries and tests
Luckily for me, we can build “binaries” for go packages... I mean, **test
binaries**. It works like this:

```bash
go test -c ./package
```

This will create a new binary file called `./package.test` and guess what it
does? Just run it and see it yourself... (*Spoiler: the binary runs the tests*)

I strongly suggest to **repeat this command in a script** for each of the
packages. This will create multiple testing binaries but it will help a lot to
ensure granularity over your tests. It is also possible to split the code with
unit tests and integration tests by [using build tags](https://stackoverflow.com/questions/25965584/separating-unit-tests-and-integration-tests-in-go).

## Multistage magic
Well, once you have your tests compiled you can run them in different steps in
a docker container.  (remember about integration and unit tests?)  🧐  Since we
don’t need anymore the source code we will use [multistage builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/).
Let me show you my *amazing* Docker file:

```Dockerfile
FROM go:alpine as builder
...
COPY . .
# build a package tests (maybe do more than one in a script)
RUN go test -c ./package1.test -o /out/tests/package1.test
# build the app
RUN go build -o /out/runme
...
FROM alpine as release
COPY /out/ /out/ —-from=builder
...
CMD [“/out/runme”]
```

We are using multistage builds. It means is that it is building the
container in two stages. Briefly this is what is happening:

* Sets  `go:alpine` as `builder` container
* Adds the source code to the local directory
* Downloads the dependencies
* Builds the tests binaries
* Builds the binaries
* Sets a new container called `alpine` as `release`
* Copies only the binaries from the `build` containers
* Set the binary as CMD

As multiple packages under the same repo *is apparently a thing*, I may
suggest to write some helpful scripts, and reduce the lines/commits/layers
inside the docker container.

**Home Work for the Reader**: Check the size of the new docker container and
compare it with the previous one...

*If your heart is accelerating... it is normal, you might be excited...*
*but get checked just in case, I am not a doctor and you are not a developer.*
*Hopefully it is extreme COD over container sizes and not an heart attack*

Ok, now we got it. We have a container! It is much smaller, it doesn’t include
unnecessary stuff like source code or dependencies.

## Working with a pipeline
Using this in a pipeline is the best example to understand the benefit of this
approach. Let’s suppose that we have a dependency like MongoDB, Redis or other
components... *whatever*! How do we run these tests in the pipeline?

I am using GitLab CI/CD Pipeline because it is really useful and easy to
explain. This is doable as well with Jenkins or something else 😉 It is just a
concept.  This is my pipeline scripted as source code in `.gitlab-ci.yaml`:

```yaml
image: docker:latest

services:
  - docker:dind

stages:
  - build
  - test
  - release

variables:
  IMAGE_BASE_NAME: registry.gitlab.com/siderus/example-app

before_script:
  - docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN registry.gitlab.com

build-container:
  stage: build
  script:
    - docker build --compress --force-rm -t "$IMAGE_BASE_NAME:$CI_BUILD_REF_NAME" .
    - docker push "$IMAGE_BASE_NAME:$CI_BUILD_REF_NAME"

test-package1:
  stage: test
  script:
    - docker pull "$IMAGE_BASE_NAME:$CI_BUILD_REF_NAME"
    - docker run -e REDIS_URL="my-test-redis:6379" --rm $IMAGE_BASE_NAME:$CI_BUILD_REF_NAME /out/tests/package1.test

[...]
```

What is happening:

1. We are setting up the basic image where the service will run all the commands as as well the services to run. (`dind`  but we could add redis too)
2. We have specified a set of stages
3. First stage: docker build and push with the commit as a tag
4. Run tests: docker pull and run tests binary

During the building phase, we are pushing a new docker container to the free
gitlab private docker registry. This container has the binary file and the
testing binaries. So the Testing stages are just running these binaries. I
strongly suggest to write a simple script to add inside the container that will
run all the testing binaries.

## Conclusions
*Let me check: is the Reader still there? are you ok? It was not an heart
attack, right?* Anyway, I have noticed the following things happening:

* Smaller container
* Slightly slower building phase
* Faster testing stages
* Faster deployment process
* You may still need to copy some files to run tests
* You still need to run tests locally before pushing commits and PR!
* More scripting is required to improve this with multiple packages

Feel free to leave a comment or share this post if you found it helpful! I am
open for feedback!

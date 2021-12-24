---
layout: post
author: koalalorenzo
comments: true
date: 2016-04-17 18:26:15+02:00
title: "React is not over engineered"
categories:
- Work
- Thoughts
tags:
- old blog
- develop
- react
- angular
- javascript
- over engineered
---
JavaScript development is crazy, and evolving fast... and the more you learn about it
the more you realize how crazy it has become 😅. I think it is exciting, indeed, but
[Sean](https://twitter.com/sfioritto), in [his clear post](http://www.planningforaliens.com/blog/2016/04/11/why-js-development-is-crazy/)
explained perfectly why a simple project is [over-engineered](https://en.wikipedia.org/wiki/Overengineering)
and I have to disagree with him: some JavaScript's frameworks, like React, are
not the cause of unnecessarily complicated projects... and React is not over
engineered!

Sean, by using a simple example of an _Hello World App_ in React described the
pain of using several tools and a big libraries, just to build a simple
application. He said:

> The state of Javascript development is overwhelming and confusing because
everyone is overengineering their apps by default without even realizing it.

The JavaScript language, was born mainly for Web Development loooong time ago.
About 6 years ago, NodeJS created an earthquake, shaking the way we implement
and use the language, opening new opportunities and ways to use the language.
(IoT, web servers or even DNS servers...) 😱

Since developers started using JS for **multiple purposes**, some of the frameworks
are _over-engineered_ for simple projects... and those **other thousands**
people, obviously are writing or including lines of code that are _too much_
for that scope... Why? Because we can use JS for almost everything now.

I have seen this before: Almost any Linux distribution is including a compiled
version of the kernel that comes with modules that you will never need, like the
PlayStation 4 support, or some weird module for a weird old printer... and you
just need to watch a video of cats on youtube! 🐈

This means that the complexity of the kernel and the amount of lines of code
used are _bigger_ than what is actually required to wach cats on youtube. 🐈 The
same happens with languages and Frameworks that are not _modular_... and Node's
NPM, and open source projects, are always there to help. 👍

Sean's example was not totally correct from my point of view. Another tool to
_compile_ code is not overengineering.

Of course, that is **too much for a Hello World**, but for bigger projects
sometimes I have found several tools time-saving and helpful. In fact React
seems to be much less over-engineered [compared to Angular's design](http://eldar.djafarov.com/2014/04/angular-is-evil-overengineering/), since
at the end [an Angular Service is just an Object](http://www.peteheard.com/angularjs/angular-services-are-just-javascript-objects/).

>When you start a Javascript application, the key is to pick a spot on that bell curve just in front of where you think the app could possibly end up in terms of complexity.
I’m not going to lie, getting this right takes experience.

You really learn how to choose specific framework and tools with the experience... but
as Software Architect I always consider the specific reason behind these tools.
React's has some valid reasons but it has its own way to implement things. 💁
I think it is not that bad considering the better outcome for big projects,
that are more than a just a simple Hello World. 😉
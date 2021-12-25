---
author: koalalorenzo
comments: true
date: 2015-05-23 07:31:08+00:00
layout: post
slug: the-final-editor-war-is-over-atom-vs-visual-studio-code
title: 'The final editor war is over: Atom vs Visual Studio Code'
wordpress_id: 18614
categories:
- Thoughts
- Work
tags:
- old blog
- atom
- develop
- github
- mac
- microsoft
- nodejs
- sublime text editor
- visual studio Code
---

During the last month I started **experimenting** a lot with some **editors** for **software development**. I've been playing for 2 weeks with **Atom** and **Visual Studio Code** and here are my impressions from a Mac and Sublime user.
<!--more-->
![Atom VS VisualStudio Code](atom-vs-visual-studio-code.webp)

I started developing several projects using NodeJS, coffee-script, python, docker and angular, but sometimes **Sublime is not enough** and I need other tools and software for job routine. I am a Sublime user, and I love it, but I had to break up with it since I need more features... and I found the love in one of those two editors... :-) 



* * *





## Atom: GitHub OSS version of Sublime



[Atom](http://atom.io/) is really new and the version 1.0 is going to be released soon. It is **OpenSource** and released by **GitHub** and it is thought, designed and created by developers for developers. it comes with a lot of **cool features** that are **helping** any developer.

![Atom Logo](cover.webp#noborder)

On my **everyday working routine**, I have to admit that it suffers from the "_open source then wannabe the best_" problem of new projects: on the website the main line claims an "Hackable text editor", and this means that **everything is plugin** and **ultra-customizable**. This is **good** if you need **specific** features, integrations and language support, but also really bad for speed, like loading time.

The version I was using is slow (Currently: 0.201) but I know they are planning a 1.0 with a better loading time.The release process is really quick: during the week I "deeply used it" I had 4 or 5 upgrades, introducing new features and fixing several bugs... at the end of the day I can say that:

  * **Atom is really young**, but soon it will be stable ([roadmap](https://atom.io/roadmap))
  * It is **customizable** and the plugins are well designed.
  * It can't load files bigger than **2MB** **at the moment** (they are going to fix that).
  * It is really slow if you are used to **Sublime speed** (they are going to fix that too).
  * It is designed and made **by developers for developers** (the welcome view is really helpful)
  * It is **inheriting** all the **cool stuff** from **Sublime** Text Editor (like multiple cursor or keyboard shortcuts)


I like it. I bet that soon it will a better editor and less "wannabe the best" as all the open source projects.



* * *





## Visual Studio Code: Microsoft may be cool again.



When I've read about Microsoft releasing a new software for Mac, I started thinking about my **Mac security and stability**: they are famous for creating software ultra unstable, that will be used in offices for decades without upgrades or security fixes. They [introduced few **viruses for Mac** with MS Office](http://www.notebookreview.com/news/mac-hit-with-a-second-major-virus-in-as-many-weeks-ms-office-users-targeted/) suite and I hope they will not do the same. Microsoft have a really strict privacy terms if you use Visual Studio Code and I got scared... but I decided to risk by downloading it.

![do not download visual studio code](schermata-2015-05-23-alle-08-22-57.webp)

Once installed, the first thing that I have noticed is that it is using Microsoft Metro style... and it is not really user friendly for me, but it is super fast. The loading time is almost immediate and it has already integrated a basic GIT client, code autocompletion and debugging tools... and it is fast. Sadly It ends here, there is nothing more than that. You don't have plugins and deeply customizations like Sublime or cool feature like the multiple cursor to edit several things at once.

I have been using it for a week an I really appreciated the GIT integration, but I was super frustrated by the lack of feature and customizations that an OpenSource release would change it. I can say that:





  * Super cool integration for NodeJS debugger. (even if it is not working as I thought)
  * I don't need a console or SourceTree to commit and push, it is already integrated
  * Super quick, fast and it's startup speed is terrific.
  * Really really basic, do not expect that to be like Sublime.
  * It is Closed Source and we can only download a "preview" ATM.
  * You can only open one window at the time, with one single directory/project.



It is a good thing that Microsoft released something for developers that are using other platform, but I don't like this editor since it has a lack of features. It is a Notepad and git client, but with steroids... and we know that steroids are bad!



* * *





## Conclusions: I decided to use...



After 2 weeks of testing both Atom and Visual Studio Code, I have to admit that both have good reasons to be used as default code editor. I went back to Sublime and I felt something was missing, because both Atom and Visual Studio Code, gave me GitHub and Microsoft ways of coding: two different experiences based on different goals.

**Microsoft wants to be cool again**, and I like this approach, but it is coming back from an **old school way of thinking**, and I don't like that. Microsoft goal probably is similar to something like: "_We wants you to know we released a basic editor for Linux and Mac too. So we are cool again, ok? It comes with 3-4 features including integration with NodeJS and our technologies, are we again cool? right?_". Nope, this is not buying me with that "privacy/terms" line, but Microsoft is doing it right and probably will change again... _but I don't care, TBH._

**GitHub** instead **wants** to provide an **Android-like experience when developing**: For me Android is a super powerful OS, but you **must customize**, **disable** and **enable** things in order to get **the best out of it**. Atom is the same: I am coding in Python and CoffeeScript, so I had to disable all the plugins and languages that I don't use. I also installed some plugins for GIT and _linting_... but **once done, I was home**. Who cares about the "out-of-the-box" startup speed, if I can make it faster and better?

So I went back to Sublime text editor, and the "_buy sublime now_" message appeared and **I freaked out**. I tried Visual Studio Code, and when I pressed _cmd-d_ I felt **physical and mental pain** for not being able of doing cool things.

**OpenSource is winning again**, I went back to **Atom**: it feels slow, but after few seconds I was able to work, with all the things I was used to from Sublime, and more. In the [roadmap](https://atom.io/roadmap), Atom developers will fix all the problems, including speed time and file-size limit. So I decided to use Atom, and I feels satisfied... for now.

_Did I mentioned that **both** Atom and Visual Studio Code are **built on nodejs** [Electron](http://electron.atom.io/)? :P_

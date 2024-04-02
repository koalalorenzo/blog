---
title: "How I get stuff done with Spoon Theory and Shortcuts"
date: 2024-04-02T12:20:57+02:00
draft: true
tags:
  - apple
  - adhd
  - spoon theory
  - shortcuts
  - ios
  - mac
  - ipados
  - automation
---
I have always been a person that organizes his day and tasks, and I have grown
over the years, a little bit too much obsessed about scheduling and prioritizing
things to do. Recently I have diagnosed as neurodivergent and I have been 
introduced to the Spoon Theory, to manage energy level.

I have made an Apple Shortcut that uses Reminders app to get stuff done based on
how much enenergy (spoons :spoon: ) I feel like I have on the moment and I am sharing it
with you! :smile:

<!--more-->
TL;DR: You can [download the shortcut from here](https://www.icloud.com/shortcuts/dca360da797e4c28b1221c5b97c83b6a).

## A little about Spoon Theory
If you have never heard about [The Spoon Theory](https://en.wikipedia.org/wiki/Spoon_theory),
it is a methaphore created by Christine Miserandino in 2003, to describe the 
amount of physical or mental energy available during a day to perform tasks.

What I have learned is that you might wake up one day and have a lot of energy,
or another day when you are deplated entirely. As everybody we have things to do
and those take energy. From cleaning my flat, to sending an email or doing 
something at work. :spoon: All of that takes energy, or spoons.

I have recently started taking medications, and I have found myself in a pit of
despare, laying in bed and not feeling motivated to do anything. I started my day
with one or negative amount of spoons. This might have been caused by the 
medication but a big chunk was due to the fact that I never knew how to manage
my daily amount of spoons.

Most of my spoons where taken away by social media, pressure from other people
or just having a never ending list of things to do. :frowning: This made me feel drained 
even more. I reached a point where just thinking about doing something was 
extremely demotivating.

I took a break from taking the pills and things did not change much. Things got
better when I started scheduling my tasks on Reminders and using the spoon 
theory with an handy Apple Shortcuts that would tell me what I can do on a 
specific moment. The medication started helping too, but managing the energy
levels helped the most. :tada:

## Apple Shortcuts to the rescue
[Apple shortcuts](https://apps.apple.com/us/app/shortcuts/id915249334) is an 
obscure, and mostly unknown application, that runs on iOS, iPadOS and macOS. 
It allows users to automate tasks and integrates with many apps, and OS 
features. My passion for automation made me create a shortcut for this specific
need. Here is how it works:

{{< video src_mp4="ios-spoon.mp4" src_webm="ios-spoon.webm" class="medium" muted="true" >}}

I schedule (_yes, with a deadline_) things that I want to do on the Reminder app.
This includes stuff like _cleaning my flat_, _groceries_, _sending emails_ or
even things like _taking a relaxing shower_ sometimes. :sweat_smile: For each
task I add a tag containing the amount of spoons (Ex: `#3-spoons`).

{{< image src="reminders.feature.webp" >}}

The shortcuts asks me how many spoons I have today, then fetches from the
Reminder app a list of upcoming tasks. It randomizes them and extracts how
many spoons they would take to complete with _regex magic_. Then it tries to
fit as many tasks as possible based on the amount of spoons I have available,
and shows it on the screen, as well as spits it out as an output.

The reason of doing it as an output too, is that I am using the same shortcut
with other shortcuts (ex: The integration with Obsidian for my second brain).

You can download, inspect and use the shortcut from 
[this link here](https://www.icloud.com/shortcuts/dca360da797e4c28b1221c5b97c83b6a).
It works on all platform (iOS, macOS and iPadOS).

## Things that made it works
Here are a few things that I have learned and changes I had to implement in 
order to make it work for me. At the beginning I got a little frustated, but 
then these tricks made me get stuff done. I have added comments in the flow
about those.

{{< image src="mac-spoon-shortcut.webp" class="big" >}}

At the beginning I was listing all the reminders, without any deadline. 
This made me a lot more anxiety then needed, and the shortcuts was not helping
at all. All the tasks together did not help. The solution was to **schedule**, 
and think _when_ I could do something, so that I don't get to do too many things
in one day and exaust spoons.

Setting the order to **random** instead of **sort by priority** was important.
Sometimes I don't feel like acting on things as the amount of spoons that some
tasks are required varies from day to day. Having a random order of tasks that
I should do, allows me to re-run the shortcut so that I might get a different
output every time. So if I don't feel like doing something, I pick something 
else!

Not knowing how many spoons a specific tasks would take (even if I had set it
up) made me not stress about it, I just know that I can acheive and I don't get
too much biased of what should and should not do on that day.

## Conclusion
I hope that this shortcut helps other people the same way it helped me. It is
a small thing. It does not require a dedicated ToDo list, or to pay for a
specific app. You can [download the shortcut here](https://www.icloud.com/shortcuts/dca360da797e4c28b1221c5b97c83b6a).

If you find this shortcut useful please [let me know on mastodon](https://mastodon.social/@koalalorenzo)! 
I would appreciate it a lot :heart: :smile:

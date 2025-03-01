---
title: "My first Game Jam"
date: 2025-03-02T14:40:01+01:00
tags:
  - gamedev
  - gamejam
  - videogames
  - software development
  - godot
---
In January 2024 I started making small videogames for pure fun. After some
practice, playtest with friends and new languages to learn, I decided to
test my skils and publish something. So I joined my first Game Jam and
submitted my first game: Yak Shaving Space Delivery. Here are my thoughts about
it.

<!--more-->

{{< image src="cover.webp" link="https://koalalorenzo.itch.io/yak-shaving-brackeys-13" >}}

## Learning something new
I wanted to learn something new, and different than SRE work! I have always been
attracted to this kind of work because it combines more than just a front-end or
back-end... it has art, lots of logic, user experience, music and on top of that
plenty to get excited!

Showing to your friends an API, some YAML, or a React web page is not the same
as playing a game you made together! Being able to export the game to different
platforms was key for this to happen.

My love for free and open source software pushed me to use Godot as a game
engine. Even if I worked for Unity and I adminre the work of my former
colleagues, I still went with FOSS as I wanted to rely on something more stable
and reliable. I even decided to [donate 5 euros a month to support the project](https://blog.setale.me/2023/01/25/Happy-to-give-back-happy-to-pay/).

## My first Game Jam
Since I started using Godot I made small games that I have never published.
I consumed a lot of tutorials, videos, and read a lot of documentation,
and I followed some suggestions of making a few games, starting from a simple
PONG, and increasing gradually the scope of the projects, as well as the audience...
I wanted to pass a real test: make a game public! What better option than a Game Jam?

So I decided to join [Brackeys Game Jam 2025.1](https://itch.io/jam/brackeys-13)
and on February the 16th at 12:00 the theme was revealed: _Nothing can go wrong..._
My goal for this Jam is to learn and gather feedback, to improve my craft.

{{< image src="brackeys-gj-logo.webp" link="https://itch.io/jam/brackeys-13" >}}

I messed up the dates and reserved the wrong week, but nothing went wrong IRL:
I ordered a lot of food on Wolt, drank a lot of coffee and stayed home the whole
time, with some breaks. During the breaks I played online games with the gang at
[PAN Idraet Gaming](https://panidraet.dk/en/idraetsgrene/andre-aktiviteter/gaming/)
and got even some playtest from some of the members of the club! :smile:

## About the game 
For a whole week, I worked very hard on making a game. I started thinking about
what I can relate when things go wrong, or not, and when brainstorming about
decision trees and tasks priority 2 things came into my mind:

1. [Toil](https://sre.google/sre-book/eliminating-toil/)
2. [Yak Shaving](https://en.wiktionary.org/wiki/yak_shaving)

I decided to work on these two concept and make a game where somebody would
start from a single goal, but gradually things go wrong and the player has to
perform tasks that seems unrelated to the main goal. Yak Shaving.
Though, _how can I make something tedious actually fun_?

{{< image src="tree.webp" class="big" >}}

So I started working on it: In the game you are an astronaut on a spaceship
picking up cargo from a planet and delivering it to another planet. Something
goes wrong: time the spaceship visits space there are new tasks. The goal?
Deliver 6 Yaks in the shortest amount of time.

To make the player do proper _Yak Shaving_ the tasks should have some sort of
dependency: do _this_ before _that_. At the beginning they have to refuel the
engine by placing new fuel in the engine. Easy to learn the mechanic.

On the second trip the _Gravity Generator_ breaks, making things float and
impossible to pick up new fuel. They need to fix it before they can refuel the
spaceship engines.

There are other tasks, that will happen, but due to the limited amount of time
for development, I focused on implementing the same mechanic: pick an object and
drop it somewhere, or interact with a machine.

To make things fun I decided to rely on dialogues from the ship and physics.
The spaceship itself guides the player and has some hints of laziness.
Theirname? _Procrastinator 9000_ of course! They are sassy, annoyed by
biological life form, and would prefer doing nothing rather than perform the
tasks.

As _Nothing can go wrong_ the player never dies, though something _goes wrong_
and the challenge is to deal with the chaos. Every trip the player needs to
transport more Yaks, Yaks poop fuel when in space, and there are more tasks.

At least that is the basic idea. Give it a spin and play the game
[here](http://koalalorenzo.itch.io/yak-shaving-brackeys-13)!

{{< video src_mp4="editor-incenerator.mp4" src_webm="editor-incenerator.webm" loop="true" class="big" muted="true" >}}

## Making the game
In line of work I have always focused on avoid repeating code, and reuse things,
so I prepared a basic Godot 4 add-on that I reuse to do UI elements, or deal
with complex things like Input, Path finding, Navigation, Inventory,
a State Machine etc etc

To be honest I used very little of the code that I prepared, the main reason is
that I did not need most of the things I prepared. The theme and time made me
focus on a limited amount of mechanics. Though bootstrapping a basic testable
version of the game was easier with my add-on/library.

I enjoyed a lot following some of the Godot principles, one of which is to make
_everything a Node_, with custom Resources too. The code was much cleaner and I
could easily implement different tasks for the player by just customizing a few
variables in an instance of my custom `Task` node.

For the sound effects I could not find right what I wanted to use... so I made
them myself! Long time ago, when I was streaming I bought a Yeti Blue microphone
that turned out to be super useful. ..._and yes, people noticed that_ :laughing:

Long time ago my partner also gifted to me an asset pack from Humble Bundle and
I hoarded a bunch of assets, including some of the background sounds.

On the last day I had some big issues with Dialogic, that caused me some
actual _Yak shaving_. :facepalm: Investigating an issues with instances not being freed
correclty, leaving memory leaks. It was hard, and I ended up switching
to [Dialogue Manager](https://dialogue.nathanhoad.net), which was much simpler,
it looked actively maintained, and easier to use/implement.

I made most of the 3D Assets using [Kenny's Forge Deluxe](https://www.kenney.nl/tools/asset-forge):
I gifted myself for christmas a tool to make quick 3D models that I could
export. I would love to learn Blender at some point. I bought the Astronaut
and got the animal from itch.io (Credits in the game page).

{{< image src="asset-forge.webp" class="big" >}}

## Learnings so far
After submitting the game to the Game Jam, I started receiving some feedback.
Simple "_Well done for solo in 7 days_", and "_Kudos_", was nice though not what
I wanted. So I reached out in the community to ask for some real and honest
feedback. I had to fix some collision shapes and issues with the game crashing
due to objects beeing freed.

I remember watching videos and videos to prepare but I realised too late that I
made some basic mistakes. Here are some learning so far:

- I should have done more playtest or gather metrics
- The orthogonal camera was a risky bet, not everybody liked it
- The game is slow and it might take 15 minutes to complete it
- I made a lot of typos and grammar mistakes

The first playtests where done by my friends, and they were honest but most of
the time I could not sit behind them and observe the behaviour. I only did 1
playtest where I could do that and I learned a lot, including that the
orthogonal camera caused some dizziness, or that the input could have been
completely different.

As a result I learned to focus on somethign faster, engaging, easy to learn, and
with a shorter game loop. From the comments I suspect that most of the players
quitted before even reaching space for the second time, probably because
_nothing seems to go wrong_.

If I could have used AI, I would at least fixed the typos! Though I was happy to
see that people do understand that making a game solo in 7 days, means cutting
corners.

## Conclusions so far!
Everybody seems super supportive, and asking for honest feedback is
super useful, it did not demoralize me. It reminded me a lot of the pressure I
get when doing hackathons, though this felt more tangible. This is my first game
jam and I would do it again. I don't feel like working on this game more than
fixing some bugs.

I enjoyed also reviewing other games and learning that I am not the only one
making these mistakes. I was also surprised by all the other mechanics and
different interpretations of the theme _Nothing can go wrong..._.

You can play Yak Shaving Space Delivery in the browser [on itch.io here](http://koalalorenzo.itch.io/yak-shaving-brackeys-13),
or download it for Windows, macOS, or Linux... and if you are in the competition
please consider reviewing my game and leaving some feedback :heart:


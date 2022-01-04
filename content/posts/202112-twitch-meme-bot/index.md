---
title: "A Twitch bot to create memes and show them live"
date: 2021-12-18T13:55:50+01:00
draft: false
tags:
  - Go
  - develop
  - twitch
  - streaming
  - bot
  - Heroku
  - opensource
mermaid: true
---
During the dark side of quarantine, I had to keep my hands busy, and instead of
writing on this blog (_sorry_!) I **started streaming on Twitch** instead. To
add some **interactivity with my viewers**, I made my own bot to let my viewers
create and display custom Images and GIFs with text... Basically, a Meme 
Generator! This  is the story of **designing it**, **building it** in Go, and **running it** Heroku 🤩

<!--more-->

See it in action:

{{< youtube os4yx5Ryzmo >}}

## The Bot Idea

The idea is simple. If you write on my chat while I stream something like:

```yaml
!meme hello Hello Lorenzo!
```

It will show you something like this on my stream:

{{< image src="hello-example.webp" alt="Example of a Meme generated using the Bot" tag="#small" >}}

People could generate Memes based on what was happening on the screen, and since 
I have been playing a lot of Dead By Daylight, there were plenty of moments to 
have fun creating new images while I was running away from the killer. 😜

I have decided to make it using [Go](https://go.dev) and hosting it on
[Heroku](https://heroku.com). If you want to skip straight to the app running,
you can do it [here](https://koalalorenzo-twitch-meme-gen.herokuapp.com) and
you can check the
[source code here](http://gitlab.com/koalalorenzo/twitch-meme-generator), where
you can follow the instructions on how to deploy it on your Twitch channel!

## Building it was fun because it was challenging
I built this live while streaming and the viewers as 
[rubber ducks](https://en.wikipedia.org/wiki/Rubber_duck_debugging)! In general,
there were a few challenges like: _How do I connect to Twitch_? _How can I make an
OBS show the Image?_ _How do I generate Images in Go?_
_How can I make it easy to deploy?_ and also,
_what should be the name of the bot?_ 🤣

In the end, I named it _Koalalorenzo's Twitch Meme Bot_... LOL!

### Twitch uses IRC for chat
In the beginning, I was thinking about using a full-blown Twitch Bot, but 
setting it up would have been way more complex than needed. 
Instead I have discovered that [Twitch uses IRC](https://dev.twitch.tv/docs/irc) 
(or sort of) for every stream. I don't have to deal with authentication unless I 
need to write to the channel. Since the bot is just listening, 
[I found a go module](https://github.com/gempir/go-twitch-irc) that would just 
listen to the IRC interface. _Jackpot_!

### Ingredients: Goroutines, WebSockets, Go channels
I found out that the easiest way to show content on my stream was to use a 
specific widget in [Open Broadcaster Software](https://obsproject.com)
(OBS for friends). I discovered that almost all the streaming services are 
using a clever trick: Streamlabs, Sound Alert, and many others use a
**transparent HTML page** to show images, content, and animations. This means
that it is super easy for me to implement this and display a picture on my 
stream!

I figured out that I needed a little more than constantly refreshing the HTML 
page. I had to make my hands dirty with WebSockets in Go and connect them 
to some Go channel.

The approach follows: Once a new message reaches the Twitch bot, a
goroutine will analyze it and generate the image. Once that is done, it will 
send a message containing the custom Image URL to the _main_ go channel.

Then a function consumes messages from this _main_ channel and sends them to 
various other channels, one for each WebSocket open. Like this:

{{< mermaid >}}
flowchart TD;
  TPar[\"twitch.parser()"/];
  IGa["GenerateMeme() 1st"];
  IGb["GenerateMeme() 2nd"];
  IGn["GenerateMeme() Nth"];
  MainChannel{{"mainChannel queue"}};
  WBC[/"channelPipe() broadcast"\];

  NMSG([IRC Messages]) ==> TPar;
  TPar-- Starts a goroutine -->IGa;
  TPar-- Starts a goroutine -->IGb;
  TPar-- Starts a goroutine -->IGn;
  IGa-- sends Image URL-->MainChannel;
  IGb-- sends Image URL -->MainChannel;
  IGn-- sends Image URL -->MainChannel;
  MainChannel==>WBC;
  WBC--"channel 1"-->wsChannela["reader() (OBS Channel)"];
  WBC--"channel 2"-->wsChannelb["reader() (Safari Channel)"];
  wsChannela-- Web Socket -->B(["Web Page in OBS"]);
  wsChannelb-- Web Socket --->C(["Web Page in Safari"]);
{{< /mermaid >}}

_Why this complex structure_? 😅 When a web page opens, using
some JavaScript code (yeah, there is some [spaghetti code here](https://gitlab.com/koalalorenzo/twitch-meme-generator/-/blob/main/http/streamview.go#L43) 🤫),
there is **a new WebSocket connection every time**. If I open more, I need to 
_broadcast_ (or _funnel out_) the Image URL to **every single web page**.
For each WebSocket, there is a Go channel and 
[a function](https://gitlab.com/koalalorenzo/twitch-meme-generator/-/blob/main/http/channels.go#L15)
that broadcasts the messages to all of them.

It might not be the best nor the most straightforward implementation, but it 
works... Please let me know with a PR or a comment if there is a better way!

### Generating Images and GIFS, but FASTER!
This part was interesting, but I was lucky to find a Go module that would
generate Images and GIFs based on text input. After inspecting the code
of [jpoz/gomeme](https://github.com/jpoz/gomeme) was working fine for my case, 
it does _exactly_ what I was planning to do... except for one minor detail: the 
image size and formats. _Here is the issue:_

[James](https://github.com/jpoz)'s module supports GIFs, PNG, and JPEGs.
Those formats could be quite heavy and slow to manipulate. One of the
GIFs that I am using as an example, called `yeah`, it is a
**whopping 23MB in size**! 😱 This file takes around **2-3 seconds**
to generate and display into OBS Browser Source and on my stream.

The solution is to implement [WebP](https://en.wikipedia.org/wiki/WebP):
a new image standard [developed by Google](https://developers.google.com/speed/webp)
that is way lighter than PNGs, JPEGs, and GIFs! During my test, the
[23MB GIF](https://gitlab.com/koalalorenzo/twitch-meme-generator/-/blob/63b969bc98b97d94550e0e53fb368e1124f50d4d/assets/yeah.69.gif?expanded=true&viewer=rich)
became
[4MB Animated WebP](https://gitlab.com/koalalorenzo/twitch-meme-generator/-/blob/d3ba69eb50726810bc5423b7586723a5334aff63/assets/yeah.69.webp).
_It is still a big file_, but it will be faster to process. 🎉

To do so I had to create my
[own fork of the module](https://gitlab.com/koalalorenzo/gomeme). Sadly, it 
requires GCC as there is no official `image/webp` package in the Go standard 
library... 😭 and on top of that, I was able to find only libraries using C code 
to deal with WebP and not with Animated WebP. So due to time constraints, I 
added support for WebP only for static Images... 🤞 hoping to upgrade to 
Animated WebP when the Go standard library implements them.

Using my fork of Jame’s Go module made some images faster, but I kept the source
to display PNGs, JPEGs, and GIFs as I am not expecting people to use only 
WebP...  I could improve the bot to render the images in WebP, but that is for 
another time, maybe! 😉

## Conclusion
In the full spirit of OpenSource, I opened a
[Pull Request on Github](https://github.com/jpoz/gomeme/pull/3)
to merge my gomeme changes and contribute to the original project. 🤞 Maybe
somebody else will use my WebP changes to make even more efficient Meme
Images! 🤣 Kudos to [James Pozdena](https://github.com/jpoz) for making it! ❤️

I have added a lot of other functionalities, like support for a basic Web UI,
a WebHook with Basic HTTP Auth, and some JSON API to integrate with **Apple
Shortcuts**...  so that I can generate memes from my iPhone or from my Mac.

![My Shortcut to generate Memes from my iPhone](shortcuts-twitch-gen.webp#noborder#big)

Building this was pure pleasure. I made something so that viewers can have some 
fun, just as a small project. I am happy that I gathered some feedback from some
of my viewers after making it. Sadly I had _very little time to stream_
on twitch recently, and therefore the project did not evolve anymore. 😭 

...But if you see me live [on my channel](https://www.twitch.com/koalalorenzo), 
feel free to say hello with a meme! ❤️  **If you want to use the twitch meme 
generator**, check out the [README](https://gitlab.com/koalalorenzo/twitch-meme-generator/-/blob/main/README.md) 
in the repo: I wrote instructions on setting it up and customizing it. 
There is even a quick button to deploy it to Heroku! 😉 

## Useful links

* [Link to Quick Deploy it on Heroku](https://heroku.com/deploy?template=https://github.com/koalalorenzo/twitch-meme-generator/tree/main)
* [See the app running here](https://koalalorenzo-twitch-meme-gen.herokuapp.com/)
* [Source Code on GitLab](https://gitlab.com/koalalorenzo/twitch-meme-generator/)
* [My GoMeme Fork with WebP Support](https://gitlab.com/koalalorenzo/gomeme)

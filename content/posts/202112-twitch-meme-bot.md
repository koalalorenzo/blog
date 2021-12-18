---
title: "I made a Twitch Bot to generate memes for fun"
date: 2021-12-18T13:55:50+01:00
draft: true
tags:
  - Go
  - develop
  - twitch
  - streaming
  - bot
  - Heroku
  - opensource
thumbnail: /images/202112/stream.webp
mermaid: true
---
During the dark side of quarantine, I had to keep my hands busy, and instead of
writing on this blog (_sorry_!) I **started streaming on Twitch** instead. To 
add some **interactivity with my viewers**, I decided to create my own bot to 
display custom Images and GIFs with a text that my viewers could decided...
Basically a Meme Generator! This is **the story of designing it, building it in
Go and running it Heroku** 🤩

<!--more-->

See it in action:

{{< youtube os4yx5Ryzmo >}}

## The Bot Idea

The Idea is simple. If you write on my chat while I stream something like:

```yaml
!meme hello Hey Lorenzo!
```

It will show you something like this on my stream:

![Example of a Meme generated using the Bot](/images/202112/hello-example.webp#small)

This was fun because at times, people could generate Memes based on what was
happening on the screen, and since I have been playing a lot of Dead By
Daylight, there were plenty of moments to have fun creating new images.

I have decided to make it using [Go](https://go.dev) and hosting it on
[Heroku](https://heroku.com). If you want to skip straight to the app running
your can do it [here](https://koalalorenzo-twitch-meme-gen.herokuapp.com) and
you can check the
[soruce code here](http://gitlab.com/koalalorenzo/twitch-meme-generator), where
you can follow the instructions on how to deploy it on your own Twitch channel!

## Building it was fun because it was challenging
I was building this live, while streamign and using the viewers as
[rubber ducks](https://en.wikipedia.org/wiki/Rubber_duck_debugging)! In general
there were a few challenges like: _How do I connect to Twitch_? _How can I make an
OBS connect to the Image_? _How do I generate Imanges in Go_?
_How can I make it easy to deploy_? and also,
_what should be the name of the bot_? 🤣

### Twitch uses IRC for chat
At the beginning I was thinking about using a full-blown Twitch Bot, but setting
it up would have been way more complex than needed. Instead I have discovered
that [Twitch uses IRC](https://dev.twitch.tv/docs/irc) (or sort of) for every
stream. This means that I don't have to deal necessarely with authentication
unless I need to write to the channel. Since the bot is just listening,
[I found a go module](https://github.com/gempir/go-twitch-irc) that would just
listen to the IRC interface. Jackpot!

### Ingredients: Go routines, WebSockets, Go channels
I found out that the easiest way to show content on my stream was to use OBS's
Browser source. I discovered that almost all the streaming plugins are using 
a clever trick: Streamlabs, Sound Alert, and many others are using a 
**transparent HTML page** to show images, content and animations. This means
that it is super easy for me to show a image on my stream!

To connect to it, I figured out that i needed a little more than just refreshing
the HTML page constantly, I had to make my hands dirty with WebSockets in Go, 
and connect them to some Go Channel.

The approach is the following: Once a new message arrives to the Twitch bot,
a Go routine will analyze it and generate the image. Once that is doen, it will
send a message to a _main_ go channel.

On the other hand of the _main_ go channel there are various channels listening,
one for each WebSocket open. Like this:

{{< mermaid >}}
flowchart TD;
  TPar[\"twitch.parser()"/];
  IGa["GenerateMeme() 1st"];
  IGb["GenerateMeme() 2nd"];
  IGn["GenerateMeme() Nth"];
  MainChannel{{"mainChannel"}};
  WBC[/"channelPipe() broadcast"\];
  
  NMSG([New Message on IRC]) ==> TPar;
  TPar-- Starts a Go routine -->IGa;
  TPar-- Starts a Go routine -->IGb;
  TPar-- Starts a Go routine -->IGn;
  IGa-- sends Image URL-->MainChannel;
  IGb-- sends Image URL -->MainChannel;
  IGn-- sends Image URL -->MainChannel;
  MainChannel==>WBC;
  WBC-->wsChannela["OBS Go Channel reader()"];
  WBC-->wsChannelb["Safari Go Channel reader()"];
  wsChannela-- Web Socket -->B(["Web Socket OBS"]);
  wsChannelb-- Web Socket --->C(["WebPage Safari"]);
{{< /mermaid >}}

_Why this complex structure_? 😅 When a web page opens, using 
some JavaScript code (yeah, there is some [spaghetti code here](https://gitlab.com/koalalorenzo/twitch-meme-generator/-/blob/main/http/streamview.go#L43) 🤫),
there is a new connection using **a new Websocket**. If I open more, 
I need to _broadcast_ (or funnel out) the Image URL to **every single web page**. 
To make it possible, the code creates **a new Go Channel for each WebSocket**,
and uses a `mainChannel` 
[to broadcast the message to all the other go channels](https://gitlab.com/koalalorenzo/twitch-meme-generator/-/blob/main/http/channels.go#L15).

### Genearting Images and GIFS, but FASTER!
This part was intersting, but I was lucky to find a Go module that would
exactly generate Images and GIFs based on text imput. After inspecting the code
[jpoz/gomeme](https://github.com/jpoz/gomeme) was working fine for my case, it
did exactly what I was planning to do... except for one little detail: the image
size and formats. Let me explain why:

[James](https://github.com/jpoz)'s module supports GIFs, PNG, and JPEGs.
Those formats could be quite heavy and slow to manipulate. Infact one of the
GIFs that I am using as an example, called `yeah`, it is a
**whopping 23MB in size**! 😱 This means that it takes from **2 to 3 seconds**
to generate, and display into OBS Browser Source and on my stream.

The solution to this is to implement where possible
[WebP](https://en.wikipedia.org/wiki/WebP): a new image standard
[developed by Google](https://developers.google.com/speed/webp)
that is way lighter than PNGs, JPEGs and GIFs! During my test, the
[23MB GIF](https://gitlab.com/koalalorenzo/twitch-meme-generator/-/blob/63b969bc98b97d94550e0e53fb368e1124f50d4d/assets/yeah.69.gif?expanded=true&viewer=rich),
became
[4MB Animated WebP](https://gitlab.com/koalalorenzo/twitch-meme-generator/-/blob/d3ba69eb50726810bc5423b7586723a5334aff63/assets/yeah.69.webp).
_It is still a big file_, but it will be faster to process. 🎉

To do so I had to create my
[own fork of the module](https://gitlab.com/koalalorenzo/gomeme). My fork sadly
does requires GCC as there is no official `image/webp` package in the Go
standard library... 😭 and on top of that I was able to find only libraries that
are actually using C code to deal with WebP and Animated WebP. So due to time
constraints I added support for WebP only for static Images... 🤞 hoping to
upgrade to Animated WebP when the Go standard library will implement them.

Using my own fork of Jame's Go module, made some of the images faster to display
but I kept the source to display PNGs, JPEGs and GIFs as I am not expecting
people to use WebP... I could improve the bot to render the images in WebP, but
that is for another time maybe! 😉

## Conclusion
Building this was actually super fun. I feel that I made something for fun,
just as a small project. I am happy that I gathered some feedback from some of
my viewers after making it, but sadly I had very little time to stream during 
the last months, and therefore the project did not evolve anymore.

In the full sprit of OpenSource I opened a Pull Request on Github to merge my 
gomeme changes and contribute to the original project. Maybe somebody else
will use my WebP changes to make even more efficient Meme Images! 🤣 


## Useful links

* [Quick link to Deploy it on Heroku](https://heroku.com/deploy?template=https://github.com/koalalorenzo/twitch-meme-generator/tree/main)
* [Source Code on GitLab](https://gitlab.com/koalalorenzo/twitch-meme-generator/)
* [My GoMeme Fork with WebP Support](https://gitlab.com/koalalorenzo/gomeme)

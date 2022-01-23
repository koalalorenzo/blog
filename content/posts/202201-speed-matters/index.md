---
title: "Speed matters: Improving my blog"
date: 2022-01-23T15:39:41+01:00
tags:
  - hugo
  - WebP
---
Recently I have been travelling with a bad airplane company that lost my 
luggage. In hope to get my belongings back with me, I tried to use their
website and support page, just to be super frustrated every time. The main
reason of frustration, besides the lack of any form of support, was the 
website speed. So I decided to spend the time without my luggage (around 5 days)
trying to use best practices to improve the speed of my own website and blog.

<!--more-->

## Investigations
On my way to Recife, from Copenhagen, on an airplane from TAP Airplines I 
realised that my luggage was stuck in Copenhagen. My Apple AirTag helped me a 
lot, but I could not do much besides trying to use a unusable website.

So I [inspected the website a little further](https://pagespeed.web.dev/report?url=http%3A%2F%2Fflytap.com%2F) 
and I realised that [FlyTAP.com homepage weights around **17MB**](flytap.com-size.webp). 
I had a lot of issue opening every single page on a _Hotel Wifi_. Using my 
iPhone was even a worse experience.

{{< image src="page-speed-mobile.webp" caption="flytap.com Google Speed test was pretty clear to me" class="noborder big">}}

Looking at the Page Speed on Google's page, my personal Hugo blog was already 
fast, but there was still a bunch of things to improve:

* There were lot of unused CSS and JS code from different frameworks/style[^deps-fix]
* The CSS files were not minimized[^css-fix]
* The JavaScript code was not minimized, nor bundled up
* Some resources were not pre-loaded[^preload]
* Images were the heavies elements

So I have decided to resolve all these issues and try to reduce the size of the
page, the amount of connections and improve the speed. Aiming for something 
below 500kb.

[^css-fix]: I am already building [SCSS/SASS files into a single CSS file](), 
but I was not minimizing it.

[^deps-fix]: This blog, and my personal page were using 
[Material UI CSS](https://www.muicss.com/) and [jquery](https://jquery.com/) 😱 
for no real reason. 😅

[^preload]: Some resources are downloaded only when the browser reaches the 
HTML page calling it, but [it is possible to pre-load](https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types/preload),
so that the files are ready to be used later on.

## Images: Hugo dynamic resize, WebP and Animated WebP
Since the Images were the heaviest elements loaded in the page


## The process
What we did to reach the goal

## Conclusion
Learnings

## Useful links
Share links here

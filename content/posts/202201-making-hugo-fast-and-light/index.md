---
title: "My Hugo blog now is fast and light"
date: 2022-01-23T15:39:41+01:00
tags:
  - hugo
  - go
  - webp
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
**below 500kb**.

This blog is entirely generated using [Hugo](https://gohugo.io). 
Everything is orchestrated using GNU/Make. It should be something 
easy to do.

[^css-fix]: I am already building 
[SCSS/SASS files into a single CSS file](https://gitlab.com/koalalorenzo/blog/-/blob/dc77e8d2ae9d6de9db8fc23b4539aec6fc15cbb5/layouts/partials/head.html#L30), 
but I was not minimizing it.

[^deps-fix]: This blog, and my personal page were using 
[Material UI CSS](https://www.muicss.com/) and [jquery](https://jquery.com/) 😱 
for no real reason. 😅

[^preload]: Some resources are downloaded only when the browser reaches the 
HTML page calling it, but [it is possible to pre-load](https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types/preload),
so that the files are ready to be used later on.

## Images: WebP, Animated WebP and right-sizing
Since the Images were the heaviest elements loaded in the page, I started 
workign there. I decided to transform all my GIF, PNG and JPEG to [WebP images](https://en.wikipedia.org/wiki/WebP).[^webp-vs-]
I ran a few commands and updated my [Makefile](https://gitlab.com/koalalorenzo/blog/-/blob/dc77e8d2ae9d6de9db8fc23b4539aec6fc15cbb5/Makefile#L44), to do this automagically:

```bash
# Installing WebP tools on macOS
brew install webp

# converting PNGs and JPEGs to WebP
cwebp -short -q 85 ${FILENAME}.png -o ${FILENAME}.webp

# converting GIF to Animated WebP
gif2webp -mt -mixed -q 60 ${FILENAME}.gif -o ${FILENAME}.webp
```

This made some huge improvements in file size, shrinking most of them **from 
several MB to a few kilobites**![^size-image-changes] That was already a huge 
win for me, because I love to use GIFs and memes in my posts! 😅

[^size-image-changes]: You can see [from this PR](https://gitlab.com/koalalorenzo/blog/-/merge_requests/4/diffs#3fa76e96f26c99e5110e368f3bbed165427a47e1) that when I started working on
moving to WebP, I reduced a lot the size of the images.

{{< image src="webp-gif-size-feature-center.webp" caption="Size matters too!">}}

To improve speed, WebP is not enough. Another issue with the image was that
I was downloading big images of around 5000x5000 pixels, for a small thumbnail
space, that is around 300x300 pixels. Resizing the thumbnail to proper size
would help, and reducing the sizes to lower things... 

Thankfully, Hugo can process images and resize/fit images to proper sizes, 
directly from the [layout templates of my theme](https://gitlab.com/koalalorenzo/blog/-/blob/dc77e8d2ae9d6de9db8fc23b4539aec6fc15cbb5/layouts/_default/page-short.html#L15)!

```html
<!-- Get the feature/cover/thumnail image for the post -->
{{- $images := $.Resources.ByType "image" -}}
{{- $featured := $images.GetMatch "*feature*" -}}
{{- if not $featured }}{{ $featured = $images.GetMatch "{*cover*,*thumbnail*}" }}{{ end -}}    

{{- with $featured -}}
<a href="{{ $.Permalink | relURL }}" data-instant>
  <!-- Resize the image to 450x300 pixels and use WebP format -->
  {{ with $i := .Fill "450x300 Center webp q75" }}
  <div class="thumbnail" style="background-image: url({{$i.RelPermalink}});"></div>
  {{ end }}
</a>
{{ end }}
```

There are [a lot of functions that can be used to manipualte images](https://gohugo.io/content-management/image-processing/), 
and I am very happy about it because it saved me a lot of commands to 
run for each thumbnail! 😎 

## Removing Material UI and jQuery
I can't remember when I started, but  when it comes to build new HTML pages, 
I have the feeling that I have always been using some sort of _quick framework_ 
to save me time. Originally it was Bootstrap but then I switched to some 
Material UI with MUI CSS.

When looking at FlyTAP website, I noticed how many frameworks the homepage 
loads: Angular, jQuery, Lodash, Mustache...  [Full list, by wappalyzer](wappalyzer_flytap-com.csv)
My blog was also using Material UI / MUI CSS, and I realised that I was using
it for no real good reason. While my homepage was using the old good Bootstrap 
and jQuery, just to have an animated avatar in the center.

So I just got rid of all of them, and I removed a lot of CSS and JavaScript that
I was anyway customizing. That removed many files!

I also got rid of Disqus, in favor of [utteranc.es](utteranc.es) with GitHub
integration.

## Hugo bundles my JavaScript now!
Originally my website was using a lot of Javascript, 

## Serving all these things together
It looks like FlyTap.com is served from Microsoft Windows Servers. 😱 I then 
understand how probably TAP Air Portugal just _wanted to have a website_, and
outsurced it to the cheapest offer. 💸 

My blog was not outsourced. I would not host on Microsoft Windows or even Azure.
Originally I have been using GitHub Pages, but then moved to GitLab Pages for 
integrity reasons. [To turn it up to eleven](https://en.wikipedia.org/wiki/Up_to_eleven), 
I have decided to onboard to [Cloudflare Pages](https://pages.dev).

Compared to GitHub and GitLab, Cloudflare Pages allows me to customize
the headers, redirects, and add serverless functions directly from my Hugo
setup.

```yaml
# File: _headers
/*
  Cache-Control: max-age=1209600, s-maxage=1209600, stale-if-error=600
  Cloudflare-CDN-Cache-Control: max-age=1209600, stale-if-error=600
  CDN-Cache-Control: 1209600, stale-if-error=600
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff

/images/*
  Cache-Control: max-age=31536000, s-maxage=31536000, stale-if-error=600
  Cloudflare-CDN-Cache-Control: max-age=31536000, stale-if-error=600
  CDN-Cache-Control: 31536000

/fonts/*
  Cache-Control: max-age=31536000, s-maxage=31536000, stale-if-error=600
  Cloudflare-CDN-Cache-Control: max-age=31536000, stale-if-error=600
  CDN-Cache-Control: 31536000
```

Setting this up, is very important to me, as I can fine tune settings and 
improve speed by better leveraging Cloudflare CDN and the Browser's cache.
There is a full page 

## Conclusions
Although I cannot change TAP Airlines's website or their customer support, I
have learned a lot of things about optimizing websites and how Hugo does it.

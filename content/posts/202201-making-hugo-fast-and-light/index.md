---
title: "My Hugo blog now is fast and light"
date: 2022-01-23T15:39:41+01:00
tags:
  - hugo
  - go
  - webp
---
This blog post is about what I have changed in my blog and website to make it
faster. Recently, I have traveled with a bad airplane company that lost my
luggage. In the hope of getting my belongings back with me, I tried to use their
website and support pages, and I was frustrated every time. The primary source
of frustration was the website speed. So I decided to spend most of the time
without my luggage (around five days), trying to use best practices to improve
my website and blog, making my Hugo blog faster and way lighter than before.

<!--more-->

## The Investigations
On my way to Recife from Copenhagen, I realized that my luggage was stuck in
Copenhagen on a TAP Airplane. [My Apple AirTag](apple-airtag-tap-luggage.webp)
helped me, but I could not do much besides using an unusable website.

So I [inspected the website a little further](https://pagespeed.web.dev/report?url=http%3A%2F%2Fflytap.com%2F)
and I realized that [FlyTAP.com homepage weights around **17MB**](flytap.com-size.webp).
I had a lot of issues opening every single page on a _Hotel Wifi_.
Using my iPhone was even a worse experience.

{{< image src="flytap-speed.webp" caption="flytap.com GTMetrix tests are very bad" class="noborder big">}}

My blog was already light, but I know that I could improve it:

* There was a lot of unused CSS and JS code from different frameworks/style[^deps-fix]
* The CSS files were not minimized[^css-fix]
* The JavaScript code was not minimized nor bundled up
* Some resources were not pre-loaded[^preload]
* Images were the heavies elements

I started resolving all these issues to reduce the page size and the number of
connections and improve the speed, [Aiming for something below 512kb](http://512kb.club/).

I am lucky because [Hugo](https://gohugo.io) is the static engine used to build
this blog. Everything is orchestrated using GNU/Make. These two Open Source
tools made the changes easier to achieve.

[^css-fix]: I am already building
[SCSS/SASS files into a single CSS file](https://gitlab.com/koalalorenzo/blog/-/blob/dc77e8d2ae9d6de9db8fc23b4539aec6fc15cbb5/layouts/partials/head.html#L30),
but I was not minimizing it.

[^deps-fix]: This blog, and my personal page were using
[Material UI CSS](https://www.muicss.com/) and [jquery](https://jquery.com/) 😱
for no real reason. 😅

[^preload]: Some resources are downloaded only when the browser reaches the
HTML page calling it, but [it is possible to pre-load](https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types/preload),
so that the files are ready to be used later on.

## Images: WebP, Animated WebP, and right-sizing
Since the Images were the heaviest elements loaded on the page, I started
working there. I decided to transform all my GIF, PNG, and JPEG to
[WebP images](https://en.wikipedia.org/wiki/WebP).[^webp-vs-]
I ran a few commands and updated my [Makefile](https://gitlab.com/koalalorenzo/blog/-/blob/dc77e8d2ae9d6de9db8fc23b4539aec6fc15cbb5/Makefile#L44) to do this automagically:

```bash
# Installing WebP tools on macOS
brew install webp

# converting PNGs and JPEGs to WebP
cwebp -short -q 85 ${FILENAME}.png -o ${FILENAME}.webp

# converting GIF to Animated WebP
gif2webp -mt -mixed -q 60 ${FILENAME}.gif -o ${FILENAME}.webp
```

These commands made some tangible improvements in file size, shrinking
**from several MB to a few kilobytes**.[^size-image-changes] That was already a
huge win because I love to use GIFs and memes in my posts! 😅

[^size-image-changes]: You can see [from this PR](https://gitlab.com/koalalorenzo/blog/-/merge_requests/4/diffs#3fa76e96f26c99e5110e368f3bbed165427a47e1) that when I started working on
moving to WebP, I reduced a lot the size of the images.

{{< image src="webp-gif-size-feature-center.webp" caption="Size matters too!">}}

To improve speed, WebP is not enough. The pages were loading big images
(around 5000x5000 pixels) for a tiny thumbnail space (approximately 300x300
pixels), and then the Browser would resize it after downloading.
Resizing the thumbnail to the proper size beforehand would help reduce the
dimensions to lower things.

Thankfully, Hugo can process images and resize/fit images to proper sizes
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

There are [a lot of functions that can be used to manipulate images](https://gohugo.io/content-management/image-processing/),
and I am very happy about it because it saved me a lot of commands to
run for each thumbnail! 😎

I made further changes to even use `srcset` for images to allow the browser to
load the right image, and resize it dynamically. You can check how I have done
it [here](https://gitlab.com/koalalorenzo/blog/-/blob/dc77e8d2ae9d6de9db8fc23b4539aec6fc15cbb5/layouts/shortcodes/image.html).

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

I also got rid of Disqus, in favor of [utteranc.es](https://utteranc.es) with
GitHub integration.

## Hugo bundles my JavaScript now!
My hugo website was bloated with a lot of almost useless Javascript, so I
decided to get rid of most of it, and bundle it, minimize it and enable the
scripts only if were in use.

To imprvoe the loading speed, I have decided to [preload the js bundle](https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types/preload),
so that the browser can fetch it a little before the js code is actually defined
and used. This improves speed a little, since the minimized bundle, changes
between a few pages.

Hugo provides some nice [Go Pipelines to do so](https://gohugo.io/hugo-pipes/bundling/).
I use it to always load [instantpage](https://instant.page), but enables
[TocBot](https://tscanlin.github.io/tocbot/) only on pages, and
[Mermaid](https://mermaid-js.github.io/mermaid/#/) only if the page uses it.

This is a useful snippet to bundle and minimize JS:

```html
{{ $instjs := resources.Get "js/instantpage.js" }}
{{ $tocbot := resources.Get "js/tocbot.js" }}
{{ $js := slice $instjs $tocbot | resources.Concat "js/bundle.js" | js.Build | minify | fingerprint }}

{{ if .Params.mermaid }}
  {{ $mermaidjs := resources.Get "js/mermaid.min.js" }}
  {{ $js = slice $instjs $mermaidjs $tocbot | resources.Concat "js/bundle.js" | js.Build | minify | fingerprint }}
{{ end }}

<script src="{{ $js.RelPermalink | absURL }}"></script>
```

If you are curious, you can check the full code of how I am bundling the
JavaScript code [here](https://gitlab.com/koalalorenzo/blog/-/blob/main/layouts/partials/scripts.html).

## Serving all these things together
It looks like FlyTap.com is served from Microsoft Windows Servers. 😱 I
personally would never use Microsoft Windows as Server or even Microsoft Azure.

Instead I have been using GitHub Pages, but then moved to GitLab Pages to
support Open Source projects[^why-use-gitlab]... but to turn it up to
eleven[^eleven], I have  decided to onboard to
[Cloudflare Pages](https://pages.dev).

Compared to GitHub and GitLab, Cloudflare Pages allows me to customize
the headers, redirects, and add serverless functions directly from my Hugo
setup:

[^eleven]: https://en.wikipedia.org/wiki/Up_to_eleven

[^why-use-gitlab]: Since Micosoft bought GitHub, I have moved my personal
                   projects to GitLab

```yaml
# File: _headers
/*
  Cache-Control: max-age=1209600, s-maxage=1209600, stale-if-error=600
  Cloudflare-CDN-Cache-Control: max-age=1209600, stale-if-error=600
  CDN-Cache-Control: 1209600, stale-if-error=600
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
```

Setting this up, is very important to me, as I can fine tune settings and
improve speed by better leveraging Cloudflare CDN, Edge Cache, and the
Browser's cache rules.

You can read more about this directly on
[Cloudflare Pages documentation](https://developers.cloudflare.com/pages/platform/headers)

## Conclusions
Although I cannot change TAP Airlines's website, their service, or their customer
support, I have learned a lot of things about optimizing websites while I was
waiting on my luggage. Most importantly I managed to:

* Replaced CSS and JS framework that I don't need with simpler lines of code
* Move all the images to WebP format to reduce the size used
* Bundled JS and CSS resources and loading them only when needed
* Improved speed by leveraging cache settings with Cache Control Headers

So what is the result? According to [GTMetrix](https://gtmetrix.com) reports: my
Homepage went from [883kb](homepage-old.webp) to just [252kb](homepage-new.webp)
(uncompressed), and my personal blog jumped from [879kb](blog-old.webp) kb to
[375kb](blog-new.webp) (uncompressed).

Comparing a personal blog with a few pages, with a much more complicated website
might not be looking fair, but generating a static website in the right way will
make it _scalable_.

Optimizing a **big SPA/static website** might not that difficult if we are using
the right technologies and the right setup. The CSS and JS files are bundled and
minimized by Hugo... but the big gain comes when considering Images are also
manipulated, resized and converted by Hugo! In other words: it is way easy to
add more content without having to think too much about the load speed, image
size and formats if Hugo does it. Providing the website on better servers than
Microsoft IIS and using CDN service helps with response time!

Using the right tecnologies and techniques may help FlyTAP to
provide a better user experience... Sadly that will not do anything about my
delayed luggage,
[1h phone calls](https://twitter.com/konikun/status/1474110357283164174?s=20&t=M0O7Pk4GwFnouuu9Y3Xjlw),
and non-existing customer support. 😅 I may know very little about airplanes but
I know a little more about making Hugo websites faster now!

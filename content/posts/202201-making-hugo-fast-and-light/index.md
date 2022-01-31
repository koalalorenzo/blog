---
title: "My Hugo blog now is fast and light"
date: 2022-01-31T19:05:41+01:00
tags:
  - hugo
  - webp
  - cache
  - cloudflare
  - javascript
  - css
  - software development
  - how to
---
This blog post is about what I have changed in my blog and website to make it
faster. Recently, I have traveled with a bad airplane company that delayed my
luggage. In the hope of getting my belongings back with me, I tried to use their
website and support pages, and I was frustrated every time. The primary source
of frustration was the website speed. So I decided to spend most of the time
without my luggage (around five days), trying to use best practices to improve
my website and blog, making my Hugo blog faster and way lighter than before.

<!--more-->

## The Investigations
On my way to Recife from Copenhagen, I realized that my luggage was stuck in
Copenhagen on a TAP Airplane. [My Apple AirTag](apple-airtag-tap-luggage.webp)
helped me, but I could not do much besides using an unusable website: FlyTAP.com

So I [inspected the website a little further](https://pagespeed.web.dev/report?url=http%3A%2F%2Fflytap.com%2F),
and I realized that the [FlyTAP.com homepage weighs around **17MB**](flytap.com-size.webp).
I had a lot of issues opening every single page on a _Hotel Wifi_. 😱
Using my 3G connection from my iPhone was an even worse experience.

{{< image src="flytap-speed.webp" caption="flytap.com GTMetrix tests results are awful" class="noborder big">}}

I do not want people browsing my homepage or blog to experience the same.
My blog was already light, but I know that I could improve it:

* There was a lot of unused CSS and JS code from different frameworks[^deps-fix]
* The CSS files were not minimized[^css-fix]
* The JavaScript code was not minimized nor bundled up
* Some resources were not pre-loaded[^preload] nor cached properly
* Images were the heavies elements

I started resolving all these issues to reduce the page size and the number of
connections and improve the speed, [Aiming for something below 512kb](http://512kb.club/).

I am lucky because [Hugo](https://gohugo.io) is the static engine that builds
this blog. Everything is orchestrated using GNU/Make. These two Open Source
tools made the changes easier to implement.

[^css-fix]: I am already building
[SCSS/SASS files into a single CSS file](https://gitlab.com/koalalorenzo/blog/-/blob/dc77e8d2ae9d6de9db8fc23b4539aec6fc15cbb5/layouts/partials/head.html#L30),
but I was not minimizing it.

[^deps-fix]: This blog and my personal page used
[Material UI CSS](https://www.muicss.com/) and [jquery](https://jquery.com/) 😱
for no real reason. 😅

[^preload]: Some resources are downloaded only when the browser reaches the
HTML page calling it, but [it is possible to pre-load](https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types/preload)
so that the files are ready to be used later on.

## Images: WebP, Animated WebP, and right-sizing
Since the Images were the heaviest elements loaded on the page, I started
working there. Earlier, I decided to transform all my GIF, PNG, and JPEG to
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
moving to WebP, I reduced the size of the images drastically.

{{< image src="webp-gif-size-feature-center.webp" caption="Size matters too!">}}

To improve speed, WebP is not enough. The blog homepage was loading big images
(around 5000x5000 pixels) for a tiny thumbnail space (approximately 300x300
pixels), and then the browser would resize it after downloading.
Resizing the thumbnail to the proper size beforehand would help reduce the
dimensions to increase the speed of rendering and transfer.

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

There are [a lot of functions to manipulate images](https://gohugo.io/content-management/image-processing/),
and I am happy about it because it saved me a lot of commands to run for each
thumbnail! 🤯 It scales as it does that for every new image.

I made further changes to even use `srcset` for images to allow the browser to
load the right image and resize it dynamically. You can check how I have done
it [here](https://gitlab.com/koalalorenzo/blog/-/blob/dc77e8d2ae9d6de9db8fc23b4539aec6fc15cbb5/layouts/shortcodes/image.html).

## Removing Material UI and jQuery
I can’t remember how long ago I started, but when building new HTML pages, I
have always been using a framework to save me time. Originally, it was
Bootstrap, but then I switched to some Material UI with MUI CSS, which comes
bundled with jQuery and some bloated fonts

When looking at the FlyTAP website, I noticed how many frameworks the homepage
loads: Angular, jQuery, Lodash, Mustache... [^tapwappalyzer]
It is a lot of repeated code to probably do similar things! I realized that **I
was using these frameworks for no good reason**: my Homepage was using the
old good Bootstrap and jQuery, just to have an animated avatar and a few divs
center[^center-div]. 😓

[^tapwappalyzer]: See the full list of tools used by TAP Airlines homepage
in [this CSV file](wappalyzer_flytap-com.csv)

[^center-div]: [Centering the div meme](https://www.reddit.com/r/ProgrammerHumor/comments/95z1xn/if_you_can_successfully_center_a_div_you_can/)

_After a deep breath_, I removed all of them. Then I wrote simple SASS/SCSS
and JavaScript and used fonts included in browsers. That removed many files!
That removed many files! 💪

I also got rid of Disqus in favor of [utteranc.es](https://utteranc.es) with
GitHub integration.

## Hugo bundles my SASS/SCSS and JavaScript now!
Even without Bootstrap, jQuery, or MUI, my Hugo website used multiple CSS and JS
files. Each file is a single HTTP request that takes time.

Hugo provides some nice [Go Pipelines to do so](https://gohugo.io/hugo-pipes/bundling/).
It works both with SASS/SCSS/CSS and JavaScript.

I use it to always load [instantpage](https://instant.page) and
[TocBot](https://tscanlin.github.io/tocbot/), but [Mermaid](https://mermaid-js.github.io/mermaid/#/)
is loaded only if the page uses it.

To improve the loading speed, I have decided to [preload the js bundle](https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types/preload)
so that the browser can fetch it slightly before the js code is actually defined
and used.

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

## Serving all these things together on CDN
It looks like FlyTap.com is served from Microsoft Windows Servers. 😱 I
personally would never use Microsoft Windows as a web server or even Microsoft
Azure after all the bad experiences I had at work.

Instead, I have been using GitHub Pages, but then moved to GitLab Pages to
support Open Source projects[^why-use-gitlab]... but to turn it up to
eleven[^eleven], I have decided to onboard to [Cloudflare Pages](https://pages.dev).

Compared to GitHub and GitLab, Cloudflare Pages allows me to **customize
the HTTP headers**, redirects, and add serverless functions directly from my
Hugo setup:

[^eleven]: https://en.wikipedia.org/wiki/Up_to_eleven

[^why-use-gitlab]: Since Microsoft bought GitHub, I have moved my personal
                   projects and CI/CD pipelines to GitLab

```yaml
# File: _headers
/*
  Cache-Control: max-age=1209600, s-maxage=1209600, stale-if-error=600
  Cloudflare-CDN-Cache-Control: max-age=1209600, stale-if-error=600
  CDN-Cache-Control: 1209600, stale-if-error=600
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
```

Setting this up is essential, as I can fine-tune settings and improve speed by
leveraging Cloudflare CDN, Edge Cache, and the browser's cache rules.

You can read more about this directly on
[Cloudflare Pages documentation](https://developers.cloudflare.com/pages/platform/headers).

## Conclusions
Although I cannot change TAP Airlines’s website, the service, or the customer
support, I have learned a lot of things about optimizing sites while I was
waiting on my luggage. Most importantly, I managed to:

* Replaced CSS and JS framework that I don’t need with way fewer lines of code
* Move all the images to WebP format to reduce the size used
* Learn that leaving an Apple AirTag in the luggage is a good idea 😜
* Bundled JS and CSS resources and loaded them only when needed
* Improved speed by leveraging cache settings with cache-control HTTP headers

So what is the result? According to [GTMetrix](https://gtmetrix.com) reports: my
Homepage went from [883kb](homepage-old.webp) to just [252kb](homepage-new.webp)
(uncompressed), and my personal blog jumped from [879kb](blog-old.webp) to
[375kb](blog-new.webp) (uncompressed).

Comparing a personal blog with a few pages with a much more complicated website
might not be looking fair, but generating a static website in the right way will
make it scalable.

Optimizing a big SPA/static website might not be difficult if we use the right
technologies and the proper setup. My website is hosted by better servers than
Microsoft IIS 🤦 and uses CDN service to help with response time.

The CSS and JS files are now bundled and minimized by Hugo... but the gain comes
when considering Images are also manipulated, resized, and converted by the
engine! In other words: it is way easy to add more content without having to
overthink about the load speed, image size, and formats if Hugo does it.

Using the right technologies and techniques may help FlyTAP provide a better
user experience... Sadly that will not do anything about my
delayed luggage,
[1h phone calls](https://twitter.com/konikun/status/1474110357283164174?s=20&t=M0O7Pk4GwFnouuu9Y3Xjlw),
and non-existing customer support. 😅 I may know very little about airplanes,
but I know a little more about making Hugo websites faster now! 🚀

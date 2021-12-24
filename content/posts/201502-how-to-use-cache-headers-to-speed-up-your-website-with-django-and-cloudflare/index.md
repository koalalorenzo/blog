---
author: koalalorenzo
comments: true
date: 2015-02-02 10:43:00+00:00
layout: post
slug: how-to-use-cache-headers-to-speed-up-your-website-with-django-and-cloudflare
title: How to use Cache Headers to speed up your website with Django and CloudFlare
wordpress_id: 18507
categories:
- Life online
- Work
- How To
tags:
- old blog
- django
- scale
- python
- cache
- cloud
- Cloudflare
- django-smartcc
- headers
- http
- minbildinbil
thumbnail: /images/2015/2015-01-01.webp
---

Since I started working at bigger startups, like [MinbilDinbil](http://minbildinbil.dk/), I had to face the problem of providing pages to a larger amount of users every day. For this reason, it is really important to use a CDN service like **CloudFlare**, in order to provide a good user experience on our website: we don't want our clients wait too much to load the homepage! How do we do that? <!-- more --> The author of GNU grep [once said](http://lists.freebsd.org/pipermail/freebsd-current/2010-August/019310.html):

> The key to making programs fast is to make them
> do practically nothing
_Mike Haertel, Sat Aug 21 2010.[^source] 

[^source]: http://lists.freebsd.org/pipermail/freebsd-current/2010-August/019310.html


So I decided to integrate our django servers with CloudFlare, improving the cache. [According to their documentation](https://support.cloudflare.com/hc/en-us/articles/202775670-How-Do-I-Tell-CloudFlare-What-to-Cache-), to enable the cache, the backend needs to provide **specific headers in the HTTP response**, like Cache-Control, Expires and others: by using these headers both the **browsers** and the CloudFlare **servers** will cache the file for a specific amount of time.

![](/images/2015/cf-logo-v-rgb.webp#noborder)

For this purpose, I created an **open source** customizable **middleware** to provide **cache headers** in a **smart way**. It is called [django-smartcc](https://github.com/koalalorenzo/django-smartcc) (standing for "smart cache control"). Once installed, it will start considering not authenticated requests as public and disabling the cache when the user is logged in. You can [read here the instructions](https://github.com/koalalorenzo/django-smartcc/blob/master/README.md#installation) to install it too:

```shell
pip install -U django-smartcc
```
I considered also that **not all the URLs should be cached at the same way**. The MinbilDinbil **API calls** are **cached differently**, as some other static files and pages are cached heavily, for example. For this reason the middleware is customizable with specific URL-based rules as described here:

```python
# settings.py
SCC_CUSTOM_URL_CACHE = (
    (r'/login/$', 'private', 0),
    (r'/api/search.json$', 'public', 300),
    (r'/downloads/contract.pdf', 'public', 900),
)
```
In this way the view at _/downloads/contract.pdf_ will return these HTTP Headers:


```shell
curl -I http://example.com/downloads/contract.pdf
```

Providing these results:

```shell
HTTP/1.1 200 OK
Server: cloudflare-nginx
Date: Sun, 01 Feb 2015 19:34:08 GMT
Content-Type: application/pdf
Connection: keep-alive
Vary: User-Agent, Accept-Language, Cookie
Expires: Sun 01 Feb 2015 19:49:08 GMT
Cache-Control: private, max-age=900
```

This is a basic example that is saying to both the browser and CloudFlare CDN to cache the file _contract.pdf_ for 15 minutes.



## Conclusion: Results and more suggestions.



The only way to measure and understand if the cache headers are working properly, is to compare CloudFlare statistics about the bandwidth and requests saved. When we started using CloudFlare on MinbilDinbil, the default settings were saving only a small quantity of requests:

![CloudFlare statistics](/images/2015/2015-01-01.webp)

Then **I enabled django-smartcc** and configured it properly on HTML pages and files. In the same amount of days, we saved about **one third** of our bandwidth to our servers:

![CloudFlare statistics when using django-smartcc to set automatically cache control HTTP headers.](/images/2015/2015-01-15.webp)

Thanks to this little trick our **user experience** is a little bit **improved**, as the **stability and speed**: basically, some pages are not provided by our django servers, but instead are downloaded from the **fast and distributed** content delivery network from **all around the world**. In other terms to make our server fast, it is doing _nothing_, as Mike Haertel, was saying!

Remember that **CloudFlare** says that their servers **are not caching the HTML** pages by default, and in case you need this feature you can [do it in the page rules](https://blog.cloudflare.com/introducing-pagerules-fine-grained-feature-co/)... but for the most of the static content it works perfectly. For this reason is important to set these headers also on your static files, and probably you really want to do that if you are using **Amazon S3**.

This is **not the only thing** that changed on MinbilDinbil website, and we are still making a better service every day. We also had to improve and _rewrite_ specific part of the code that was too slow or _RAM-hungry_, and we are not stopping doing that. For this reason **my suggestion** is to **not consider cache** as big solution to **speed problems**, but think about rewriting and **improving the code** when possible: otherwise the cache will be generated from a slow process anyway :-)

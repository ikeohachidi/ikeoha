---
tags: []
title: The need for a CSS library
description: Be cheerful without requiring others help
date: 2021-12-13T23:00:00.000+00:00
draft: false

---
I've been using Tailwind for the styling of my Vue component library, Tailwind. It's been great but after a little while i started to wonder if it was worth it.

I should mention CSS libraries are great they help out people who don't really know CSS that well or simply can't be bothered with writing a lot of styles themselves.

But on close inspection of my library i noticed the most used CSS classes were `padding` , `margin` and `flex` that's it and to be honest that's all I've been really using for most of my projects recently. I didn't use Tailwind's colours which by the way are fantastic because i had a set of colours i already planned to use, the other thing that i would have missed would have been CSS grids but i prefer using `flexbox` to `grid` for creating components anyway so it all worked out right for me.

So to solve this non-issue i created [kwik-css](https://github.com/ikeohachidi/kwik-css "Kwik"). Yes, another css library i know. But on close inspection you'll notice that it only comes with the most used(in my opinion) CSS classes: `margin`, `padding`, `display`, `position`.


---
tags:
- go
- nginx
title: Enhancing static assets load time on my app
description: Time is a river, glimpsed once and carried past
date: 2022-01-01T23:00:00Z
draft: true

---
Some information before we move on. My app is [chapi](https://chapihq.com "Chapi"), the frontend is built with Vue with tailwind for styling and the server is written in Go.

The entire Javascript bundle is compiled the Go server, which make the entire app to be able to run as a single binary.

When i pushed it to a production environment the app was incredibly slow, sometimes taking as far as 5 - 6 seconds to load, this is where my journey into increasing the performance of the app began.

First tailwind. Tailwind is large but it also provides purging, basically a way to remove the css classes you're not using in your app. Without configuring purging my CSS bundle was a massive `3000+kb` and with purging it dropped to `100+kb`. This small step offered significant improvement but i was curious to know how far i could push this.

I stumbled upon `Cache-Control` header on [MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching). 
Here i realised i could get a huge performance boost from just setting this header
```
Cache-Control: max-age=86000
```
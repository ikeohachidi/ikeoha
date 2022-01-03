---
tags:
- go
- nginx
title: Improving static assets load time on my app
description: Time is a river, glimpsed once and carried past
date: 2022-01-01T23:00:00.000+00:00
draft: false

---
Some information before we move on. My app is [chapi](https://chapihq.com "Chapi"), the frontend is built with Vue with tailwind for styling and the server is written in Go.

The entire Javascript bundle is compiled with the Go server, which make the entire app to be able to run as a single binary.

When i pushed it to a production environment the static assets took an incredible amount of time to load, sometimes taking as far as 5 - 6 seconds, this is where my journey into increasing the performance of the app began.

First tailwind. Tailwind is large but it also provides purging, basically a way to remove the css classes you're not using in your app. Without configuring purging my CSS bundle was a massive `3000+kb` and with purging it dropped to `100+kb`(Not fantastic, but not `3MB`). This small step offered significant improvement but i was curious to know how far i could push this.

I stumbled upon `Cache-Control` header on [MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching).

    Cache-Control: max-age=86400

From reading the MDN article adding the header above when serving static assets from my Go backend would suffice. The `max-age=86400` sets the content to be valid for 24 hours, after that it becomes stale and fetches again.

Worthy of note though is that while debugging Response headers using Chrome dev tools i noticed that Google uses `Cache-Control: max-age=86400 stale-while-revalidate=604800` for google fonts responses.
This particular value isn't documented on the great MDN docs but here's a page i found that explains it
[Google stale-while-revalidate](https://web.dev/stale-while-revalidate/).
The gist of it though is that if the cache isn't stale yet based on `max-age` set. The browser simply fulfills the request using the cache and does nothing with the `stale-while-revalidte` value, but if it's stale then the `stale-while-revalidate` value checks if the stale response is still within the time it covers. If it is then it still serves the cached response while also non obtrusively revalidating the cache and updating if necessary.
Basically, the advantage of this is that if the cache is stale you don't have to wait like you would.

This would be enough but i run an Nginx server in front of my Go server. So following another great article [Nginx Caching](https://www.nginx.com/blog/nginx-caching-guide/), i added the following configuration.

    proxy_cache_path /home/chidi/Work/nginx_cache levels=1:2 keys_zone=nginx_cache:10m max_size=5g inactive=10m use_temp_path=off;
    
    server {
    	listen 80 default_server;
    	listen [::]:80 default_server;
    
    	location / {
    		# First attempt to serve request as file, then
    		# as directory, then fall back to displaying a 404.
    		# proxy_redirect http://localhost/ http://localhost:5000/; 
    		proxy_cache nginx_cache;
    		proxy_cache_revalidate on;
    		proxy_cache_use_stale error timeout http_500 http_502 http_503 http_504;
       }
       
    }

The Nginx article goes into greater detail about what the `proxy_*` directives do. But to summarize what the Nginx configuration does:

- `proxy_cache_path` sets the location of the cache on the machine.
- `proxy_cache` sets the cache to use
- `proxy_cache_revalidate` This revalidates the assets agains the origin server if the asset has become stale
- `proxy_cache_use_stale` Returns the cached file if the origin server returns a specified `5**` error.

**NOTE** The `proxy_cache_use_stale` was a bit of a controversial decision tbh. See the files built with VueJS are always hashed, e.g `dashboard-<random string>.js`. And on every new build the js file for dashboard will change but the browser will still receive the old content because of this. I still took the tradeoff though because the Frontend has come to a stable version and the `max-age` set on `Cache-Control` it'll get revalidated and then updated every 24 hrs.

And that's that! With these changes i was able to get a significant performance boost.
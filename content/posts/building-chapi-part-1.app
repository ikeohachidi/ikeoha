---
tags:
- programming
title: Building Chapi Part(1)
description: Man suffers more in his imagination
date: 2021-07-06T23:00:00Z
draft: false

---
Honestly this shouldn't be part 1 as there might never even be a part 2 but who knows. 

Over the past month i've been building an App which is a HTTP Tunneler or Proxy, i'm really not sure, the definitions for both of those terms have a tendency to become really blurry.

My tech stack for this will be my trusty Vue, Golang, Postgres(SQLite to test out some things in development).

The idea for this project came from a friend who was trying to use an API which required a private key seeing as my friend is a frontend dev with little to no backend experience he got stuck.  **See you can't keep something like a private key in your Javascript code because it can easily be found and you don't want to wake up and see an email with half of your net worth gone.**

So why not, it's a good idea it may not propel me to becoming one of the richest people in my country or street for that matter but it seems like fun and **So we code**.

The should be simple with a very simple plan

* Chike has a request that requires a private key
* He sets up a project on chapi **(projects contain proxies)**
* He setups a request config on chapi with the private key and whatever else he needs
* Chapi spits out a url Chike hits 
* Chapi is the middle man that makes the request and sends it back to Chike

So you see it's simple and should be easy to execute if the programming gods and senior developer Google are kind to a brother.
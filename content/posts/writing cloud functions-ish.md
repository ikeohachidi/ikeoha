---
tags: ['systems design']
title: Rough idea for implementing cloud functions
description: Waste no time arguing what a good man should be, be one.
date: 2024-03-10T23:00:00Z
draft: false

---

First things first, i haven't even tried any of these ideas i'm going to express on this page at the moment but i want
to write about them anyway.
So I've been building something(hopefully i don't abandon this one too). It's a forward proxy "of sorts". Basically, it
allows a client to make a request to fetch some protected resource or with some private key securely. An example of what
i mean by this is something like using a payment gateway. Stripe and/or Paystack, last i used it provided a private key
which needed to be stored on some backend. I didn't want to have a to run a backend server just to hide a key and forward
a request from my frontend client to the Paystack api. My service solves that for the next man.

So while the core of everything has been built, by core i mean the request forwarding, I want to allow users to be able 
to run functions on those requests. It could be a function like transforming the request, or making another request before 
returning the response. So basically functions.

So here's a thought I have on how to accomplish cloud functions, i have looked into how firebase does this, but can't find
any information about how they do it. So i'll assume the key here could be containers.

Important information that may be found useful is my app has a project and a project has multiple requests under it.

### So here is the idea
##### Developer creating a function
![](/screenshot-from-2024-03-10-01-52-47.png)
- Devs write their functions on the frontend and save it.
- This function gets stored on the functions server(Context: There is another server which handles the forwarding)
- How on the functions server?
  - Well this is an example of what the payload would look like
    ```json
    {
      "projectId": "some-project-id",
      "requestId": "some-request-id",
      "fnName": "myFunction",
      "fnDefinition": "function action() {// code here}"
    }
    ```
  - The function is saved in a folder with the created path `projectId/requestId/fnName.js`


##### How is the function executed

First things first, these functions will run before or after a request has been run and the functions would in fact
be called by the forwarding server
![](/screenshot-from-2024-03-10-01-53-00.png)
- Forwarding server makes a request to functions server with the response returned from hitting the resource. This is assuming
  the user decided the function runs after the request.
- The function is run with a context argument that has the response and some of the data from running the origin forwarding
  request.
- The response is send to the forwarding server which in turn returns the response the the client.
  
Now this seems reasonable, but there is a big issue: We don't want to be able to just run any javascript code on the functiopns
server. This has the potential to be a huge security risk.
So the functions need to be run in isolation, okay docker then, we spin up a docker container for every function, execute 
the function and return the response. This makes sense in theory buuuuuuuuuut, from running `docker stats` i can see that
my node container is using approx 80MB of memory, to be fair it's running a frontend server using doing hot module reloading,
so this may be less or more when running a node server(likely more).
But taking 80MB as the baseline, if i have 20(lol, i wish) functions running i'll need 1.6GBs of memory. I'm too broke
for that but it's nice to know though. So now i'll just concentrate on finding alternatives.

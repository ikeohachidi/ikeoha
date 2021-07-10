---
title: Use Namecheap domain with EC2 instance with Route53.
description: You never know where life may take you
tags:
  - aws
  - devops
date: 2020-07-29T12:11:20.709Z
draft: false
---
I've been working on [fontkit](https://github.com/ikeohachidi/fontkit-web) for a while now and i felt it's time to get a domain name. I headed on over to namecheap to get a domain name and got fontkt.net, .com was $4,000 🙄.
I decided to use AWS for this, i haven't used it before so now seemed to be a good time to get up to date.
Note, you can actually buy a domain from AWS with Route53, i didn't know this, not sure i would have still cared though, namecheap is cool.

Okay let's get to the "How to" part.
I'll assume you have a namecheap account and an AWS account with an EC2 instance already created.

* Search for Route53 on your services, click that, go there.
* Create a new hosted zone with the name of the domain you just bought on namecheap.
* Once created you should see your domain hosted among the hosted zones on the page. Click on the domain name. Now you should see "Nameservers" with a list of what seem to be domains. Note them.
* In your namecheap account, click on "domain list" and click on your domain
* Scroll down to "NAMESERVERS", you should see "Namecheap BasicDNS", change that to the Nameservers which you see on your Route53 hosted zone. Once done click on the blue check marker and all done.
* Wait a little, Great things take time, sometimes.
* Now click on your domain name hosted record, click on "Create Record", then choose "Simple Routing", click next.
* Now you should see a page asking you to "Define simple record", click that, 
* In the popup window
* Record Name:  you can leave record name empty, unless you need a subdomain.
* Value traffic to: change that to "Ip Address"
* Record Type: leave to be "A record"
* Click on define simple record. On the next popup window, add the Public IPv4 address of your EC2 instance. 
* Wait a little an voila you should be ready.

Confused? I messed up? Comment below, i'll do my best to reply as sharply as possible.
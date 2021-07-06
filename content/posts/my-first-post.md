---
title: Reading Zack Schollz's hostyoself codebase
description: An effort at self improvement
tags:
  - go
  - deep dive
  - code read
  - websocket
date: 2020-05-14T17:56:46.301Z
draft: false
---
For the past few weeks  I've been practicing my code reading. So during my search for a Github Repo which i may find interesting enough to read, i stumbled upon a post on Reddit promoting [hostyoself](hostyoself.com). Hostyoself is a website which allows you to host flies from your machine online. I'm a web developer and i found this interesting as i had absolutely no idea how to implement something like this.

Luckily for me the entire source code for the project is available on Github so, Thank God!!

Here's what i found out after reading through the source code.

## Let's begin

Note: i put some of the code explanations as comments in the code

Upon startup of the CLI and running \`go run *.go h\` (opens help)

```
COMMANDS
  relay     start a relay
  host      host files from your computer
  help, h   shows a list of commands or help for one command
  
 relay OPTIONS:
   --url value, -u   value public url to use(default: "localhost")
   --p
---
title: "Elixir Notes: My majestic entrance into Elixir's Phoenix framework"
description: Obula chyse
tags:
  - Elixir
date: 2020-11-23T12:04:28.901Z
draft: false
---
So I've been on elixir for about a month now and i'm liking it. Why Elixir though? Well i kept on stumbling on different articles saying functional programming is where it's at now, so yeah, I've gotten into elixir out of sheer curiosity and boredom.

Now to Phoenix, phoenix is the go to framework for building webapps on Elixir. Seeing as I'm something of a web developer my self I said why not.

So here's a gentle introduction to Phoenix. Mind you the docs are really good as is every doc for anything Elixir I've encountered.

1. Create a phoenix project with:  `mix phx.new <project name>`
   
   The command will create a new phoenix project with all it's dependencies. Phoenix kind of ironically depends on NodeJS' webpack to build static assets. So you'll get a prompt asking if you should install dependencies. Just say yes, why not?

2. Run phoenix project: cd into folder and run `mix phx.server'

   This command will startup your phoenix project on localhost:4000.

   Running that command hopefully resulted in errors on your console. Well that's because out of the box Phoenix uses Postgres as it's default database.

  So what to do is cd into `<project directory>/config`, there you should find a file `dev.exs`, there is a line `config :elixir_app, ElixirApp.Repo,` under that is a username and password, change that to your Postgres username and password. I have no idea how to use a different database yet, so I'm pretty lucky I generally use Postgres.


## Explaining basic level folder structure
The most important folders I've noticed so far to note are `config, assets, lib`

The assets folder contains static assets like CSS, and JavaScript files.

The config folder contains files used for configuring the project for development or production mode. Noteworthy so far is the `dev.exs` file which contains config values necessary for connecting to a database and also a http port to attach to.

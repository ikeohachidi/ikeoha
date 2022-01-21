---
tags: []
title: An idea for creating an SQL "friends" relationship
description: Look back over the past, with its changing empires that rose and fell,
  and you can foresee the future too
date: 2022-01-20T23:00:00Z
draft: true

---
Recently been experimenting with (Supabase)[https://supabase.com] and it's been a great experience so far. Supabase is a firebase alternative, like AppWrite but it actually uses Postgres under the hood.
I've been working on an experimental chat app just to try out some ideas and concepts. The app is written in React not my usual Vue and Supabase.
The chat app has a requirement before two people can communicate at least one of the users in the conversation must have accepted a "contact" request.
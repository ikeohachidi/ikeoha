---
title: Concurrency for the layman
description: Waste no more time arguing what a good man should be. Be one.
tags: [Go, concurrency]
date: 2021-09-10T15:58:10.944Z
draft: false
---
According to Wikipedia: Concurrency is the abililty of different parts of a program, algorithm or problem to be executed out-of-order or in partial order without affecting the final outcome. This can be easily confused with parallelism.

Let me break it down further, in concurrency many tasks are handled not necessarily sequentially but not simultaneously. The biggest difference between them is interruptability.

Still confused? Then maybe an analogy might help. Say maybe you’re babysitting two babies let’s call them Carl and Karen, You start changing Carl’s diaper midway Karen starts crying for milk so you halt Carl’s diaper change and go give Karen milk. That halt in activity is the interruptability i talked about earlier and that scenario is a concurrent one. Now If you were to have another person be able to change Carl’s diaper while you give Karen her milk AT THE SAME TIME then you have successfully achieved parallelism.  

Further Reading i found particularly useful, Read the answer by Methos [here](https://stackoverflow.com/questions/1050222/what-is-the-difference-between-concurrency-and-parallelism)
>

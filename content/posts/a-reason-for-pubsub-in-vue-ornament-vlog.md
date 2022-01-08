---
tags:
- typescript
- javascript
title: A reason for pubsub in Vue (Ornament Vlog)
description: Breathe consistently
date: 2022-01-07T23:00:00Z
draft: false

---
**NOTE** I only explain the implementaiton details of pub in javascript and don't go full into code

Yes, still on my Vue 3 component library project [Ornament](https://github.com/ikeohachidi/ornament-ui). Before i begin i should say hobby projects are the best. They push you to get in depth knowledge of the thing you're building and the tools you've decided to build it with.

Now that's aside, i recently wanted to add a vertical menu component o Ornament. Most of the CSS and Javascript(Vue) were pretty straightforward but i ran into an interesting problem.

See it's important to emit some events from the component to allow the user take some actions in certain cases but the problem is the `vertical-menu` component can be as nested as possible obviously to have a smoother developer experience i simply allowed the structure of the `vertical-menu` be created with an Array of nested arrays.

**Example**
The developer supplies the following array
```
const menu = [
	{	text: 'User',
     	children: [
        	{ text: 'Delete }, // this child node can still have children too
            { text: 'Edit } // this child node can still have children too
        ]
    },
    {	text: 'Settings',
     	children: [
        	{ text: 'Auth }, // this child node can still have children too
            { text: 'Profile } // this child node can still have children too
        ]
    }
]
```

The code above then uses the array above to create the UI component on the screen when the user does the following in `html` code
```
<or-vertical-menu :menu="menu"/>
```

Under the hood the component recursively goes through the `menu` structure and creates this:
```
<or-vertical-menu>
  <or-vertical-menu>
  	<or-vertical-menu>
  	<or-vertical-menu/>
  <or-vertical-menu/>
  
  <or-vertical-menu>
    <or-vertical-menu>
    <or-vertical-menu/>
  <or-vertical-menu/>
<or-vertical-menu/>
```
And this can go as deep as possible. So the challenge is how do i push up the event for the developer consuming the component to listen to it. One approach would be to listen to the event on a node and keep recursively emitt it to all parent nodes. But i don't like that, it'll pollute my `vue-devtools` inspector. So i went with implementing my own pubsub.

PubSub is something i've heard of and got the idea of but never really had a reason to use in a project.
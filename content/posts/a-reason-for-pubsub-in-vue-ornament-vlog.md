---
tags:
- typescript
- javascript
title: A reason for pubsub in Vue - Ornament Blog
description: Breathe consistently
date: 2022-01-07T23:00:00Z
draft: false

---
**NOTE** I only explain the implementaiton details(more like pseudo code) of pubsub in javascript and don't go full into code tutorial. The actual code can be found here [use-shared-event](https://github.com/ikeohachidi/ornament-ui/blob/main/src/utilities/use-shared-event.ts).

Yes, still on my Vue 3 component library project [Ornament](https://github.com/ikeohachidi/ornament-ui). Before i begin i should say hobby projects are the best. They push you to get in depth knowledge of the thing you're building and the tools you've decided to build it with.

Now that's aside, i recently wanted to add a vertical menu component to Ornament. Most of the CSS and Javascript(Vue) were pretty straightforward but i ran into an interesting problem.

See it's important to emit some events from the component to allow the user take some actions in certain cases but the problem is the `vertical-menu` component can be as nested as possible obviously to have a smoother developer experience i simply allowed the structure of the `vertical-menu` be created with an Array of nested arrays.

**Example**
The developer supplies the following array

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

Then the `menu` variable above is used to create the UI component on the screen when the developer does the following:

    <or-vertical-menu :menu="menu"/>

Under the hood the component recursively goes through the `menu` structure and creates something similar to this:

    <or-vertical-menu>
      <node>
      	<node>
      	<node>
      <node/>
      
      <node>
        <node>
        <node/>
      <node/>
    <or-vertical-menu/>

At each node there will be an event `node-click` that gets emitted when that node is clicked and that event can be consumed by the developer to perform some action.
The problem is when a `node` that is 5 levels deep gets clicked it'll have to recursively go up it's tree 5 times and each step of the way it'll fire the `node-click` for each node. This i imagine would be a pain to debug and it'll totally mess up my `vue-devtools`.

In short PubSub is short for publish subscribe. Basically, Somewhere there's something listening for an event(subscriber) and when the event goes off(published) the listener performs some action.
So i just had to subscribe to my event in the top layer of my `vertical-menu` and then any child node that publishes an event goes directly to my subscriber and not up the tree first.

#### Implementaion

**Full code here**: [use-shared-event](https://github.com/ikeohachidi/ornament-ui/blob/main/src/utilities/use-shared-event.ts)

A simple pubsub API api would look something like this:

```javascript
// subscriber
emit(<event>).listen(callback)

// publisher
emit(<event>).push(value)
```

**NOTE** `<event>` is used as a placeholder for an event name.
So how is this really implemented? Under the hood we'll create an `events` which takes an array of objects. Each key in the object would be the name of the event and the value would be an array of functions.

    const events = {
    	likePicture: [Function, Function, Function]
    }

When a user runs `emit(<event>).listen(callback)` we check if there's a key corresponding that `<event>` name in our `events` array. If there isn't then we initialize the object with the `<event>` as the key and a value of `[Function]`. Functions are first class values in javascript so they can be passed around.

```javascript
// code cut for brevity
listen(callback) {
 	const event = events[<event>];
    event.push(callback)
}
```

When a user finally hits `emit(<event>).push(value)`, we simply simple get the `<event>` array from `event` with `events[<event>]`, iterate over it and then fun the callback functions passing the `value` as the argument to the `callback`.

```javascript
// code cut for brevity
push(value) {
  const listeners = events[<event>];
  for (const listener of listeners) {
    listener(value)
  }
}
```
---
tags:
- vue
- vue3
- typescript
- frontend
title: Implementing a vue clickaway with vue 3 composables
description: A ship in harbor is safe, but that is not what ships are built for.
date: 2021-12-09T23:00:00Z
draft: false

---
I've been working on [Ornament UI](https://github.com/ikeohachidi/ornament-ui "Ornament Ui") lately and while creating a dropdown component i wanted the basic effect of clicking away from the component to hide it. Easy enough there's a vue directive `vue-clickaway` that solves this with very few lines of code. So i used `vue-clickaway` but then i couldn't build the documentation website anymore because of some SSR errors when using the package.

This got me thinking deeply about choices i was making for my component library like: Do i really want to depend on that `vue-clickaway` package, Do i really want to depend on `tailwind `(More on this later).

So i decided to give this a go, shouldn't really be a complicated problem to solve.

**Problem**
- Clicking away from the element should hide it
- Clicking on a child of the element shouldn't hide it

**First Solution**
```typescript
const useClickAway = (parentEl: HTMLElement, callback: Function) => {
	window.addEventListener('click', (event: Event) => {
		const target = event.target as Element;
		if (!target) return;

		parentEl.outerHTML.includes(target.outerHTML) ? () => {} : callback();
	})
}
```

This is a very simple solution to the problem. With `<Element>.outerHTML`we can basically "stringify" html elements and with that we can check if one element exists inside another. Eg.
```html
<div id="outer">
  Outer
  <div id="inner">
    Inner
  </div>
</div>
```
So we pass the element with an id of `outer` as the first argument to our `useClickAway` function and pass a callback as the second. The callback would have the code to hide our dropdown.
So if the element with an id of `inner` is clicked our function the `click` event we listen to on the 2nd line will fire and check if the element with `inner` id is included insde the element with the id `outer`.

The downside to this approach is that if we have an identical `inner` id element that isn't a child of `outer` it'll still fire our callback. So next is a more thourough solution to the problem.

**Second Solution**
```typescript
const useClickAway = (parentEl: HTMLElement, callback: Function) => {
	window.addEventListener('click', (event: Event) => {
		const target = event.target as Element;
		if (!target) return;

		isElementChild(target, parentEl) ? () => {} : callback();
	})
}

const isElementChild = (target: Element, element: Element): boolean => {
	if (target.isSameNode(element)) return true;

	if (element.hasChildNodes()) {
		for (const child of Array.from(element.children)) {
			if (isElementChild(target, child)) return true;
		}
	}

	return false;
}
```

Here with the `isElementChild` function we are recursively going throught the tree nodes of the parent element and checking if the clicked node exists within it. The obvious downfall to this being that it's recursive so for a very large DOM node there'd be a performance hit.
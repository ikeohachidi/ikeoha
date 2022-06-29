---
tags:
- CSS
- " media queries"
- " responsive"
title: Towards understanding CSS media queries
description: Your progress is probably on the other side of the work you're avoiding
date: 2022-06-30T06:19:00Z
draft: false

---
## Honestly, it's just about min-width and max-width

#### min-width

The CSS rules are applied if a screen is **greater or equal** to the specified size.
E.g: Given the CSS style rule
```css
 @media (min-width: 360px) {
 	div#okay {
 		border: 1px solid blue;
 	}
 }
```
The above style will only be applied to `#okay` if the screen is **greater or equal** to `360px`.
So visually it can be seen as
```
0px <---------------|360px|---------------->
	   Not applied		 	    Applied
```
#### max-width

The CSS rules are applied when a screen is at **lesser or equal** to the specified size.
E.g: Given the CSS style rule
```css
@media (max-width: 360px) {
	div#okay {
		border: 1px solid blue;
	}
}
```

The above style will only be applied until the screen the reaches the specified width.
This can be visually represented as:
```css
0px <---------------|360px|---------------->
	   Applied		 	      Not Applied
```

### Description for the non-technical

**min-width**: Don't add the style rule until the screen is at least the specified size.

**max-width**: Add the style rule until the screen size reaches the specified width.

### Application during development

`min-width` is used when doing **mobile-first** styling while `max-width` is used for \`desktop-first**.

To further explain this take the following style rules:
```css
p {
  color: blue;
}

@media (min-width: 360px) {
  p {
  	color: red;
  }
}
```

This can be visually represented as:
```css
0px <---------------|360px|---------------->
color: blue		 	  color: red
```

This would be considered a `mobile-first` approach because the default style of the `p` tag is only applied when the screen is small and changes once the increases in size towards a large(desktop) screen.
    
Now alternatively consider this style rule:
```css
p {
	color: blue;
}

@media (max-width: 360px) {
	p {
		color: red;
	}
}
```
This can be visually represented as:
```css
0px <---------------|360px|---------------->
	   color: red		 	  color: blue
```

This is a `desktop-first` approach because the default style for the `p` tag only applies to a desktop screen and the changes once the screen reduces towards a smaller(mobile) screen.
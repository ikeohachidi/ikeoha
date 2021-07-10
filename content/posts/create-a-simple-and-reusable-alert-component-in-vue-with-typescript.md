---
title: Create a simple and reusable alert component in Vue with Typescript
description: You could leave life right now. Let that determine what you do and say and think.
tags:
  - vuejs
  - vue
  - typescript
  - javascript
date: 2020-08-27T21:58:09.767Z
draft: false
---
I've been working on my side Project [fontkit](fontkit.net)(not ready yet) for sometime now and I've been putting off creating an alert component. The project is getting to a good enough place and i felt it would be time to create one.

The Goals where simple

-   Single Import
-  Simple function to either display a success message or a failure message

Getting started
I won't talk about installing vue typescript with the vue-cli , i'll make the hopefully not too stupid assumption that if you're here you already know how to do that.

1st the component should be called from any other component without being imported first into that component. To achieve this we need to create an emitter that can be listened to globally
So in your `main.ts` file at the root of the vue app, add the code beween the `add me` and `add me end` comment.
```
import Vue from 'vue';
import App from './App.vue';

// add me
Vue.prototype.$eventBus = new Vue();
// add me end

new Vue({
  render: h => h(App)
}).$mount('#app')
```

2nd an Alert component is needed
So create an `Alert.vue` component

```javascript
<template>
    <!-- the alertWrapper class keeps the component at the top of the page and has a simple animation too -->
    <section  class="alertWrapper" ref="alertWrapper">
        <!-- we want appropriate colors depending on the kind of alert we get -->
	    <div :class={'fail': alertBox.type === 'fail', 'success': alertBox.type === 'success'}>
		    {{ alertBox.text }}
	    </div>
    </section>
</template>

<script lang='ts'>
import {Vue, Component} from  'vue-property-decorator';

type AlertMessage = {
	text: string;
	type: 'fail' | 'success';
}

@Component
export default class Alert extends Vue {
	alertBox: AlertMessage = {
		text: '',
		type: 'fail'
	}	

	mounted() {
	    // the Alert component will listen for a global 'alert' event and will act accordingly
	    // displaying the component and hiding it after 5 seconds
		this.$eventBus.$on('alert', ($event:  AlertMessage) => {
			const alertWrapper = (this.$refs['alertWrapper'] as Element);
			if ($event.text !== '' && ($event.type === 'success' || $event.type === 'fail')) {
				this.alertBox.type = $event.type;
				this.alertBox.text = $event.text;

				alertWrapper.classList.add('toggle')

                // hide the alert element after 5 seconds
				setTimeout(() => {
					alertWrapper.classList.remove('toggle')
				}, 5000)
			}
		})
	}
}
</script>

<style scoped>
.alertWrapper {
    position: absolute;
    top: 0;
    width: 100%;
    top: 0;
    z-index: 40;
    transform: translateY(-100%);
	opacity: 0;
	transition: 0.5s;
}

.alertWrapper.toggle {
	opacity: 1;
	transform: translateY(0);
}

.success {
    background-color: green;
}

.fail {
    background-color: red;
}
</style>
```

Now we call the `alert` event from another component.
So create a random component, call it whatever you like, i'll call mine `AlertCaller.vue`
```
<script lang='ts'>
import {Vue, Component} from  'vue-property-decorator';

export class AlertCaller extends Vue {
    mounted() {
        // emit the alert event
        this.$eventBus.$emit('alert', {
            type: 'success',
            text: 'We taking over baby'
        })
    }
}
<script>
```
Now if you run this you'll get a typescript error saying something like `Property '$eventBus' does not exist on type 'AlertCaller'`, to fix this we'll augument our existing types with [module augumentation](https://vuejs.org/v2/guide/typescript.html#Augmenting-Types-for-Use-with-Plugins).
So create another file `event.d.ts`(you can name it whatever you want) in the root of our app and add the following
```typescript
import Vue from 'vue';

declare module 'vue/types/vue'  {
    interface Vue {
        $eventBus: Vue ;
    }
}
```
Restart your vue-cli and you're off.
While this works well as it is, it'll be very tiring to keep writing the code on the `mounted` lifecycle of the `AlertCaller` component everytime we need an alert. So we can further abstract this away. To do this add the following code between the `add me` and `add me end` comment in your `main.ts` file.
```typescript
import Vue from 'vue';
import App from './App.vue';

Vue.prototype.$eventBus = new Vue();
// add me
Vue.prototype.$sAlert = (text: string) => {
  Vue.prototype.$eventBus.$emit('alert', {
    type: 'success',
    text 
  })
}
Vue.prototype.$fAlert = (text: string) => {
  Vue.prototype.$eventBus.$emit('alert', {
    type: 'fail',
    text 
  })
}
// add me end

new Vue({
  render: h => h(App)
}).$mount('#app')
```
And then add the following beween the `add me` and `add me end` comment in `event.d.ts` file. It'll fix any typescript error you may get.
```typescript
import Vue from 'vue';

declare module 'vue/types/vue'  {
    interface Vue {
        $eventBus: Vue ;
        // add me
        $sAlert: (text: string) => void;
        $fAlert: (text: string) => void;
        // add me end
    }
}
```

Now the code in `mounted` lifecycle of the `AlertCaller` component can be replaced with with this
```typescript
mounted() {
    // for success alert 
    this.$sAlert('We taking over baby')
    
    // for failure alert 
    this.$sAlert('No we not')
}
```

If you made it this far, thank you. Please if you have any contribution or some tips to better the quality of my writing please i urge you to  reach out. Thanks again.




























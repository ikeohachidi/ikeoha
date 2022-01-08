<template>
    <ul class="page-width mx-auto">
        <li><nuxt-link to="/">ikeoha.com</nuxt-link></li>
        <li><nuxt-link to="/post">posts</nuxt-link></li>
        <li><a href="https://github.com/ikeohachidi" target="_blank">projects</a></li>

        <li class="ml-auto" @click="goToExternalPage('github')">
            <i class="ri-github-fill ri-lg"></i>
            <span class="ml-2">Github</span>
        </li>
        <li @click="goToExternalPage('twitter')">
            <i class="ri-twitter-fill ri-lg"></i>
            <span class="ml-2">Twitter</span>
        </li>
    </ul>
</template>

<script>
export default {
    methods: {
        goToExternalPage(page) {
            if (page === 'github') window.open('https://github.com/ikeohachidi', '_blank');
            if (page === 'twitter') window.open('https://twitter.com/ikeoha_chidi', '_blank');
        }
    }
}
</script>

<style lang="postcss" scoped>
ul {
    @apply flex py-4;
}

ul li:first-of-type {
    @apply font-bold pl-0 pr-4;
} 

ul li {
    @apply px-4 flex items-center cursor-pointer;;
}
</style>
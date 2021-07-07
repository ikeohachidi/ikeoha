<template>
    <ul class="page-width mx-auto">
        <li><nuxt-link to="/">ikeoha.com</nuxt-link></li>
        <li><nuxt-link to="/post">posts</nuxt-link></li>
        <li><nuxt-link to="/projects">projects</nuxt-link></li>
    </ul>
</template>

<style lang="postcss" scoped>
ul {
    @apply flex py-4;
}

ul li:first-of-type {
    @apply font-bold pl-0 pr-4;
} 

ul li {
    @apply px-4;
}
</style>
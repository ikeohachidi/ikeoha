<template>
    <section>
        <div class="bg-dark">
            <Navbar/>
            <div class="page-width mx-auto mt-20 pb-20">
                <h1 class="text-2xl font-bold">{{ post.title }}</h1>
                <p class="mt-4 text-gray-200">{{ post.description }}</p>
            </div>
        </div>

        <article class="page-width mx-auto mt-20">
            <nuxt-content :document="post"/>
        </article>
    </section>
</template>

<script>
export default {
    async asyncData({ $content, params }) {
        const post = await $content('posts', params.slug).fetch()

        return {post}
    }
}
</script>
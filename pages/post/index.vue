<template>
    <section>
        <Navbar/>
        <div class="page-width mx-auto">
            <h1 class="text-3xl font-bold mb-8 mt-20 mb-10 text-gray-900">Posts</h1>

            <ul>
                <li v-for="post in posts" :key="post.slug" class="w-100 mb-5">
                    <p class="font-bold text-lg text-gray-900">
                        <NuxtLink :to="{ name: 'post-slug', params: { slug: post.slug } }">
                            {{ post.title }}
                        </NuxtLink>
                        <span class="text-gray-500 text-xs italic ml-3">{{ timeFormat(post.date) }}</span>
                    </p>
                    
                    <p class="text-gray-600 text-base font-light">{{ post.description }}</p>
                </li>
            </ul>
        </div>
    </section>
</template>

<script>
import { timeFormat } from '@/utils/date';

export default {
    methods: {
        timeFormat(time) {
            return timeFormat(time)
        }
    },
    async asyncData({ $content, params }) {
        const posts = await $content('posts')
            .only(['title', 'description', 'slug', 'date'])
            .where({ draft: false })
            .sortBy('date', 'desc')
            .fetch()

        return { posts }
    }
}
</script>
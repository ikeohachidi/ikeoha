<template>
  <div>
    <div class="page-width mx-auto mt-20">
      <ul>
        <li
          v-for="(project, index) in projects"
          :key="index"
        >
          <h1>{{ project.title }}</h1>
          <p class="links">
            <a v-if="project.github" target="_blank" :href="project.github">
              <i class="ri-github-fill"></i>
              Github
            </a>
            <a v-if="project.live" target="_blank" :href="project.live" class="animate-pulse">
              <i class="ri-flashlight-fill"></i>
              Go live
            </a>
          </p>
          <p>{{ project.description }}</p>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  data () {
    return {
      projects: [
        {
          title: 'Foreq',
          inDevelopment: true,
          live: 'https://foreq.dev',
          github: '',
          description: 'Foreq is a dead simple forward proxy created with the intention of making third party request integration easier without the hassle of server provisioning'
        },
        {
          title: 'Github static viewer',
          inDevelopment: false,
          live: 'https://gh-static.ikeoha.xyz',
          github: 'https://github.com/ikeohachidi/live-editor',
          description: 'View static websites in github repos effortlessly without cloning locally'
        },
        {
          title: 'Live editor',
          inDevelopment: false,
          live: 'https://live-editor.ikeoha.xyz',
          github: 'https://github.com/ikeohachidi/live-editor',
          description: 'Edit html, css, sass, javascript and typescript and see changes in realtime, Inspired by Codepen'
        }
      ]
    }
  }
}

</script>

<style lang="postcss" scoped>
li {
  @apply mb-10;
}

li h1 {
  @apply mb-2;
}

li a {
  @apply inline-flex items-center mr-5;
  @apply text-purple-600;
}

li a i {
  @apply inline-block mr-1;
}
</style>

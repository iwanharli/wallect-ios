<template>
  <div class="wallect-app">
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup>
const { checkAuth } = useAuth()
onMounted(checkAuth)
</script>

<style>
/* Global Transitions */
.page-enter-active,
.page-leave-active {
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}
.page-enter-from,
.page-leave-to {
  opacity: 0;
  filter: blur(10px);
  transform: translateY(20px);
}

/* Base Styles */
body {
  margin: 0;
  padding: 0;
  background-color: var(--bg-deep);
}

.wallect-app {
  min-height: 100vh;
}
</style>

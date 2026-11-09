<script setup>
// Redirect root to dashboard
definePageMeta({
  middleware: [
    function (to, from) {
      return navigateTo('/dashboard', { redirectCode: 301 })
    }
  ]
})
</script>

<template>
  <div>Redirecting to dashboard...</div>
</template>

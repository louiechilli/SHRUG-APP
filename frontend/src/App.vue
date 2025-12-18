<script setup lang="ts">
    import { onMounted } from 'vue'
import { useAuthStore } from './stores/auth'

const auth = useAuthStore()


onMounted(() => auth.bootstrap())
</script>

<template>
  <div class="min-h-[100svh] flex flex-col bg-white">
    <main>
      <RouterView />
    </main>
  </div>
</template>
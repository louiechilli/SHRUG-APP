<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const route = useRoute()
const auth = useAuthStore()

const title = computed(() => {
  if (route.name === 'dashboard') return 'Dashboard'
  if (route.name === 'login') return 'Log in'
  if (route.name === 'register') return 'Create account'
  return 'Vocal'
})
</script>

<template>
  <header
    class="sticky top-0 z-10 bg-white backdrop-blur"
    :style="{ paddingTop: 'env(safe-area-inset-top)' }"
  >
    <div class="mx-auto flex w-full max-w-md items-center justify-between px-4 py-3">
      <div class="min-w-0">
        <p class="text-xs font-semibold uppercase tracking-wide text-slate-500">Vocal</p>
        <h1 class="truncate text-base font-semibold text-slate-900">{{ title }}</h1>
      </div>

      <nav class="flex items-center gap-2">
        <RouterLink
          v-if="!auth.token"
          to="/login"
          class="rounded-lg px-3 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-100"
        >
          Log in
        </RouterLink>
        <RouterLink
          v-if="!auth.token"
          to="/register"
          class="rounded-lg bg-slate-900 px-3 py-2 text-sm font-semibold text-white hover:bg-slate-800"
        >
          Sign up
        </RouterLink>
        <RouterLink
          v-else
          to="/dashboard"
          class="rounded-lg px-3 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-100"
        >
          Account
        </RouterLink>
      </nav>
    </div>
  </header>
</template>



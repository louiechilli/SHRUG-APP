<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useAuthStore } from '../stores/auth'
import api from '../services/api'

const auth = useAuthStore()

const apiStatus = ref<'loading' | 'connected' | 'disconnected'>('loading')

onMounted(async () => {
  try {
    await api.get('/status')
    apiStatus.value = 'connected'
    console.log('API status:', apiStatus.value)
  } catch {
    apiStatus.value = 'disconnected'
    console.log('API status:', apiStatus.value)
  }
})
</script>

<template>
  <section class="space-y-4">
    <div class="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <p class="text-sm font-semibold text-slate-500">Mobile-first Vue + Laravel starter</p>
      <h2 class="mt-1 text-2xl font-bold tracking-tight text-slate-900">Vocal</h2>
      <p class="mt-2 text-sm text-slate-600">
        SPA + PWA shell, versioned API, and token auth out of the box.
      </p>

      <div class="mt-4 flex items-center gap-2 text-sm">
        <span class="rounded-full px-2 py-1 text-xs font-semibold" :class="{
          'bg-slate-100 text-slate-700': apiStatus === 'loading',
          'bg-emerald-100 text-emerald-800': apiStatus === 'connected',
          'bg-rose-100 text-rose-800': apiStatus === 'disconnected',
        }">
          API: {{ apiStatus }}
        </span>
        <span class="text-xs text-slate-500">GET /api/v1/status</span>
      </div>
    </div>

    <div class="grid gap-3">
      <RouterLink
        v-if="!auth.token"
        to="/register"
        class="block rounded-2xl bg-slate-900 px-5 py-4 text-center text-sm font-semibold text-white shadow-sm hover:bg-slate-800"
      >
        Create account
      </RouterLink>
      <RouterLink
        v-if="!auth.token"
        to="/login"
        class="block rounded-2xl bg-white px-5 py-4 text-center text-sm font-semibold text-slate-900 shadow-sm ring-1 ring-slate-200 hover:bg-slate-50"
      >
        Log in
      </RouterLink>
      <RouterLink
        v-else
        to="/dashboard"
        class="block rounded-2xl bg-white px-5 py-4 text-center text-sm font-semibold text-slate-900 shadow-sm ring-1 ring-slate-200 hover:bg-slate-50"
      >
        Go to dashboard
      </RouterLink>
    </div>
  </section>
</template>



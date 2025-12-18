<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { handleCallback } from '../services/workos'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()

const error = ref<string | null>(null)

onMounted(async () => {
  const code = route.query.code as string
  const state = route.query.state as string

  if (!code) {
    error.value = 'No authorization code received'
    return
  }

  try {
    const { user, accessToken } = await handleCallback(code, state)
    auth.setToken(accessToken)
    auth.user = user
    router.replace('/dashboard')
  } catch (e: any) {
    error.value = e.message ?? 'Authentication failed'
  }
})
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-b from-blue-900 via-purple-800 to-rose-500">
    <div class="text-center text-white">
      <div v-if="error" class="bg-red-500/20 rounded-lg px-6 py-4">
        <p class="text-red-200">{{ error }}</p>
        <RouterLink to="/login" class="mt-4 inline-block underline">Back to login</RouterLink>
      </div>
      <div v-else>
        <div class="animate-spin w-8 h-8 border-4 border-white border-t-transparent rounded-full mx-auto mb-4"></div>
        <p>Signing you in...</p>
      </div>
    </div>
  </div>
</template>


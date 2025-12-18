<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const auth = useAuthStore()

const name = ref('')
const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const error = ref<string | null>(null)
const loading = ref(false)

async function submit() {
  error.value = null
  loading.value = true
  try {
    await auth.register({
      name: name.value,
      email: email.value,
      password: password.value,
      password_confirmation: passwordConfirmation.value,
    })
    await router.replace('/dashboard')
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? 'Registration failed.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <section class="space-y-4">
    <div class="rounded-2xl bg-white p-5 shadow-sm ring-1 ring-slate-200">
      <h2 class="text-lg font-bold text-slate-900">Create account</h2>
      <p class="mt-1 text-sm text-slate-600">This creates a user and returns an API token.</p>

      <form class="mt-4 space-y-3" @submit.prevent="submit">
        <label class="block">
          <span class="text-sm font-semibold text-slate-700">Name</span>
          <input
            v-model="name"
            type="text"
            autocomplete="name"
            required
            class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm outline-none focus:border-slate-400"
            placeholder="Your name"
          />
        </label>

        <label class="block">
          <span class="text-sm font-semibold text-slate-700">Email</span>
          <input
            v-model="email"
            type="email"
            autocomplete="email"
            required
            class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm outline-none focus:border-slate-400"
            placeholder="you@example.com"
          />
        </label>

        <label class="block">
          <span class="text-sm font-semibold text-slate-700">Password</span>
          <input
            v-model="password"
            type="password"
            autocomplete="new-password"
            required
            minlength="8"
            class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm outline-none focus:border-slate-400"
            placeholder="At least 8 characters"
          />
        </label>

        <label class="block">
          <span class="text-sm font-semibold text-slate-700">Confirm password</span>
          <input
            v-model="passwordConfirmation"
            type="password"
            autocomplete="new-password"
            required
            minlength="8"
            class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm outline-none focus:border-slate-400"
            placeholder="Repeat password"
          />
        </label>

        <p v-if="error" class="rounded-xl bg-rose-50 px-4 py-3 text-sm text-rose-800">
          {{ error }}
        </p>

        <button
          type="submit"
          class="w-full rounded-xl bg-slate-900 px-4 py-3 text-sm font-semibold text-white shadow-sm hover:bg-slate-800 disabled:opacity-60"
          :disabled="loading"
        >
          {{ loading ? 'Creating…' : 'Create account' }}
        </button>
      </form>
    </div>

    <p class="text-center text-sm text-slate-600">
      Already have an account?
      <RouterLink to="/login" class="font-semibold text-slate-900 underline underline-offset-4">Log in</RouterLink>
    </p>
  </section>
</template>



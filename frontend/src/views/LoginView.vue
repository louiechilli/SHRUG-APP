<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { loginWithGoogle as workosGoogle, loginWithApple as workosApple } from '../services/workos'
import DesktopLayout from '../layouts/DesktopLayout.vue'
import MobileLayout from '../layouts/MobileLayout.vue'

const router = useRouter()

const loading = ref(false)

function loginWithGoogle() {
  loading.value = true
  workosGoogle()
}

function loginWithFacebook() {
  console.log('Facebook login - not implemented')
}

function loginWithApple() {
  loading.value = true
  workosApple()
}

function loginWithEmail() {
  router.push('/register')
}

// SVG icon paths
const icons = {
  google: `<path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>`,
  facebook: `<path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>`,
  apple: `<path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>`,
  email: `<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>`,
  phone: `<rect x="5" y="2" width="14" height="20" rx="2" stroke-width="2"/><line x1="12" y1="18" x2="12" y2="18" stroke-width="3" stroke-linecap="round"/>`,
  menu: `<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>`
}
</script>



<template>
  <!-- Desktop Layout -->
  <DesktopLayout>
    <!-- Header -->
    <header class="absolute top-0 left-0 right-0 flex items-center justify-between px-8 py-6 z-10">
      <div class="flex items-center gap-1">
        <div class="w-12 h-12 bg-white rounded-xl flex items-center justify-center">
          <img src="/shrug_man_logo.png" alt="Vocal" class="w-32 h-12">
        </div>
        <img src="/shrug_logo_text.svg" alt="Vocal" class="w-32 h-12 fill-white">
      </div>
      <div class="flex items-center gap-4">
        <button class="flex items-center gap-2 bg-white/20 hover:bg-white/30 text-white px-5 py-2.5 rounded-full transition">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" v-html="icons.phone"></svg>
          Get App
        </button>
        <button class="text-white p-2">
          <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24" v-html="icons.menu"></svg>
        </button>
      </div>
    </header>

    <!-- Main Content -->
    <div class="flex-1 flex items-center justify-center px-8 relative z-10">
      <div class="flex items-center gap-16 max-w-6xl w-full">
        <!-- Left Side - Text & Login -->
        <div class="flex-1 max-w-md">
          <h1 class="text-white text-5xl font-black leading-tight mb-6 text-left uppercase">
            Chat with random people. <br> Or don't. <br> <span class="text-yellow-400">Whatever.</span>
          </h1>
          <p class="text-center text-lg text-white/80 italic mb-8">Today, you might meet someone who collects spoons.</p>

          <!-- Google Button -->
          <button @click="loginWithGoogle" :disabled="loading" class="w-full bg-white hover:bg-gray-50 text-gray-700 font-semibold py-4 px-6 rounded-full flex items-center justify-center gap-3 transition shadow-lg">
            <svg class="w-6 h-6" viewBox="0 0 24 24" v-html="icons.google"></svg>
            Connect with Google
          </button>

          <!-- Divider -->
          <div class="flex items-center gap-4 my-6">
            <div class="flex-1 h-px bg-white/30"></div>
            <span class="text-white/70 text-sm">OR</span>
            <div class="flex-1 h-px bg-white/30"></div>
          </div>

          <!-- Social Buttons -->
          <div class="flex justify-center gap-4 mb-6">
            <button @click="loginWithFacebook" class="w-14 h-14 bg-white hover:bg-gray-50 rounded-full flex items-center justify-center shadow-lg transition">
              <svg class="w-7 h-7 text-[#1877F2]" fill="currentColor" viewBox="0 0 24 24" v-html="icons.facebook"></svg>
            </button>
            <button @click="loginWithApple" class="w-14 h-14 bg-white hover:bg-gray-50 rounded-full flex items-center justify-center shadow-lg transition">
              <svg class="w-7 h-7 text-black" fill="currentColor" viewBox="0 0 24 24" v-html="icons.apple"></svg>
            </button>
            <button @click="loginWithEmail" class="w-14 h-14 bg-white hover:bg-gray-50 rounded-full flex items-center justify-center shadow-lg transition">
              <svg class="w-7 h-7 text-[#00B4D8]" fill="none" stroke="currentColor" viewBox="0 0 24 24" v-html="icons.email"></svg>
            </button>
          </div>

          <!-- Terms -->
          <p class="text-white/80 text-xs leading-relaxed">
            By clicking this, you agree to our <a href="#" class="underline">Terms Of Service</a>, 
            <a href="#" class="underline">Privacy Policy</a>
            and the possibility of meeting someone who owns a haunted doll. You must be 18+ and mildly okay with chaos.
          </p>

          <p v-if="error" class="mt-4 text-red-200 text-sm bg-red-500/20 rounded-lg px-4 py-2">{{ error }}</p>
        </div>

        <!-- Right Side - Video Preview -->
        <div class="flex-1 max-w-xl">
          <div class="bg-white/20 backdrop-blur-sm rounded-3xl p-3 shadow-2xl">
            <div class="flex rounded-2xl overflow-hidden">
              <video src="https://data.monkey.app/web-cdn/neo/login.mp4" class="w-full object-cover h-100" autoplay muted loop />
            </div>
          </div>
        </div>
      </div>
    </div>
  </DesktopLayout>

  <!-- Mobile Layout -->
  <MobileLayout>
    <!-- Header -->
    <header class="flex items-center justify-between px-5 py-4 relative z-10">
      <div class="flex items-center gap-1">
        <div class="w-12 h-12 bg-white rounded-xl flex items-center justify-center">
          <img src="/shrug_man_logo.png" alt="Vocal" class="w-32 h-12">
        </div>
        <img src="/shrug_logo_text.svg" alt="Vocal" class="w-32 h-12 fill-white">
      </div>
      <div class="flex items-center gap-3">
        <button class="bg-white/20 hover:bg-white/30 text-white p-2.5 rounded-xl transition">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" v-html="icons.phone"></svg>
        </button>
        <button class="text-white p-2">
          <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24" v-html="icons.menu"></svg>
        </button>
      </div>
    </header>

    <!-- Video Preview -->
    <div class="flex-1 flex flex-col items-center justify-center px-5 py-6 relative z-10">
      <h1 class="text-white text-3xl font-black leading-tight mb-6 text-center uppercase">
        Chat with random people. <br> Or don't. <span class="text-yellow-400">Whatever.</span>
      </h1>
      <p class="text-center text-lg text-white/80 italic mb-8">Today, you might meet someone who collects spoons.</p>

      <div class="bg-white/20 backdrop-blur-sm rounded-3xl p-2 shadow-2xl w-full max-w-sm">
        <div class="flex rounded-2xl overflow-hidden">
          <video src="https://data.monkey.app/web-cdn/neo/login.mp4" class="w-full object-cover h-100" autoplay muted loop />
        </div>
      </div>
    </div>

    <!-- Bottom Section -->
    <div class="px-5 pb-8 pt-4 relative z-10">
      <!-- Google Button -->
      <button @click="loginWithGoogle" :disabled="loading" class="w-full bg-white hover:bg-gray-50 text-gray-700 font-semibold py-4 px-6 rounded-full flex items-center justify-center gap-3 transition shadow-lg">
        <svg class="w-6 h-6" viewBox="0 0 24 24" v-html="icons.google"></svg>
        Connect with Google
      </button>

      <!-- Divider -->
      <div class="flex items-center gap-4 my-5">
        <div class="flex-1 h-px bg-white/30"></div>
        <span class="text-white/70 text-sm">OR</span>
        <div class="flex-1 h-px bg-white/30"></div>
      </div>

      <!-- Social Buttons -->
      <div class="flex justify-center gap-5 mb-5">
        <button @click="loginWithFacebook" class="w-16 h-16 bg-white hover:bg-gray-50 rounded-full flex items-center justify-center shadow-lg transition">
          <svg class="w-8 h-8 text-[#1877F2]" fill="currentColor" viewBox="0 0 24 24" v-html="icons.facebook"></svg>
        </button>
        <button @click="loginWithApple" class="w-16 h-16 bg-white hover:bg-gray-50 rounded-full flex items-center justify-center shadow-lg transition">
          <svg class="w-8 h-8 text-black" fill="currentColor" viewBox="0 0 24 24" v-html="icons.apple"></svg>
        </button>
        <button @click="loginWithEmail" class="w-16 h-16 bg-white hover:bg-gray-50 rounded-full flex items-center justify-center shadow-lg transition">
          <svg class="w-8 h-8 text-[#00B4D8]" fill="none" stroke="currentColor" viewBox="0 0 24 24" v-html="icons.email"></svg>
        </button>
      </div>

      <!-- Terms -->
      <p class="text-white/80 text-xs leading-relaxed text-center">
        By clicking this, you agree to our <a href="#" class="underline">Terms Of Service</a>, 
        <a href="#" class="underline">Privacy Policy</a>
        and the possibility of meeting someone who owns a haunted doll. You must be 18+ and mildly okay with chaos.
      </p>

      <p v-if="error" class="mt-4 text-red-200 text-sm bg-red-500/20 rounded-lg px-4 py-2">{{ error }}</p>
    </div>
  </MobileLayout>
</template>

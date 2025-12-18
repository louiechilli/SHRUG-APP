<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'

type BeforeInstallPromptEvent = Event & {
  prompt: () => Promise<void>
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed' }>
}

const deferredPrompt = ref<BeforeInstallPromptEvent | null>(null)
const dismissed = ref(false)

const isStandalone = computed(() => {
  // iOS Safari: navigator.standalone; other browsers: display-mode
  const anyNav = navigator as any
  return (
    window.matchMedia?.('(display-mode: standalone)')?.matches === true ||
    anyNav?.standalone === true
  )
})

const canInstall = computed(() => !!deferredPrompt.value && !dismissed.value && !isStandalone.value)

function onBeforeInstallPrompt(e: Event) {
  e.preventDefault()
  deferredPrompt.value = e as BeforeInstallPromptEvent
}

async function install() {
  if (!deferredPrompt.value) return
  await deferredPrompt.value.prompt()
  await deferredPrompt.value.userChoice
  deferredPrompt.value = null
  dismissed.value = true
}

function dismiss() {
  dismissed.value = true
}

onMounted(() => window.addEventListener('beforeinstallprompt', onBeforeInstallPrompt))
onBeforeUnmount(() => window.removeEventListener('beforeinstallprompt', onBeforeInstallPrompt))
</script>

<template>
  <div
    v-if="canInstall"
    class="px-4 pb-4"
  >
    <div class="mx-auto w-full max-w-md rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
      <div class="flex items-start gap-3">
        <div class="mt-1 h-10 w-10 shrink-0 rounded-xl bg-slate-900 text-white">
          <div class="flex h-full w-full items-center justify-center text-sm font-bold">V</div>
        </div>
        <div class="min-w-0">
          <p class="text-sm font-semibold text-slate-900">Install Vocal</p>
          <p class="mt-0.5 text-sm text-slate-600">Add to your home screen for faster access and offline support.</p>
          <div class="mt-3 flex gap-2">
            <button
              type="button"
              class="inline-flex items-center justify-center rounded-xl bg-slate-900 px-4 py-2 text-sm font-semibold text-white hover:bg-slate-800"
              @click="install"
            >
              Install
            </button>
            <button
              type="button"
              class="inline-flex items-center justify-center rounded-xl px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-100"
              @click="dismiss"
            >
              Not now
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>



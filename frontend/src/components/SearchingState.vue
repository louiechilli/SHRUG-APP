<script setup lang="ts">
import EmojiSwitcher from './EmojiSwitcher.vue'

defineProps<{
  currentEmojiIndex: number
}>()
</script>

<template>
  <div class="searching-state">
    <EmojiSwitcher :current-index="currentEmojiIndex" />
    <p class="searching-text">Looking for someone...</p>
  </div>
</template>

<style scoped>
.searching-state {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1.5rem;
  z-index: 5;
}

.searching-text {
  color: white;
  font-size: 1.25rem;
  font-weight: 600;
}
</style>


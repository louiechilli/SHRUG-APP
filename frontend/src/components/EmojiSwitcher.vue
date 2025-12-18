<script setup lang="ts">
defineProps<{
  currentIndex: number
}>()
</script>

<template>
  <div class="emoji-switcher">
    <img v-show="currentIndex === 0" src="/assets/emojis/shrug.png" alt="">
    <img v-show="currentIndex === 1" src="/assets/emojis/man-shrugging.png" alt="">
    <img v-show="currentIndex === 2" src="/assets/emojis/woman-shrugging.png" alt="">
  </div>
</template>

<style scoped>
.emoji-switcher {
  position: relative;
  width: 80px;
  height: 80px;
  
  img {
    width: 80px;
    height: 80px;
    animation: fadeIn 0.3s ease;
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}
</style>


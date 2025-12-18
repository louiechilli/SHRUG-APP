<script setup lang="ts">
</script>

<template>
  <div class="chat-container">
    <slot />
  </div>
</template>

<style scoped>
.chat-container {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  margin: auto;
  height: 60%;
  width: 70%;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 10px;
  backdrop-filter: blur(5px);
  -webkit-backdrop-filter: blur(5px);
  padding: 10px;
  display: flex;
  flex-direction: row;
  gap: 10px;
}

@media (max-width: 1224px) {
  .chat-container {
    width: 90%;
  }
}

@media (max-width: 1024px) {
  .chat-container {
    width: 100vw;
    height: 100vh;
    padding: 0;
  }
}
</style>


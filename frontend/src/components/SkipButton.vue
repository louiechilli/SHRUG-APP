<script setup lang="ts">
const emit = defineEmits<{
  skip: []
}>()
</script>

<template>
  <button class="skip-btn" @click="emit('skip')">
    <img src="/assets/emojis/fast_forward.png" alt="">
  </button>
</template>

<style scoped>
.skip-btn {
  position: absolute;
  bottom: 10px;
  right: 10px;
  width: 50px;
  height: 50px;
  padding: 8px;
  cursor: pointer;
  border-radius: 12px;
  box-sizing: border-box;
  background-color: rgba(0, 0, 0, 0.5);
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s;
}

.skip-btn:hover {
  background: rgba(59, 130, 246, 0.8);
}

.skip-btn img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

@media (max-width: 1024px) {
  .skip-btn {
    bottom: unset;
    top: 10px;
  }
}
</style>


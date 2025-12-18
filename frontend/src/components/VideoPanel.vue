<script setup lang="ts">
defineProps<{
  type: 'host' | 'guest'
}>()
</script>

<template>
  <div class="video-panel" :class="type === 'host' ? 'host-panel' : 'guest-panel'">
    <slot />
  </div>
</template>

<style scoped>
.video-panel {
  width: 100%;
  height: 100%;
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

.host-panel {
  background-color: black;
  padding: 0;
}

.host-panel :deep(.host-video) {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.guest-panel {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 16px;
  backdrop-filter: blur(5px);
  -webkit-backdrop-filter: blur(5px);
}

@media (max-width: 1023px) {
  .video-panel {
    border-radius: 0;
  }
}
</style>


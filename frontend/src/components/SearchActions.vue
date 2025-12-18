<script setup lang="ts">
defineProps<{
  genderIcon: string
  genderLabel: string
}>()

const emit = defineEmits<{
  toggleGender: []
  cancel: []
}>()
</script>

<template>
  <div class="search-actions">
    <button class="search-action-btn" @click="emit('toggleGender')">
      <img :src="genderIcon" alt="" class="btn-icon">
      {{ genderLabel }}
    </button>
    <button class="search-action-btn" @click="emit('cancel')">Cancel</button>
  </div>
</template>

<style scoped>
.search-actions {
  position: absolute;
  bottom: 2rem;
  left: 0;
  right: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 0 3rem;
  z-index: 10;
}

.search-action-btn {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 25px;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  
  img {
    height: 2rem;
  }
}

.search-action-btn:hover {
  background: rgba(255, 255, 255, 0.3);
}

.btn-icon {
  height: 1.5rem;
  width: 1.5rem;
}
</style>


<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  selectedGender?: string
  loading?: boolean
}>()

const emit = defineEmits<{
  startCall: []
  toggleBoth: []
}>()

const genderLabel = computed(() => {
  switch (props.selectedGender) {
    case 'girls': return 'Girls Only'
    case 'guys': return 'Guys Only'
    default: return 'Both'
  }
})

const genderIcon = computed(() => {
  switch (props.selectedGender) {
    case 'girls': return '/assets/icon-female.png'
    case 'guys': return '/assets/icon-male.png'
    default: return '/assets/icon-both.png'
  }
})
</script>

<template>
  <div class="pre-call-action">
    <button class="action-btn secondary" role="button" @click="emit('toggleBoth')" :disabled="loading">
      <img :src="genderIcon" alt="">
      {{ genderLabel }}
    </button>
    <button class="action-btn primary" role="button" @click="emit('startCall')" :disabled="loading">
      <span v-if="loading" class="spinner"></span>
      <template v-else>Start Video Call</template>
    </button>
  </div>
</template>

<style scoped>
.pre-call-action {
  position: absolute;
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 10px;
  bottom: 2rem;
  padding: 0 3rem;
}

.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
  border: 2px solid #422800;
  border-radius: 10px;
  box-shadow: #422800 4px 4px 0 0;
  color: #422800;
  cursor: pointer;
  font-weight: 600;
  font-size: 18px;
  padding: 0 18px;
  width: 100%;
  line-height: 50px;
  text-align: center;
  user-select: none;
  -webkit-user-select: none;
  touch-action: manipulation;
}

.action-btn img {
  height: 2rem;
}

.action-btn.primary {
  background-color: #fdfb4c;
  min-height: 50px;
}

.action-btn.primary:hover {
  background-color: #eeeb46;
}

.action-btn.secondary {
  background-color: #ffffff;
}

.action-btn.secondary:hover {
  background-color: #f0f0f0;
}

.action-btn:active {
  box-shadow: #422800 2px 2px 0 0;
  transform: translate(2px, 2px);
}

@media (min-width: 768px) {
  .action-btn {
    min-width: 120px;
    padding: 0 25px;
  }
}

@media (max-width: 1023px) {
  .action-btn {
    height: 4rem;
  }
}

.action-btn:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.spinner {
  width: 20px;
  height: 20px;
  border: 3px solid #422800;
  border-top-color: transparent;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>


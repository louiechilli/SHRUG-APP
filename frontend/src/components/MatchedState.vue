<script setup lang="ts">
import type { ApiUser } from '../stores/auth'

const props = defineProps<{
  peerUser: ApiUser | null
}>()

const pronoun = props.peerUser?.gender === 'female' ? "She's" : props.peerUser?.gender === 'male' ? "He's" : "They're"
</script>

<template>
  <div class="matched-state">
    <div class="matched-avatar">
      <img :src="peerUser?.avatar || '/assets/emojis/wave.png'" alt="">
    </div>
    <h2 class="matched-title">Meet {{ peerUser?.name || 'Someone' }}!</h2>
    <p class="matched-info" v-if="peerUser?.age || peerUser?.location">
      {{ pronoun }} {{ peerUser?.age || '?' }} from {{ peerUser?.location || 'somewhere' }}
    </p>
    <div class="connecting-dots">
      <span></span>
      <span></span>
      <span></span>
    </div>
  </div>
</template>

<style scoped>
.matched-state {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  animation: fadeIn 0.3s ease;
  z-index: 5;
}

.matched-avatar {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  overflow: hidden;
  border: 3px solid rgba(255, 255, 255, 0.5);
  
  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.matched-title {
  color: white;
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0;
  text-align: center;
}

.matched-info {
  color: rgba(255, 255, 255, 0.8);
  font-size: 1.1rem;
  margin: 0;
  text-align: center;
}

.connecting-dots {
  display: flex;
  gap: 8px;
  margin-top: 1rem;
  
  span {
    width: 10px;
    height: 10px;
    background: white;
    border-radius: 50%;
    animation: bounce 1.4s infinite ease-in-out both;
  }
  
  span:nth-child(1) {
    animation-delay: -0.32s;
  }
  
  span:nth-child(2) {
    animation-delay: -0.16s;
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.9);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

@keyframes bounce {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}
</style>


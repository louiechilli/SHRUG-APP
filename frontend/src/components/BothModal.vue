<script setup lang="ts">
import { ref } from 'vue'
import Modal from './Modal.vue'

defineProps<{
  open: boolean
}>()

const emit = defineEmits<{
  close: []
  save: [gender: string]
}>()

const selectedGender = ref('both')

function save() {
  emit('save', selectedGender.value)
  emit('close')
}
</script>

<template>
  <Modal :open="open" @close="emit('close')">
    <!-- Premium Banner -->
    <!-- <div class="premium-banner">
      <span class="crown">👑</span>
      <div class="premium-text">
        <strong>Vocal Plus</strong>
        <span>Get More Gender Filters</span>
      </div>
      <button class="join-btn">Join</button>
    </div> -->

    <!-- Gender Section -->
    <div class="section">
      <div class="section-header">
        <span>🕹️</span>
        <span>Gender. <p class="text-sm text-gray-500 italic mb-0 font-normal">Yes, there are only two...</p></span>
      </div>
      
      <div class="gender-options">
        <button 
          class="gender-btn" 
          :class="{ active: selectedGender === 'girls' }"
          @click="selectedGender = 'girls'"
        >
          <img src="/assets/icon-female.png" alt="Girls Only" class="gender-btn-icon">
          <span>Girls Only</span>
        </button>
        <button 
          class="gender-btn" 
          :class="{ active: selectedGender === 'guys' }"
          @click="selectedGender = 'guys'"
        >
          <img src="/assets/icon-male.png" alt="Guys Only" class="gender-btn-icon">
          <span>Guys Only</span>
        </button>
        <button 
          class="gender-btn" 
          :class="{ active: selectedGender === 'both' }"
          @click="selectedGender = 'both'"
        >
          <img src="/assets/icon-both.png" alt="Both" class="gender-btn-icon">
          <span>Both</span>
        </button>
      </div>
    </div>

    <div class="footer-actions">
      <button class="save-btn" @click="save">Save</button>
    </div>
  </Modal>
</template>

<style scoped>
.premium-banner {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  width: 100%;
  padding: 0.75rem 1rem;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  border-radius: 12px;
  margin-bottom: 1.5rem;
}

.crown {
  font-size: 2rem;
}

.premium-text {
  display: flex;
  flex-direction: column;
  flex: 1;
  text-align: left;
}

.premium-text strong {
  color: white;
  font-size: 1rem;
}

.premium-text span {
  color: rgba(255, 255, 255, 0.8);
  font-size: 0.8rem;
}

.join-btn {
  background: #facc15;
  color: #422800;
  border: none;
  padding: 0.5rem 1.5rem;
  border-radius: 20px;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.2s;
}

.join-btn:hover {
  background: #eab308;
}

.section {
  width: 100%;
  margin-bottom: 1.5rem;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 700;
  font-size: 1.1rem;
  color: #1f2937;
  margin-bottom: 1rem;
}

.gender-options {
  display: flex;
  gap: 0.75rem;
}

.gender-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 1rem 0.5rem;
  background: #f9fafb;
  border: 2px solid #e5e7eb;
  border-radius: 2rem;
  cursor: pointer;
  aspect-ratio: 1;
  transition: all 0.2s;
}

.gender-btn:hover {
  background: #f3f4f6;
}

.gender-btn.active {
  border-color: #6366f1;
  background: white;
}

.gender-btn-icon {
  width: 4rem;
  height: 4rem;
}

.gender-btn span:last-child {
  font-size: 0.85rem;
  color: #6366f1;
  font-weight: 500;
}

.footer-actions {
  display: flex;
  gap: 0.75rem;
  width: 100%;
}

.save-btn {
  flex: 1;
  background: #6366f1;
  color: white;
  border: none;
  padding: 1rem;
  border-radius: 12px;
  font-weight: 700;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.2s;
}

.save-btn:hover {
  background: #4f46e5;
}

.globe-btn {
  width: 56px;
  height: 56px;
  background: white;
  border: 2px solid #6366f1;
  border-radius: 12px;
  font-size: 1.5rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s;
}

.globe-btn:hover {
  background: #f3f4f6;
}
</style>

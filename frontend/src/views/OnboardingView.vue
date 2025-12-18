<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import api from '../services/api'

const router = useRouter()
const auth = useAuthStore()

const gender = ref<'male' | 'female' | 'other' | null>(null)
const birthdate = ref('')
const saving = ref(false)
const error = ref('')

const isValid = computed(() => gender.value && birthdate.value)

const minDate = computed(() => {
  const d = new Date()
  d.setFullYear(d.getFullYear() - 100)
  return d.toISOString().split('T')[0]
})

const maxDate = computed(() => {
  const d = new Date()
  d.setFullYear(d.getFullYear() - 18)
  return d.toISOString().split('T')[0]
})

async function save() {
  if (!isValid.value) return
  saving.value = true
  error.value = ''
  try {
    await api.put('/auth/me', { gender: gender.value, birthdate: birthdate.value })
    await auth.fetchMe()
    router.replace('/dashboard')
  } catch (e: any) {
    const errors = e?.response?.data?.errors
    if (errors?.birthdate) {
      error.value = 'You must be at least 18 years old'
    } else if (errors?.gender) {
      error.value = 'Please select a valid gender'
    } else {
      error.value = e?.response?.data?.message || 'Failed to save'
    }
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="onboarding">
    <div class="card">
      <h1>Complete Your Profile</h1>
      <p class="subtitle">We need a few details before you can start</p>

      <div class="field">
        <label>I am a...</label>
        <div class="gender-options">
          <button
            :class="['gender-btn', { active: gender === 'male' }]"
            @click="gender = 'male'"
          >
            <img src="/assets/icon-male.png" alt="Male" />
            <span>Male</span>
          </button>
          <button
            :class="['gender-btn', { active: gender === 'female' }]"
            @click="gender = 'female'"
          >
            <img src="/assets/icon-female.png" alt="Female" />
            <span>Female</span>
          </button>
        </div>
      </div>

      <div class="field">
        <label>Birthday</label>
        <input
          type="date"
          v-model="birthdate"
          :min="minDate"
          :max="maxDate"
        />
      </div>

      <p v-if="error" class="error">{{ error }}</p>

      <button
        class="save-btn"
        :disabled="!isValid || saving"
        @click="save"
      >
        {{ saving ? 'Saving...' : 'Continue' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.onboarding {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  padding: 20px;
}

.card {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 40px;
  max-width: 400px;
  width: 100%;
  text-align: center;
}

h1 {
  color: #fff;
  margin: 0 0 8px;
  font-size: 24px;
}

.subtitle {
  color: rgba(255, 255, 255, 0.6);
  margin: 0 0 30px;
}

.field {
  margin-bottom: 24px;
  text-align: left;
}

.field label {
  display: block;
  color: rgba(255, 255, 255, 0.8);
  margin-bottom: 10px;
  font-weight: 500;
}

.gender-options {
  display: flex;
  gap: 12px;
}

.gender-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px;
  background: rgba(255, 255, 255, 0.05);
  border: 2px solid transparent;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
}

.gender-btn img {
  width: 40px;
  height: 40px;
}

.gender-btn span {
  color: rgba(255, 255, 255, 0.8);
  font-size: 14px;
}

.gender-btn:hover {
  background: rgba(255, 255, 255, 0.1);
}

.gender-btn.active {
  border-color: #6366f1;
  background: rgba(99, 102, 241, 0.2);
}

.field input[type="date"] {
  width: 100%;
  padding: 14px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  color: #fff;
  font-size: 16px;
}

.field input[type="date"]::-webkit-calendar-picker-indicator {
  filter: invert(1);
}

.error {
  color: #ef4444;
  margin-bottom: 16px;
}

.save-btn {
  width: 100%;
  padding: 16px;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  border: none;
  border-radius: 12px;
  color: #fff;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: opacity 0.2s;
}

.save-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.save-btn:not(:disabled):hover {
  opacity: 0.9;
}
</style>


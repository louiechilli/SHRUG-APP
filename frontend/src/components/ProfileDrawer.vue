<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const props = defineProps<{
  open: boolean
}>()

const emit = defineEmits<{
  close: []
}>()

const router = useRouter()
const auth = useAuthStore()

// Page navigation
const currentPage = ref<'profile' | 'more' | 'edit'>('profile')

// Edit form state
const editName = ref('')
const editBio = ref('')
const saving = ref(false)
const saveError = ref('')
const nameError = ref('')
const bioError = ref('')

const initials = computed(() => {
  return auth.user?.name?.split(' ').map(name => name[0]).join('') || '?'
})

const profilePic = computed(() => auth.user?.avatar ?? null)

const formattedBirthday = computed(() => {
  if (!auth.user?.created_at) return null
  return '2000-01-01'
})

const moreItems = [
  { label: 'Blocklist', action: () => {} },
  { label: 'About Us', action: () => {} },
  { label: 'Safety', action: () => {} },
  { label: 'Community', action: () => {} },
  { label: 'Privacy Policy', action: () => {} },
  { label: 'Terms Of Service', action: () => {} },
  { label: 'Contact Us', action: () => {} },
  { label: 'FAQ', action: () => {} },
  { label: 'Account & Security', action: () => {} },
]

async function signOut() {
  await auth.logout()
  emit('close')
  router.push('/login')
}

function copyId() {
  if (auth.user?.id) {
    navigator.clipboard.writeText(auth.user.id.toString())
  }
}

function goToMore() {
  currentPage.value = 'more'
}

function goToEdit() {
  editName.value = auth.user?.name || ''
  editBio.value = auth.user?.bio || ''
  currentPage.value = 'edit'
}

function goBack() {
  currentPage.value = 'profile'
}

function handleClose() {
  currentPage.value = 'profile'
  emit('close')
}

async function saveProfile() {
  nameError.value = ''
  bioError.value = ''
  saveError.value = ''
  
  if (!editName.value.trim()) {
    nameError.value = 'Name is required'
    return
  }
  
  saving.value = true
  try {
    await auth.updateProfile({
      name: editName.value,
      bio: editBio.value.trim() || null,
    })
    currentPage.value = 'profile'
  } catch (err: any) {
    const errors = err?.response?.data?.errors
    if (errors?.name) {
      nameError.value = errors.name[0]
    }
    if (errors?.bio) {
      bioError.value = errors.bio[0]
    }
    if (!errors) {
      saveError.value = err?.response?.data?.message || 'Failed to save'
    }
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <Teleport to="body">
    <Transition name="drawer">
      <div v-if="open" class="drawer-overlay" @click.self="handleClose">
        <div class="drawer-content">
          <!-- Profile Page -->
          <template v-if="currentPage === 'profile'">
            <div class="drawer-header">
              <h2>My Profile</h2>
              <button class="close-btn" @click="handleClose">
                <i class="fa-solid fa-xmark"></i>
              </button>
            </div>

            <div class="profile-card">
              <div class="profile-avatar">
                <div v-if="profilePic" :style="{ backgroundImage: `url(${profilePic})` }" class="avatar-img"></div>
                <span v-else class="avatar-initials">{{ initials }}</span>
              </div>
              <div class="profile-info">
                <h3>{{ auth.user?.name || 'User' }}</h3>
                <p class="user-id" @click="copyId">
                  ID: {{ auth.user?.id }}
                  <i class="fa-regular fa-copy"></i>
                </p>
              </div>
              <button class="edit-btn" @click="goToEdit">
                <i class="fa-solid fa-pencil"></i>
                Edit
              </button>
            </div>

            <!-- <div class="premium-banner">
              <img src="/assets/emojis/crown.png" alt="" class="crown-icon">
              <div class="premium-text">
                <h4>Shrug Plus</h4>
                <p>Get More Gender Filters</p>
              </div>
              <button class="join-btn">Join</button>
            </div> -->

            <!-- <div class="stats-row">
              <div class="stat-item">
                <img src="/assets/emojis/moneybag.png" alt="" class="stat-icon">
                <span>0</span>
              </div>
              <div class="stat-divider"></div>
              <div class="stat-item">
                <img src="/assets/emojis/gem.png" alt="" class="stat-icon">
                <span>0</span>
              </div>
            </div> -->

            <div class="info-section">
              <div class="info-row">
                <span class="info-label">🎂 Birthday</span>
                <span class="info-value">{{ formattedBirthday || 'Not set' }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">🧑 Gender</span>
                <span class="info-value capitalize">{{ auth.user?.gender || 'Not set' }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">🌍 Location</span>
                <span class="info-value capitalize">{{ auth.user?.location || 'Not set' }}</span>
              </div>
            </div>

            <div class="more-section" @click="goToMore">
              <span>📋 More</span>
              <i class="fa-solid fa-chevron-right"></i>
            </div>

            <button class="sign-out-btn" @click="signOut">
              Sign Out
            </button>
          </template>

          <!-- More Page -->
          <template v-else-if="currentPage === 'more'">
            <div class="drawer-header">
              <button class="back-btn" @click="goBack">
                <i class="fa-solid fa-chevron-left"></i>
              </button>
              <h2>More</h2>
              <button class="close-btn" @click="handleClose">
                <i class="fa-solid fa-xmark"></i>
              </button>
            </div>

            <div class="more-list">
              <button 
                v-for="item in moreItems" 
                :key="item.label" 
                class="more-item"
                @click="item.action"
              >
                {{ item.label }}
              </button>
            </div>
          </template>

          <!-- Edit Profile Page -->
          <template v-else-if="currentPage === 'edit'">
            <div class="drawer-header">
              <h2>Edit Profile</h2>
              <button class="close-btn" @click="handleClose">
                <i class="fa-solid fa-xmark"></i>
              </button>
            </div>

            <div class="edit-avatar-section">
              <div class="edit-avatar">
                <div v-if="profilePic" :style="{ backgroundImage: `url(${profilePic})` }" class="avatar-img"></div>
                <span v-else class="avatar-initials large">{{ initials }}</span>
                <!-- <button class="camera-btn">
                  <i class="fa-solid fa-camera"></i>
                </button> -->
              </div>
            </div>

            <div class="edit-field">
              <div class="field-header">
                <span class="field-icon">😊</span>
                <span class="field-label">Name</span>
                <span class="field-counter">{{ editName.length }}/16</span>
              </div>
              <input 
                v-model="editName" 
                type="text" 
                maxlength="16" 
                placeholder="Enter your name"
                :class="['edit-input', { 'input-error': nameError }]"
              >
              <span v-if="nameError" class="error-text">{{ nameError }}</span>
            </div>

            <div class="edit-field">
              <div class="field-header">
                <span class="field-icon">💬</span>
                <span class="field-label">About</span>
              </div>
              <textarea 
                v-model="editBio" 
                maxlength="140" 
                placeholder="Hobby | Status | Secret | Spirit Animal"
                :class="['edit-textarea', { 'input-error': bioError }]"
                rows="3"
              ></textarea>
              <span class="field-counter bottom">{{ editBio.length }}/140</span>
              <span v-if="bioError" class="error-text">{{ bioError }}</span>
            </div>

            <p v-if="saveError" class="error-text center">{{ saveError }}</p>

            <button class="save-btn" @click="saveProfile" :disabled="saving">
              {{ saving ? 'Saving...' : 'Save' }}
            </button>
          </template>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.drawer-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 1000;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding-top: 5vh;
}

.drawer-content {
  background: #1a1a2e;
  border-radius: 20px;
  width: 90%;
  max-width: 400px;
  max-height: 85vh;
  overflow-y: auto;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;

  position: absolute;
  right: 2rem;
  top: 7rem;
}

.drawer-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  h2 {
    color: white;
    font-size: 1.25rem;
    margin: 0;
  }
}

.close-btn {
  background: none;
  border: none;
  color: white;
  font-size: 1.5rem;
  cursor: pointer;
  padding: 0.5rem;
}

.profile-card {
  background: #2a2a4a;
  border-radius: 16px;
  padding: 1rem;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.profile-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: #4a90a4;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 3px solid #5ba8bd;
  flex-shrink: 0;
}

.avatar-img {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background-size: cover;
  background-position: center;
}

.avatar-initials {
  color: white;
  font-size: 1.5rem;
  font-weight: 600;
}

.profile-info {
  flex: 1;
  
  h3 {
    color: white;
    margin: 0 0 0.25rem;
    font-size: 1.1rem;
  }
}

.user-id {
  color: #888;
  font-size: 0.85rem;
  margin: 0;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  
  &:hover {
    color: #aaa;
  }
  
  i {
    font-size: 0.75rem;
  }
}

.edit-btn {
  background: #3a3a5a;
  border: none;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  
  &:hover {
    background: #4a4a6a;
  }
}

.premium-banner {
  background: linear-gradient(135deg, #6b5ce7, #8b7cf7);
  border-radius: 16px;
  padding: 1rem;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.crown-icon {
  width: 50px;
  height: 50px;
}

.premium-text {
  flex: 1;
  
  h4 {
    color: white;
    margin: 0;
    font-size: 1.1rem;
  }
  
  p {
    color: rgba(255, 255, 255, 0.7);
    margin: 0;
    font-size: 0.85rem;
  }
}

.join-btn {
  background: #f0e040;
  border: none;
  color: #333;
  padding: 0.75rem 2rem;
  border-radius: 25px;
  font-weight: 600;
  cursor: pointer;
  
  &:hover {
    background: #ffe040;
  }
}

.stats-row {
  background: #2a2a4a;
  border-radius: 16px;
  padding: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex: 1;
  justify-content: center;
  
  span {
    color: white;
    font-size: 1.1rem;
    font-weight: 600;
  }
}

.stat-icon {
  width: 30px;
  height: 30px;
}

.stat-divider {
  width: 1px;
  height: 30px;
  background: #444;
}

.info-section {
  background: #2a2a4a;
  border-radius: 16px;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.info-label {
  color: white;
  font-size: 0.95rem;
}

.info-value {
  color: #888;
  font-size: 0.95rem;
}

.more-section {
  background: #2a2a4a;
  border-radius: 16px;
  padding: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: white;
  cursor: pointer;
  
  &:hover {
    background: #3a3a5a;
  }
}

.sign-out-btn {
  background: #2a2a4a;
  border: none;
  color: white;
  padding: 1rem;
  border-radius: 16px;
  font-size: 1rem;
  cursor: pointer;
  text-align: left;
  
  &:hover {
    background: #3a3a5a;
  }
}

/* Transitions */
.drawer-enter-active,
.drawer-leave-active {
  transition: opacity 0.2s ease;
}

.drawer-enter-active .drawer-content,
.drawer-leave-active .drawer-content {
  transition: transform 0.2s ease;
}

.drawer-enter-from,
.drawer-leave-to {
  opacity: 0;
}

.drawer-enter-from .drawer-content,
.drawer-leave-to .drawer-content {
  transform: translateY(-20px);
}

.back-btn {
  background: none;
  border: none;
  color: white;
  font-size: 1.25rem;
  cursor: pointer;
  padding: 0.5rem;
}

.more-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.more-item {
  background: none;
  border: none;
  color: white;
  padding: 1rem 0;
  font-size: 1rem;
  text-align: left;
  cursor: pointer;
  transition: color 0.2s;
  
  &:hover {
    color: #aaa;
  }
}

/* Edit Profile Styles */
.edit-avatar-section {
  background: #2a2a4a;
  border-radius: 16px;
  padding: 2rem;
  display: flex;
  justify-content: center;
}

.edit-avatar {
  position: relative;
  width: 100px;
  height: 100px;
}

.edit-avatar .avatar-img {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background-size: cover;
  background-position: center;
}

.edit-avatar .avatar-initials.large {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: #2a4a6a;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 2.5rem;
  font-weight: 600;
}

.camera-btn {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #6b5ce7;
  border: 2px solid white;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 0.85rem;
}

.edit-field {
  background: #2a2a4a;
  border-radius: 16px;
  padding: 1rem;
  position: relative;
}

.field-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.field-icon {
  font-size: 1.25rem;
}

.field-label {
  flex: 1;
  color: #888;
  font-weight: 500;
}

.field-counter {
  color: #888;
  font-size: 0.85rem;
}

.field-counter.bottom {
  position: absolute;
  bottom: 0.75rem;
  right: 1rem;
}

.edit-input {
  width: 100%;
  border: none;
  background: transparent;
  font-size: 1rem;
  color: #888;
  outline: none;
  padding: 0;
}

.edit-input::placeholder {
  color: #aaa;
}

.edit-textarea {
  width: 100%;
  border: none;
  background: transparent;
  font-size: 0.9rem;
  color: #888;
  outline: none;
  padding: 0;
  resize: none;
  font-family: inherit;
}

.edit-textarea::placeholder {
  color: #aaa;
}

.save-btn {
  background: #6b5ce7;
  border: none;
  color: white;
  padding: 1rem;
  border-radius: 16px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  width: 100%;
  
  &:hover {
    background: #5a4bd6;
  }
  
  &:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }
}

.input-error {
  border: 1px solid #ef4444 !important;
  border-radius: 8px;
  padding: 0.5rem !important;
}

.error-text {
  color: #ef4444;
  font-size: 0.75rem;
  margin-top: 0.25rem;
  display: block;
}

.error-text.center {
  text-align: center;
}

/* Mobile: full-height drawer from bottom */
@media (max-width: 1024px) {
  .drawer-overlay {
    align-items: flex-end;
    padding-top: 0;
  }
  
  .drawer-content {
    border-radius: 20px 20px 0 0;
    max-height: 90vh;
    width: 100%;
    max-width: 100%;
    position: unset;
  }
  
  .drawer-enter-from .drawer-content,
  .drawer-leave-to .drawer-content {
    transform: translateY(100%);
  }
}
</style>


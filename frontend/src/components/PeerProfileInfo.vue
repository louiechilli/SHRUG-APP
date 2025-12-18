<script setup lang="ts">
import type { ApiUser } from '../stores/auth'

defineProps<{
  peerUser: ApiUser | null
}>()

const emit = defineEmits<{
  addFriend: []
}>()
</script>

<template>
  <div class="call-meta">
    <div class="guest-profile-info">
      <div class="guest-user-avatar">
        <img :src="peerUser?.avatar || '/assets/emojis/man-shrugging.png'" alt="">
      </div>
      <div class="guest-user-name-location">
        <p class="guest-user-name">{{ peerUser?.name || 'Anonymous' }}{{ peerUser?.age ? `, ${peerUser.age}` : '' }}</p>
        <p class="guest-user-location">{{ peerUser?.location || 'Unknown location' }}</p>
      </div>
      <!-- <button class="guest-friend-add-btn" @click="emit('addFriend')">
        <img src="/assets/emojis/heartpulse.png" alt="">
      </button> -->
    </div>
  </div>
</template>

<style scoped>
.call-meta {
  position: absolute;
  top: 10px;
  left: 10px;
  right: 10px;
  bottom: 10px;
  height: fit-content;
}

.guest-profile-info {
  background: rgba(0, 0, 0, 0.5);
  border-radius: 50px;
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  width: fit-content;
  padding: 10px;
}

.guest-user-avatar {
  width: 40px;
  height: 40px;
  aspect-ratio: 1/1;
  border-radius: 50%;
  overflow: hidden;
  
  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.guest-user-name-location {
  display: flex;
  padding-right: 10px;
  flex-direction: column;
  align-items: flex-start;
  justify-content: center;
  gap: 3px;
  height: fit-content;
  flex: 1;
}

.guest-user-name-location p {
  font-size: 14px;
  margin: 0;
  line-height: 1;
  text-overflow: ellipsis;
  overflow: hidden;
  white-space: nowrap;
  width: fit-content;
}

.guest-user-name {
  font-size: 16px;
  font-weight: 600;
  color: white !important;
}

.guest-user-location {
  font-size: 13px;
  font-weight: 400;
  color: rgb(237, 237, 237) !important;
}

.guest-friend-add-btn {
  width: 40px;
  height: 40px;
  aspect-ratio: 1/1;
  background: #fdfb4c;
  border-radius: 50%;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  cursor: pointer;
  transition: transform 0.2s;
}

.guest-friend-add-btn:hover {
  transform: scale(1.1);
}

.guest-friend-add-btn img {
  width: 70%;
  height: 70%;
  object-fit: cover;
}
</style>


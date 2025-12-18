<script setup lang="ts">
import { computed, ref } from 'vue'
import { useAuthStore } from '../stores/auth'
import ProfileDrawer from './ProfileDrawer.vue'

const auth = useAuthStore()
const showProfile = ref(false)

const initials = computed(() => {
    return auth.user?.name?.split(' ').map(name => name[0]).join('')
})

const profilePic = computed(() => {
    return auth.user?.avatar ?? null
})
</script>

<template>
    <div class="auth-header">
        <div class="auth-header-item" id="profile" @click="showProfile = true">
            <div class="profile-placeholder">
                <div v-if="profilePic" :style="{ backgroundImage: `url(${profilePic})` }" class="profile-pic"></div>
                <span v-else>{{ initials }}</span>
            </div>
        </div>
    </div>
    
    <ProfileDrawer :open="showProfile" @close="showProfile = false" />
</template>

<style scoped>
.auth-header {
    z-index: 10;
    padding: 1rem;
    position: absolute;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-direction: row;
    top: 1.5rem;  
    right: 1.5rem;
    gap: 1rem;

    .auth-header-item {
        padding: 0.25rem;
        aspect-ratio: 1/1;
        display: flex;
        justify-content: center;
        height: 3.5rem;
        width: 3.5rem;
        border-radius: 50%;
        align-items: center;
        background: rgba(255, 255, 255, 0.2);
        backdrop-filter: blur(5px);
        -webkit-backdrop-filter: blur(5px);
        font-size: 1.3rem;
        cursor: pointer;
        transition: transform 0.2s, background 0.2s;
        
        &:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: scale(1.05);
        }

        .profile-placeholder {
            height: 100%;
            width: 100%;
            border-radius: 50%;
            background-size: cover;
            background-position: center;
            
            .profile-pic {
                height: 100%;
                width: 100%;
                border-radius: 50%;
                background-size: cover;
                background-position: center;
            }
        }
    }

    .notification-badge {
        position: absolute;
        top: -5px;
        right: -5px;
        height: 1.5rem;
        width: 1.5rem;
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 0.8rem;
        background: red;
        color: white;
        border-radius: 50%;
        padding: 0.25rem;
    }
}

@media (max-width: 1023px) {
    .auth-header {
        left: 1.5rem;
        width: fit-content;
        flex-direction: column;

        .auth-header-item {
            width: 6rem;
            height: 6rem;
            font-size: 2rem;
        }
    }
}

@media (max-width: 670px) {
    .auth-header {
        .auth-header-item {
            width: 4rem;
            height: 4rem;
            font-size: 1.5rem;
        }
    }
}
</style>
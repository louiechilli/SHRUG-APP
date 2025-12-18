<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore, type ApiUser } from '../stores/auth'
import { useSignaling } from '../services/signaling'
import { useAgora } from '../services/agora'
import api from '../services/api'
import DesktopLayout from '../layouts/DesktopLayout.vue'
import MobileLayout from '../layouts/MobileLayout.vue'
import ChatContainer from '../components/ChatContainer.vue'
import VideoPanel from '../components/VideoPanel.vue'
import WelcomePanel from '../components/WelcomePanel.vue'
import PreCallActions from '../components/PreCallActions.vue'
import AuthHeader from '../components/AuthHeader.vue'
import BothModal from '../components/BothModal.vue'
import SearchingState from '../components/SearchingState.vue'
import SearchActions from '../components/SearchActions.vue'
import PeerProfileInfo from '../components/PeerProfileInfo.vue'
import SkipButton from '../components/SkipButton.vue'
import CallOverlay from '../components/CallOverlay.vue'
import MatchedState from '../components/MatchedState.vue'

const router = useRouter()
const auth = useAuthStore()
const signaling = useSignaling()
const agora = useAgora()

const loading = ref(false)
const callLoading = ref(false)
const inCall = ref(false)
const searchingForPeer = ref(false)
const matchedPeer = ref(false) // Show "Meet X" screen before connecting
const error = ref<string | null>(null)
const showBothModal = ref(false)
const selectedGender = ref('both') // Gender preference for matching
// User's own gender - computed from auth store
const userGender = computed(() => auth.user?.gender ?? 'other')
const currentEmojiIndex = ref(0)
const minSearchTime = ref<number>(0)
const peerUser = ref<ApiUser | null>(null)
let emojiInterval: number | null = null

function startEmojiRotation() {
  emojiInterval = window.setInterval(() => {
    currentEmojiIndex.value = (currentEmojiIndex.value + 1) % 3
  }, 800)
}

function stopEmojiRotation() {
  if (emojiInterval) {
    clearInterval(emojiInterval)
    emojiInterval = null
  }
}

// Video element refs
const hostVideoRef = ref<HTMLDivElement | null>(null)
const hostVideoRefMobile = ref<HTMLDivElement | null>(null)
const guestVideoRef = ref<HTMLDivElement | null>(null)
const guestVideoRefMobile = ref<HTMLDivElement | null>(null)

// Watch for remote video track changes
watch(() => agora.remoteVideoTrack.value, (track) => {
  if (track) {
    nextTick(() => {
      console.log('Remote track received, playing in:', guestVideoRef.value, guestVideoRefMobile.value)
      const isMobile = window.innerWidth < 1024
      const container = isMobile ? guestVideoRefMobile.value : guestVideoRef.value
      if (container) track.play(container)
    })
  }
})

async function initLocalVideo() {
  try {
    await agora.initLocalTracks()
    await nextTick()
    
    // Only play in one container (the visible one based on screen size)
    const isMobile = window.innerWidth < 1024
    const container = isMobile ? hostVideoRefMobile.value : hostVideoRef.value
    if (container && agora.localVideoTrack.value) {
      agora.localVideoTrack.value.play(container)
    }
  } catch (err) {
    console.error('Failed to init local video:', err)
    error.value = 'Camera/microphone access denied'
  }
}

function stopMediaStream() {
  agora.stopLocalTracks()
}

async function logout() {
  endCall()
  signaling.disconnect()
  stopMediaStream()
  await auth.logout()
  router.push('/login')
}

async function startCall() {
  callLoading.value = true
  
  try {
    // Connect to signaling server
    if (!signaling.connected.value) {
      await signaling.connect(auth.user?.id?.toString() ?? 'anonymous')
    }
    
    // Setup signaling handlers
    setupSignalingHandlers()
    
    callLoading.value = false
    searchingForPeer.value = true
    startEmojiRotation()
    
    // Set minimum search time for initial join too
    minSearchTime.value = Date.now() + 3000
    
    // Join the matchmaking queue
    signaling.joinQueue(
      auth.user?.id?.toString() ?? 'anonymous',
      userGender.value,
      selectedGender.value
    )
  } catch (err) {
    console.error('Failed to start call:', err)
    error.value = 'Failed to connect to server'
    callLoading.value = false
  }
}

async function fetchPeerUser(peerId: string) {
  // Don't fetch if peer ID is 'anonymous' or not a valid number
  if (peerId === 'anonymous' || isNaN(Number(peerId))) {
    peerUser.value = null
    return
  }
  try {
    const { data } = await api.get(`/users/${peerId}`)
    peerUser.value = data.user
  } catch (err) {
    console.error('Failed to fetch peer user:', err)
    peerUser.value = null
  }
}

let currentMatchChannel: string | null = null

function setupSignalingHandlers() {
  signaling.on('matched', async (data: any) => {
    console.log('Matched raw data:', JSON.stringify(data))
    
    // Ignore if already processing a match or in call
    if (currentMatchChannel || inCall.value) {
      console.log('Ignoring duplicate match, already processing:', currentMatchChannel)
      return
    }
    
    currentMatchChannel = data.channelName
    
    // Fetch peer user info first
    await fetchPeerUser(data.peerId)
    
    // Check if cancelled during fetch
    if (!searchingForPeer.value && !matchedPeer.value) {
      currentMatchChannel = null
      return
    }
    
    // Wait for minimum search time
    const now = Date.now()
    const waitTime = Math.max(0, minSearchTime.value - now)
    if (waitTime > 0) {
      await new Promise(resolve => setTimeout(resolve, waitTime))
    }
    
    // Check if cancelled during wait
    if (!searchingForPeer.value && !matchedPeer.value) {
      currentMatchChannel = null
      return
    }
    
    // Stop searching, show "Meet X" screen
    stopEmojiRotation()
    searchingForPeer.value = false
    matchedPeer.value = true
    
    // Get token and join Agora channel while showing "Meet X" screen
    try {
      const { data: tokenData } = await api.post('/agora/token', { channel_name: currentMatchChannel })
      await agora.joinChannel(currentMatchChannel, tokenData.uid, tokenData.token)
    } catch (err) {
      console.error('Failed to join Agora channel:', err)
      error.value = 'Failed to connect to call'
      matchedPeer.value = false
      currentMatchChannel = null
      return
    }
    
    // Wait for remote video to be available (max 10 seconds)
    const startWait = Date.now()
    while (!agora.remoteVideoTrack.value && Date.now() - startWait < 10000) {
      if (!matchedPeer.value) {
        // Cancelled during wait
        currentMatchChannel = null
        return
      }
      await new Promise(r => setTimeout(r, 200))
    }
    
    // Check if cancelled
    if (!matchedPeer.value) {
      currentMatchChannel = null
      return
    }
    
    // Transition to call view
    matchedPeer.value = false
    inCall.value = true
    
    // Play remote video
    await nextTick()
    if (agora.remoteVideoTrack.value) {
      const isMobile = window.innerWidth < 1024
      const container = isMobile ? guestVideoRefMobile.value : guestVideoRef.value
      if (container) agora.remoteVideoTrack.value.play(container)
    }
  })
  
  signaling.on('peer-left', () => {
    console.log('Peer left')
    handlePeerLeft()
  })
}

function handlePeerLeft() {
  console.log('handlePeerLeft called - cleaning up connection')
  
  // Leave Agora channel
  agora.leaveChannel()
  peerUser.value = null
  currentMatchChannel = null
  
  // Reset all call states
  inCall.value = false
  matchedPeer.value = false
  
  // Small delay before rejoining to ensure clean state
  setTimeout(() => {
    // Only rejoin if we haven't cancelled
    if (!searchingForPeer.value && !inCall.value && !matchedPeer.value) {
      // Auto-search for new peer with minimum 3 second search
      searchingForPeer.value = true
      startEmojiRotation()
      minSearchTime.value = Date.now() + 3000
      signaling.joinQueue(
        auth.user?.id?.toString() ?? 'anonymous',
        userGender.value,
        selectedGender.value
      )
    }
  }, 100)
}

function skipPeer() {
  signaling.skip()
  agora.leaveChannel()
  peerUser.value = null
  currentMatchChannel = null
  inCall.value = false
  searchingForPeer.value = true
  startEmojiRotation()
  minSearchTime.value = Date.now() + 3000
  signaling.joinQueue(
    auth.user?.id?.toString() ?? 'anonymous',
    userGender.value,
    selectedGender.value
  )
}

function endCall() {
  // Notify server so peer gets put back in queue
  signaling.skip()
  agora.leaveChannel()
  currentMatchChannel = null
  inCall.value = false
  
  // Put back in queue with minimum 3 second search
  searchingForPeer.value = true
  startEmojiRotation()
  minSearchTime.value = Date.now() + 3000
  signaling.joinQueue(
    auth.user?.id?.toString() ?? 'anonymous',
    userGender.value,
    selectedGender.value
  )
}

function cancelSearch() {
  // Leave Agora channel
  agora.leaveChannel()
  peerUser.value = null
  currentMatchChannel = null
  
  // Leave the queue on server
  signaling.leaveQueue()
  
  // Reset all states
  searchingForPeer.value = false
  inCall.value = false
  matchedPeer.value = false
  stopEmojiRotation()
}

function toggleBoth() {
  showBothModal.value = true
}

function onGenderSave(gender: string) {
  console.log('Gender preference changed:', gender)
  console.log('searchingForPeer:', searchingForPeer.value, 'inCall:', inCall.value)
  selectedGender.value = gender
  
  // If searching, rejoin queue with new preference
  if (searchingForPeer.value && !inCall.value) {
    console.log('Rejoining queue with new preference:', gender, 'userGender:', userGender.value)
    signaling.joinQueue(
      auth.user?.id?.toString() ?? 'anonymous',
      userGender.value,
      gender
    )
  }
}

const genderLabel = computed(() => {
  switch (selectedGender.value) {
    case 'girls': return 'Girls Only'
    case 'guys': return 'Guys Only'
    default: return 'Both'
  }
})

const genderIcon = computed(() => {
  switch (selectedGender.value) {
    case 'girls': return '/assets/icon-female.png'
    case 'guys': return '/assets/icon-male.png'
    default: return '/assets/icon-both.png'
  }
})

const initials = computed(() => {
  const name = auth.user?.name?.trim() ?? 'U'
  const parts = name.split(/\s+/).slice(0, 2)
  return parts.map((p) => p[0]?.toUpperCase()).join('')
})

onMounted(async () => {
  // Initialize local video
  await initLocalVideo()
  
  if (auth.user) return
  loading.value = true
  error.value = null
  try {
    await auth.fetchMe()
  } catch (e: any) {
    error.value = e?.response?.data?.message ?? 'Could not load your account.'
  } finally {
    loading.value = false
  }
})

onUnmounted(() => {
  endCall()
  signaling.disconnect()
  stopMediaStream()
  stopEmojiRotation()
})
</script>

<template>
  <DesktopLayout>
    <AuthHeader />
    <ChatContainer>
      <VideoPanel type="host">
        <div ref="hostVideoRef" class="host-video" />
      </VideoPanel>
      <VideoPanel type="guest">
        <!-- In call - show remote video -->
        <template v-if="inCall">
          <div ref="guestVideoRef" class="guest-video" />
          <CallOverlay />
          <PeerProfileInfo :peer-user="peerUser" />
          <SkipButton @skip="skipPeer" />
        </template>
        
        <!-- Matched - show "Meet X" screen -->
        <template v-else-if="matchedPeer">
          <MatchedState :peer-user="peerUser" />
        </template>
        
        <!-- Searching state -->
        <template v-else-if="searchingForPeer">
          <SearchingState :current-emoji-index="currentEmojiIndex" />
          <SearchActions :gender-icon="genderIcon" :gender-label="genderLabel" @toggle-gender="toggleBoth" @cancel="cancelSearch" />
        </template>
        
        <!-- Welcome state -->
        <template v-else>
          <WelcomePanel />
          <PreCallActions :selected-gender="selectedGender" :loading="callLoading" @start-call="startCall" @toggle-both="toggleBoth" />
        </template>
      </VideoPanel>
    </ChatContainer>
  </DesktopLayout>

  <MobileLayout>
    <AuthHeader v-if="!inCall && !searchingForPeer && !matchedPeer" />
    <ChatContainer :class="{ 'mobile-chat': searchingForPeer || matchedPeer || inCall }">
      <!-- Guest panel only visible when searching, matched, or in call -->
      <VideoPanel v-if="searchingForPeer || matchedPeer || inCall" type="guest">
        <!-- In call - show remote video -->
        <template v-if="inCall">
          <div ref="guestVideoRefMobile" class="guest-video" />
          <CallOverlay />
          <PeerProfileInfo :peer-user="peerUser" />
        </template>
        <!-- Matched - show "Meet X" screen -->
        <template v-else-if="matchedPeer">
          <MatchedState :peer-user="peerUser" />
        </template>
        <!-- Searching -->
        <template v-else-if="searchingForPeer">
          <SearchingState :current-emoji-index="currentEmojiIndex" />
        </template>
      </VideoPanel>
      <VideoPanel type="host">
        <div ref="hostVideoRefMobile" class="host-video" />
        <SkipButton v-if="inCall" @skip="skipPeer" />
        <SearchActions v-else-if="searchingForPeer" :gender-icon="genderIcon" :gender-label="genderLabel" @toggle-gender="toggleBoth" @cancel="cancelSearch" />
        <PreCallActions v-else-if="!matchedPeer" :selected-gender="selectedGender" :loading="callLoading" @start-call="startCall" @toggle-both="toggleBoth" />
      </VideoPanel>
    </ChatContainer>
  </MobileLayout>

  <BothModal :open="showBothModal" @close="showBothModal = false" @save="onGenderSave" />
</template>

<style scoped>
.host-video,
.guest-video {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border-radius: 10px;
  overflow: hidden;
}

.host-video :deep(div),
.guest-video :deep(div) {
  width: 100% !important;
  height: 100% !important;
}

.host-video :deep(video),
.guest-video :deep(video) {
  width: 100% !important;
  height: 100% !important;
  object-fit: cover !important;
  transform: scaleX(-1);
}

.mobile-chat {
  flex-direction: column;
  gap: 0 !important;

  .video-panel {
    border-radius: 0 !important;
    height: 100%;
  }
}
</style>

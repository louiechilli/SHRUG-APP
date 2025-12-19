import AgoraRTC, {
  type IAgoraRTCClient,
  type ICameraVideoTrack,
  type IMicrophoneAudioTrack,
  type IRemoteVideoTrack,
  type IRemoteAudioTrack,
} from 'agora-rtc-sdk-ng'
import { ref } from 'vue'

const APP_ID = import.meta.env.VITE_AGORA_APP_ID

// Validate Agora APP_ID is configured
if (!APP_ID) {
  console.error('VITE_AGORA_APP_ID is not configured. Please set it in your environment variables.')
} else {
  console.log('Agora APP_ID:', APP_ID ? `${APP_ID.substring(0, 10)}...` : 'NOT SET')
}

// Singleton state
const client = ref<IAgoraRTCClient | null>(null)
const localAudioTrack = ref<IMicrophoneAudioTrack | null>(null)
const localVideoTrack = ref<ICameraVideoTrack | null>(null)
const remoteVideoTrack = ref<IRemoteVideoTrack | null>(null)
const remoteAudioTrack = ref<IRemoteAudioTrack | null>(null)
const isJoined = ref(false)
const remoteUid = ref<string | number | null>(null)
const remoteUsers = new Map<string | number, boolean>()

export function useAgora() {
  async function initLocalTracks() {
    try {
      console.log('Creating microphone and camera tracks...')
      const [audioTrack, videoTrack] = await AgoraRTC.createMicrophoneAndCameraTracks()
      console.log('Tracks created:', { audioTrack, videoTrack })
      localAudioTrack.value = audioTrack
      localVideoTrack.value = videoTrack
      return { audioTrack, videoTrack }
    } catch (err) {
      console.error('Failed to create local tracks:', err)
      throw err
    }
  }

  function playLocalVideo(element: HTMLElement) {
    if (localVideoTrack.value) {
      localVideoTrack.value.play(element)
    }
  }

  async function joinChannel(channelName: string, uid?: string | number, token?: string | null) {
    if (!APP_ID) {
      throw new Error('VITE_AGORA_APP_ID is not set')
    }

    // Create client if not exists
    if (!client.value) {
      client.value = AgoraRTC.createClient({ mode: 'rtc', codec: 'vp8' })
      
      // Setup event handlers
      // Track which users we've subscribed to (shared across events)
      const subscribedUsers = new Set<string | number>()
      
      client.value.on('user-joined', (user) => {
        console.log('User joined channel:', user.uid)
        remoteUsers.set(user.uid, true)
        // Reset subscription tracking for this user
        subscribedUsers.delete(user.uid)
      })
      
      // Track which users we've already subscribed to (to avoid duplicate subscriptions)
      const subscribedUsers = new Set<string | number>()
      
      client.value.on('user-published', async (user, mediaType) => {
        console.log('=== USER PUBLISHED EVENT ===')
        console.log('User published:', user.uid, mediaType)
        console.log('Timestamp:', new Date().toISOString())
        
        // Mark user as available
        remoteUsers.set(user.uid, true)
        
        // In P2P mode, wait for both audio and video to be published before subscribing
        // This avoids the "user is not in the channel" error that occurs when subscribing
        // too early in the P2P connection lifecycle
        if (subscribedUsers.has(user.uid)) {
          console.log(`⏭️ Already subscribed to user ${user.uid}, skipping...`)
          return
        }
        
        // Wait longer for P2P connection to be fully ready
        console.log(`⏳ Waiting 3000ms for P2P connection to be fully ready before subscribing to user ${user.uid}...`)
        await new Promise(resolve => setTimeout(resolve, 3000))
        
        // Retry subscribe with exponential backoff
        let retries = 0
        const maxRetries = 8
        
        while (retries < maxRetries) {
          try {
            console.log(`🔄 Attempting to subscribe to user ${user.uid} (all tracks) - attempt ${retries + 1}/${maxRetries}...`)
            // Subscribe without mediaType to subscribe to all available tracks at once
            // This works better in P2P mode
            await client.value!.subscribe(user, undefined)
            console.log('✅ Successfully subscribed to user', user.uid)
            subscribedUsers.add(user.uid)
            console.log('✅ Successfully subscribed to', mediaType, 'track for user', user.uid)
            
            // Wait for tracks to be populated after subscription
            // Poll up to 2 seconds for tracks to become available
            await new Promise(resolve => setTimeout(resolve, 500))
            
            // Get fresh user reference from client.remoteUsers after subscribe
            const remoteUser = client.value!.remoteUsers.find(u => u.uid === user.uid)
            
            if (remoteUser) {
              if (remoteUser.videoTrack) {
                console.log('✅ Video track found, Track ID:', remoteUser.videoTrack.getTrackId())
                remoteVideoTrack.value = remoteUser.videoTrack
                remoteUid.value = remoteUser.uid
                console.log('✅ Remote video track set successfully')
              } else {
                console.warn('⚠ Video track not available after subscription')
              }
              
              if (remoteUser.audioTrack) {
                console.log('✅ Audio track found, Track ID:', remoteUser.audioTrack.getTrackId())
                remoteAudioTrack.value = remoteUser.audioTrack
                try {
                  remoteUser.audioTrack.play()
                  console.log('✅ Remote audio track set and playing successfully')
                } catch (playErr) {
                  console.error('❌ Failed to play audio track:', playErr)
                }
              } else {
                console.warn('⚠ Audio track not available after subscription')
              }
            } else {
              console.warn('⚠ Remote user not found in client.remoteUsers after subscription')
              console.log('Available remote users:', client.value!.remoteUsers.map(u => u.uid))
            }
            break // Success, exit loop
          } catch (err: any) {
            retries++
            console.error(`✗ Subscribe attempt ${retries} failed:`, err)
            if (retries < maxRetries) {
              // Use longer delays: 800ms, 1200ms, 1600ms, 2000ms
              const delay = 400 + (400 * retries)
              console.log(`Retrying subscription in ${delay}ms... (attempt ${retries + 1}/${maxRetries})`)
              await new Promise(r => setTimeout(r, delay))
            } else {
              console.error(`✗ Failed to subscribe to user ${user.uid} ${mediaType} after ${maxRetries} retries:`, err)
            }
          }
        }
      })

      client.value.on('user-unpublished', (user, mediaType) => {
        console.log('User unpublished:', user.uid, mediaType)
        if (mediaType === 'video') {
          remoteVideoTrack.value = null
        }
        if (mediaType === 'audio') {
          remoteAudioTrack.value = null
        }
      })

      client.value.on('user-left', (user) => {
        console.log('User left:', user.uid)
        remoteUsers.delete(user.uid)
        subscribedUsers.delete(user.uid)
        remoteVideoTrack.value = null
        remoteAudioTrack.value = null
        remoteUid.value = null
      })
    }
    
    // Clear remote users for new channel
    remoteUsers.clear()

    // Join channel
    await client.value.join(APP_ID, channelName, token || null, uid || null)
    isJoined.value = true

    // Publish local tracks if they exist
    if (localAudioTrack.value && localVideoTrack.value) {
      await client.value.publish([localAudioTrack.value, localVideoTrack.value] as any)
    } else if (localAudioTrack.value) {
      await client.value.publish(localAudioTrack.value)
    } else if (localVideoTrack.value) {
      await client.value.publish(localVideoTrack.value)
    }

    return client.value
  }

  function playRemoteVideo(element: HTMLElement) {
    if (remoteVideoTrack.value) {
      remoteVideoTrack.value.play(element)
    }
  }

  async function leaveChannel() {
    // Unpublish and leave
    if (client.value && isJoined.value) {
      await client.value.leave()
    }
    
    // Stop remote tracks
    remoteVideoTrack.value = null
    remoteAudioTrack.value = null
    remoteUid.value = null
    isJoined.value = false
  }

  function stopLocalTracks() {
    if (localAudioTrack.value) {
      localAudioTrack.value.stop()
      localAudioTrack.value.close()
      localAudioTrack.value = null
    }
    if (localVideoTrack.value) {
      localVideoTrack.value.stop()
      localVideoTrack.value.close()
      localVideoTrack.value = null
    }
  }

  function cleanup() {
    leaveChannel()
    stopLocalTracks()
    if (client.value) {
      client.value.removeAllListeners()
      client.value = null
    }
  }

  return {
    client,
    localAudioTrack,
    localVideoTrack,
    remoteVideoTrack,
    remoteAudioTrack,
    isJoined,
    remoteUid,
    initLocalTracks,
    playLocalVideo,
    joinChannel,
    playRemoteVideo,
    leaveChannel,
    stopLocalTracks,
    cleanup,
  }
}


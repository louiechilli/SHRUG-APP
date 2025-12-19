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
      client.value.on('user-joined', (user) => {
        console.log('User joined channel:', user.uid)
        remoteUsers.set(user.uid, true)
      })
      
      client.value.on('user-published', async (user, mediaType) => {
        console.log('User published:', user.uid, mediaType)
        
        // Mark user as available
        remoteUsers.set(user.uid, true)
        
        // Add initial delay to ensure Agora SDK has synchronized the user state
        // This prevents "user is not in the channel" errors that occur when
        // subscription happens too quickly after user-published event
        // Increased delay to 500ms for better reliability
        await new Promise(resolve => setTimeout(resolve, 500))
        
        // Retry subscribe with exponential backoff
        let retries = 0
        const maxRetries = 5
        
        while (retries < maxRetries) {
          try {
            await client.value!.subscribe(user, mediaType)
            console.log('Subscribed to', mediaType, 'track')
            
            // Get fresh user reference from client.remoteUsers after subscribe
            const remoteUser = client.value!.remoteUsers.find(u => u.uid === user.uid)
            if (remoteUser) {
              if (mediaType === 'video') {
                remoteVideoTrack.value = remoteUser.videoTrack || null
                remoteUid.value = remoteUser.uid
                console.log('Remote video track set:', remoteVideoTrack.value)
              }
              if (mediaType === 'audio') {
                remoteAudioTrack.value = remoteUser.audioTrack || null
                remoteUser.audioTrack?.play()
              }
            }
            break // Success, exit loop
          } catch (err: any) {
            retries++
            if (retries < maxRetries) {
              // Use longer delays: 800ms, 1200ms, 1600ms, 2000ms
              const delay = 400 + (400 * retries)
              console.log(`Subscribe retry ${retries}/${maxRetries} for ${mediaType} (waiting ${delay}ms)...`)
              await new Promise(r => setTimeout(r, delay))
            } else {
              console.warn('Failed to subscribe to user after retries:', err)
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


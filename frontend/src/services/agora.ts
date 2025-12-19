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
        console.log('=== USER PUBLISHED EVENT ===')
        console.log('User published:', user.uid, mediaType)
        console.log('Timestamp:', new Date().toISOString())
        
        // Mark user as available
        remoteUsers.set(user.uid, true)
        
        // In P2P mode, user-published can fire immediately after user-joined,
        // but the SDK needs time to establish the peer connection and process
        // the media stream before subscription will work.
        // Use a conservative initial delay of 1000ms to ensure SDK is ready.
        console.log(`⏳ Waiting 1000ms before subscribing to user ${user.uid} ${mediaType}...`)
        await new Promise(resolve => setTimeout(resolve, 1000))
        
        // Retry subscribe with exponential backoff
        let retries = 0
        const maxRetries = 5
        
        while (retries < maxRetries) {
          try {
            console.log(`🔄 Attempting to subscribe to user ${user.uid} ${mediaType}...`)
            await client.value!.subscribe(user, mediaType)
            console.log('✅ Successfully subscribed to', mediaType, 'track for user', user.uid)
            
            // Wait for tracks to be populated after subscription
            // Poll up to 1 second for tracks to become available
            let trackFound = false
            let pollAttempts = 0
            const maxPollAttempts = 10
            const pollInterval = 100
            
            while (!trackFound && pollAttempts < maxPollAttempts) {
              await new Promise(resolve => setTimeout(resolve, pollInterval))
              
              // Get fresh user reference from client.remoteUsers after subscribe
              const remoteUser = client.value!.remoteUsers.find(u => u.uid === user.uid)
              
              if (remoteUser) {
                if (mediaType === 'video') {
                  const videoTrack = remoteUser.videoTrack
                  if (videoTrack) {
                    console.log('✅ Video track found after', (pollAttempts + 1) * pollInterval, 'ms, Track ID:', videoTrack.getTrackId())
                    remoteVideoTrack.value = videoTrack
                    remoteUid.value = remoteUser.uid
                    trackFound = true
                    console.log('✅ Remote video track set successfully - track will play via watcher in DashboardView')
                  }
                }
                if (mediaType === 'audio') {
                  const audioTrack = remoteUser.audioTrack
                  if (audioTrack) {
                    console.log('✅ Audio track found after', (pollAttempts + 1) * pollInterval, 'ms, Track ID:', audioTrack.getTrackId())
                    remoteAudioTrack.value = audioTrack
                    try {
                      await audioTrack.play()
                      trackFound = true
                      console.log('✅ Remote audio track set and playing successfully')
                    } catch (playErr) {
                      console.error('❌ Failed to play audio track:', playErr)
                      // Track is set even if play fails - browser autoplay restrictions might prevent it
                      trackFound = true
                    }
                  }
                }
              }
              
              if (!trackFound) {
                pollAttempts++
                if (pollAttempts < maxPollAttempts) {
                  console.log(`Waiting for ${mediaType} track... (attempt ${pollAttempts + 1}/${maxPollAttempts})`)
                }
              }
            }
            
            if (!trackFound) {
              const remoteUser = client.value!.remoteUsers.find(u => u.uid === user.uid)
              console.warn(`⚠ ${mediaType} track not found after ${maxPollAttempts * pollInterval}ms`)
              if (remoteUser) {
                console.warn('Remote user exists but track is null:', {
                  hasVideoTrack: !!remoteUser.videoTrack,
                  hasAudioTrack: !!remoteUser.audioTrack,
                  uid: remoteUser.uid
                })
              } else {
                console.warn('⚠ Remote user not found in client.remoteUsers')
                console.log('Available remote users:', client.value!.remoteUsers.map(u => u.uid))
              }
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


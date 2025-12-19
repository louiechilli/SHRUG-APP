import { ref } from 'vue'

// Use WebSocket through port 443 (HTTPS) for Cloudflare compatibility
// Cloudflare only proxies ports 80 and 443, so we route /ws through the main domain
const getWebSocketUrl = () => {
  const envUrl = import.meta.env.VITE_WS_URL
  const isProduction = window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1'
  
  if (isProduction) {
    // In production, use wss://getshrug.app/ws (port 443 via nginx)
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
    return `${protocol}//${window.location.hostname}/ws`
  } else {
    // In development, use the env variable or default to localhost:8080
    return envUrl || 'ws://localhost:8080'
  }
}

const WS_URL = getWebSocketUrl()

export type SignalingMessage = 
  | { type: 'join'; userId: string; gender: string; genderPreference: string }
  | { type: 'matched'; peerId: string; channelName: string }
  | { type: 'offer'; offer: RTCSessionDescriptionInit }
  | { type: 'answer'; answer: RTCSessionDescriptionInit }
  | { type: 'ice-candidate'; candidate: RTCIceCandidateInit }
  | { type: 'peer-left' }
  | { type: 'skip' }
  | { type: 'leave-queue' }
  | { type: 'error'; message: string }

// Singleton state
const socket = ref<WebSocket | null>(null)
const connected = ref(false)
const peerId = ref<string | null>(null)
const messageHandlers = new Map<string, (data: any) => void>()

export function useSignaling() {

  function connect(userId: string): Promise<void> {
    return new Promise((resolve, reject) => {
      socket.value = new WebSocket(`${WS_URL}?userId=${userId}`)

      socket.value.onopen = () => {
        connected.value = true
        resolve()
      }

      socket.value.onerror = (err) => {
        reject(err)
      }

      socket.value.onclose = () => {
        connected.value = false
        peerId.value = null
      }

      socket.value.onmessage = (event) => {
        const message = JSON.parse(event.data) as SignalingMessage
        
        if (message.type === 'matched') {
          peerId.value = message.peerId
        }

        const handler = messageHandlers.get(message.type)
        if (handler) {
          handler(message)
        }
      }
    })
  }

  function send(message: SignalingMessage) {
    if (socket.value && connected.value) {
      socket.value.send(JSON.stringify(message))
    }
  }

  function on(type: string, handler: (data: any) => void) {
    messageHandlers.set(type, handler)
  }

  function off(type: string) {
    messageHandlers.delete(type)
  }

  function joinQueue(userId: string, gender: string, genderPreference: string) {
    send({ type: 'join', userId, gender, genderPreference })
  }

  function skip() {
    send({ type: 'skip' })
  }

  function leaveQueue() {
    send({ type: 'leave-queue' })
  }

  function disconnect() {
    if (socket.value) {
      socket.value.close()
      socket.value = null
    }
    connected.value = false
    peerId.value = null
  }

  return {
    connected,
    peerId,
    connect,
    on,
    off,
    joinQueue,
    skip,
    leaveQueue,
    disconnect,
  }
}


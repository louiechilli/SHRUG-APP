import { ref } from 'vue'

const ICE_SERVERS = [
  { urls: 'stun:stun.l.google.com:19302' },
  { urls: 'stun:stun1.l.google.com:19302' },
]

export type CallState = 'idle' | 'searching' | 'connecting' | 'connected' | 'ended'

// Singleton state
const peerConnection = ref<RTCPeerConnection | null>(null)
const localStream = ref<MediaStream | null>(null)
const remoteStream = ref<MediaStream | null>(null)
const callState = ref<CallState>('idle')
const error = ref<string | null>(null)
const pendingCandidates: RTCIceCandidateInit[] = []

export function useWebRTC() {

  async function initLocalStream() {
    try {
      localStream.value = await navigator.mediaDevices.getUserMedia({
        video: true,
        audio: true
      })
      return localStream.value
    } catch (err) {
      error.value = 'Failed to access camera/microphone'
      throw err
    }
  }

  function createPeerConnection(onIceCandidate: (candidate: RTCIceCandidate) => void) {
    const pc = new RTCPeerConnection({ iceServers: ICE_SERVERS })

    pc.onicecandidate = (event) => {
      if (event.candidate) {
        onIceCandidate(event.candidate)
      }
    }

    pc.ontrack = (event) => {
      remoteStream.value = event.streams[0]
    }

    pc.onconnectionstatechange = () => {
      if (pc.connectionState === 'connected') {
        callState.value = 'connected'
      } else if (pc.connectionState === 'disconnected' || pc.connectionState === 'failed') {
        callState.value = 'ended'
      }
    }

    // Add local tracks
    if (localStream.value) {
      localStream.value.getTracks().forEach(track => {
        pc.addTrack(track, localStream.value!)
      })
    }

    peerConnection.value = pc
    return pc
  }

  async function createOffer() {
    if (!peerConnection.value) return null
    const offer = await peerConnection.value.createOffer()
    await peerConnection.value.setLocalDescription(offer)
    return offer
  }

  async function createAnswer(offer: RTCSessionDescriptionInit) {
    if (!peerConnection.value) return null
    await peerConnection.value.setRemoteDescription(offer)
    // Process any pending ICE candidates
    await processPendingCandidates()
    const answer = await peerConnection.value.createAnswer()
    await peerConnection.value.setLocalDescription(answer)
    return answer
  }

  async function setRemoteAnswer(answer: RTCSessionDescriptionInit) {
    if (!peerConnection.value) return
    if (peerConnection.value.signalingState === 'have-local-offer') {
      await peerConnection.value.setRemoteDescription(answer)
      // Process any pending ICE candidates
      await processPendingCandidates()
    }
  }

  async function processPendingCandidates() {
    if (!peerConnection.value) return
    while (pendingCandidates.length > 0) {
      const candidate = pendingCandidates.shift()!
      await peerConnection.value.addIceCandidate(candidate)
    }
  }

  async function addIceCandidate(candidate: RTCIceCandidateInit) {
    if (!peerConnection.value) return
    // Queue if remote description not set yet
    if (!peerConnection.value.remoteDescription) {
      pendingCandidates.push(candidate)
      return
    }
    await peerConnection.value.addIceCandidate(candidate)
  }

  function endCall() {
    // Stop all remote tracks
    if (remoteStream.value) {
      remoteStream.value.getTracks().forEach(track => track.stop())
      remoteStream.value = null
    }
    
    // Close peer connection
    if (peerConnection.value) {
      // Remove all event handlers to prevent callbacks after close
      peerConnection.value.onicecandidate = null
      peerConnection.value.ontrack = null
      peerConnection.value.onconnectionstatechange = null
      peerConnection.value.close()
      peerConnection.value = null
    }
    
    callState.value = 'idle'
    pendingCandidates.length = 0
  }

  function stopLocalStream() {
    if (localStream.value) {
      localStream.value.getTracks().forEach(track => track.stop())
      localStream.value = null
    }
  }

  return {
    peerConnection,
    localStream,
    remoteStream,
    callState,
    error,
    initLocalStream,
    createPeerConnection,
    createOffer,
    createAnswer,
    setRemoteAnswer,
    addIceCandidate,
    endCall,
    stopLocalStream,
  }
}


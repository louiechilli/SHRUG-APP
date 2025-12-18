import { WebSocketServer } from 'ws'

const PORT = process.env.PORT || 8080

const wss = new WebSocketServer({ port: PORT })

// Connected users: Map<userId, { ws, gender, genderPreference, peerId }>
const users = new Map()

// Matchmaking queue: Array<userId>
const queue = []

console.log(`Signaling server running on ws://localhost:${PORT}`)

wss.on('connection', (ws, req) => {
  const url = new URL(req.url, `http://localhost:${PORT}`)
  const userId = url.searchParams.get('userId')

  if (!userId) {
    ws.close(1008, 'userId required')
    return
  }

  console.log(`User connected: ${userId}`)

  users.set(userId, { ws, gender: null, genderPreference: null, peerId: null })

  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data.toString())
      handleMessage(userId, message)
    } catch (err) {
      console.error('Failed to parse message:', err)
    }
  })

  ws.on('close', () => {
    console.log(`User disconnected: ${userId}`)
    handleDisconnect(userId)
  })
})

function handleMessage(userId, message) {
  const user = users.get(userId)
  if (!user) return

  switch (message.type) {
    case 'join':
      handleJoin(userId, message.gender, message.genderPreference)
      break

    case 'offer':
    case 'answer':
    case 'ice-candidate':
      // Forward to peer
      if (user.peerId) {
        const peer = users.get(user.peerId)
        if (peer) {
          peer.ws.send(JSON.stringify(message))
        }
      }
      break

    case 'skip':
      handleSkip(userId)
      break

    case 'leave-queue':
      handleLeaveQueue(userId)
      break
  }
}

function handleJoin(userId, gender, genderPreference) {
  console.log(`handleJoin: userId=${userId}, gender=${gender}, genderPreference=${genderPreference}`)
  const user = users.get(userId)
  if (!user) return

  user.gender = gender
  user.genderPreference = genderPreference

  // Remove from queue if already in it
  const queueIndex = queue.indexOf(userId)
  if (queueIndex > -1) {
    queue.splice(queueIndex, 1)
  }

  // Try to find a match
  const matchId = findMatch(userId, gender, genderPreference)

  if (matchId) {
    // Match found!
    const match = users.get(matchId)
    
    // Remove match from queue
    const matchQueueIndex = queue.indexOf(matchId)
    if (matchQueueIndex > -1) {
      queue.splice(matchQueueIndex, 1)
    }

    // Set peer IDs
    user.peerId = matchId
    match.peerId = userId

    // Generate unique channel name for this call
    const channelName = `call_${Date.now()}_${userId}_${matchId}`

    console.log(`Matched: ${userId} <-> ${matchId} on channel: ${channelName}`)

    // Notify both users with channel info
    user.ws.send(JSON.stringify({ type: 'matched', peerId: matchId, channelName }))
    match.ws.send(JSON.stringify({ type: 'matched', peerId: userId, channelName }))
  } else {
    // No match, add to queue
    queue.push(userId)
    console.log(`User ${userId} added to queue. Queue size: ${queue.length}`)
  }
}

// Map preference labels to gender values
function prefMatchesGender(preference, gender) {
  if (preference === 'both') return true
  if (preference === 'girls' && gender === 'female') return true
  if (preference === 'guys' && gender === 'male') return true
  return preference === gender // fallback for direct match
}

function findMatch(userId, gender, genderPreference) {
  console.log(`Finding match for ${userId}: gender=${gender}, preference=${genderPreference}`)
  console.log(`Queue:`, queue.map(id => {
    const u = users.get(id)
    return { id, gender: u?.gender, pref: u?.genderPreference }
  }))
  
  for (const candidateId of queue) {
    if (candidateId === userId) continue

    const candidate = users.get(candidateId)
    if (!candidate) continue

    // Check if preferences match
    const userWantsCandidate = prefMatchesGender(genderPreference, candidate.gender)
    const candidateWantsUser = prefMatchesGender(candidate.genderPreference, gender)

    console.log(`Checking ${candidateId}: userWants=${userWantsCandidate}, candidateWants=${candidateWantsUser}`)

    if (userWantsCandidate && candidateWantsUser) {
      return candidateId
    }
  }

  return null
}

function handleSkip(userId) {
  const user = users.get(userId)
  if (!user) return

  const peerId = user.peerId

  // Notify peer they've been skipped
  if (peerId) {
    const peer = users.get(peerId)
    if (peer) {
      peer.ws.send(JSON.stringify({ type: 'peer-left' }))
      peer.peerId = null
      // Put peer back in queue
      if (!queue.includes(peerId)) {
        queue.push(peerId)
      }
    }
  }

  // Clear user's peer
  user.peerId = null

  // Re-join queue with same preferences
  if (user.gender && user.genderPreference) {
    handleJoin(userId, user.gender, user.genderPreference)
  }
}

function handleLeaveQueue(userId) {
  const user = users.get(userId)
  if (!user) return

  console.log(`User ${userId} leaving queue - immediate cleanup`)

  // Remove from queue first
  const queueIndex = queue.indexOf(userId)
  if (queueIndex > -1) {
    queue.splice(queueIndex, 1)
    console.log(`Removed ${userId} from queue`)
  }

  // Clear preferences IMMEDIATELY so they won't be matched
  user.gender = null
  user.genderPreference = null

  // If matched with someone, notify them immediately
  if (user.peerId) {
    const peerId = user.peerId
    const peer = users.get(peerId)
    
    // Clear peer references BEFORE sending message
    user.peerId = null
    
    if (peer) {
      peer.peerId = null
      console.log(`Notifying peer ${peerId} that ${userId} left`)
      peer.ws.send(JSON.stringify({ type: 'peer-left' }))
    }
  }
}

function handleDisconnect(userId) {
  const user = users.get(userId)
  
  if (user && user.peerId) {
    const peer = users.get(user.peerId)
    if (peer) {
      peer.ws.send(JSON.stringify({ type: 'peer-left' }))
      peer.peerId = null
    }
  }

  // Remove from queue
  const queueIndex = queue.indexOf(userId)
  if (queueIndex > -1) {
    queue.splice(queueIndex, 1)
  }

  users.delete(userId)
}


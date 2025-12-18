// WorkOS AuthKit configuration
const WORKOS_CLIENT_ID = import.meta.env.VITE_WORKOS_CLIENT_ID
const REDIRECT_URI = import.meta.env.VITE_WORKOS_REDIRECT_URI ?? `${window.location.origin}/auth/callback`

// Generate a random state for CSRF protection
function generateState(): string {
  const array = new Uint8Array(32)
  crypto.getRandomValues(array)
  return Array.from(array, byte => byte.toString(16).padStart(2, '0')).join('')
}

// Build the WorkOS authorization URL
export function getAuthorizationUrl(provider: 'GoogleOAuth' | 'AppleOAuth' | 'MicrosoftOAuth' = 'GoogleOAuth'): string {
  const state = generateState()
  localStorage.setItem('workos_state', state)

  const params = new URLSearchParams({
    client_id: WORKOS_CLIENT_ID,
    redirect_uri: REDIRECT_URI,
    response_type: 'code',
    state,
    provider,
  })

  return `https://api.workos.com/user_management/authorize?${params.toString()}`
}

// Handle the OAuth callback - exchange code for session
export async function handleCallback(code: string, state: string): Promise<{ user: any; accessToken: string }> {
  const savedState = localStorage.getItem('workos_state')
  
  if (state !== savedState) {
    throw new Error('Invalid state parameter - possible CSRF attack')
  }
  
  localStorage.removeItem('workos_state')

  // Exchange the code for tokens via your backend
  // WorkOS requires server-side token exchange for security
  const response = await fetch(`${import.meta.env.VITE_API_BASE_URL}/auth/workos/callback`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ code }),
  })

  if (!response.ok) {
    throw new Error('Failed to authenticate')
  }

  return response.json()
}

export function loginWithGoogle() {
  window.location.href = getAuthorizationUrl('GoogleOAuth')
}

export function loginWithApple() {
  window.location.href = getAuthorizationUrl('AppleOAuth')
}


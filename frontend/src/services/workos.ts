// WorkOS AuthKit configuration
const WORKOS_CLIENT_ID = import.meta.env.VITE_WORKOS_CLIENT_ID
const REDIRECT_URI = import.meta.env.VITE_WORKOS_REDIRECT_URI ?? `${window.location.origin}/auth/callback`

// Debug logging (always log in browser console for troubleshooting)
console.log('WorkOS Configuration:', {
  clientId: WORKOS_CLIENT_ID ? `${WORKOS_CLIENT_ID.substring(0, 20)}...` : 'NOT SET - THIS IS THE PROBLEM!',
  fullClientId: WORKOS_CLIENT_ID || 'UNDEFINED',
  redirectUri: REDIRECT_URI,
  hasClientId: !!WORKOS_CLIENT_ID,
  envCheck: import.meta.env.VITE_WORKOS_CLIENT_ID || 'NOT IN ENV'
})

// Validate WorkOS client ID is configured
if (!WORKOS_CLIENT_ID) {
  console.error('VITE_WORKOS_CLIENT_ID is not configured. Please set it in your environment variables.')
}

// Generate a random state for CSRF protection
function generateState(): string {
  const array = new Uint8Array(32)
  crypto.getRandomValues(array)
  return Array.from(array, byte => byte.toString(16).padStart(2, '0')).join('')
}

// Build the WorkOS authorization URL
export function getAuthorizationUrl(provider: 'GoogleOAuth' | 'AppleOAuth' | 'MicrosoftOAuth' = 'GoogleOAuth'): string {
  if (!WORKOS_CLIENT_ID) {
    throw new Error('WorkOS Client ID is not configured. Please set VITE_WORKOS_CLIENT_ID environment variable.')
  }
  
  const state = generateState()
  localStorage.setItem('workos_state', state)

  const params = new URLSearchParams({
    client_id: WORKOS_CLIENT_ID,
    redirect_uri: REDIRECT_URI,
    response_type: 'code',
    state,
    provider,
  })

  const authUrl = `https://api.workos.com/user_management/authorize?${params.toString()}`
  
  // Debug logging - always show in console
  console.log('WorkOS Authorization Request:', {
    clientId: WORKOS_CLIENT_ID,
    redirectUri: REDIRECT_URI,
    provider,
    fullUrl: authUrl,
    paramsObject: Object.fromEntries(params)
  })

  return authUrl
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
  // FORCE production URL - always use production in deployed environment
  const envApiUrl = import.meta.env.VITE_API_BASE_URL
  const isProduction = window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1'
  
  // Always use production URL in production, ignore env variable if it's localhost
  let apiUrl = 'https://api.getshrug.app/api/v1'
  if (!isProduction) {
    // Only use env variable in development
    apiUrl = envApiUrl || 'http://localhost:8000/api/v1'
  } else {
    // In production, check if env var is localhost and warn
    if (envApiUrl && envApiUrl.includes('localhost')) {
      console.warn('⚠️ Localhost API URL detected in production build. Using production URL instead.')
      console.warn('⚠️ Please rebuild with correct VITE_API_BASE_URL in .env file')
    }
  }
  
  console.log('WorkOS Callback API URL (final):', apiUrl)
  console.log('Environment:', { envApiUrl, isProduction, hostname: window.location.hostname })
  
  const response = await fetch(`${apiUrl}/auth/workos/callback`, {
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


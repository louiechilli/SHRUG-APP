import axios from 'axios'

// Use production URL if localhost is detected (fallback for build issues)
const getApiBaseUrl = () => {
  const envUrl = import.meta.env.VITE_API_BASE_URL
  // If we're in production and still have localhost, use production URL
  if (envUrl?.includes('localhost') && window.location.hostname !== 'localhost') {
    console.warn('Localhost API URL detected in production, using production URL instead')
    return 'https://api.getshrug.app/api/v1'
  }
  return envUrl || 'https://api.getshrug.app/api/v1'
}

const api = axios.create({
  baseURL: getApiBaseUrl(),
  headers: {
    Accept: 'application/json',
  },
})

console.log('API Base URL:', getApiBaseUrl())

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('auth_token')
  if (token) {
    config.headers = config.headers ?? {}
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

export default api



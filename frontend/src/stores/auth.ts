import { defineStore } from 'pinia'
import api from '../services/api'

export type ApiUser = {
  id: number
  name: string
  email: string
  avatar: string | null
  location: string | null
  age: number | null
  gender: 'male' | 'female' | 'other' | null
  bio: string | null
  created_at: string | null
  updated_at: string | null
}

type AuthState = {
  token: string | null
  user: ApiUser | null
  bootstrapped: boolean
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    token: localStorage.getItem('auth_token'),
    user: null,
    bootstrapped: false,
  }),
  getters: {
    isAuthenticated: (s) => !!s.token,
  },
  actions: {
    setToken(token: string) {
      this.token = token
      localStorage.setItem('auth_token', token)
    },
    clearAuth() {
      this.token = null
      this.user = null
      localStorage.removeItem('auth_token')
    },
    async bootstrap() {
      if (this.bootstrapped) return
      this.bootstrapped = true

      if (!this.token) return
      try {
        await this.fetchMe()
      } catch {
        // If the token is invalid, fetchMe clears auth.
      }
    },
    async register(payload: { name: string; email: string; password: string; password_confirmation: string }) {
      const { data } = await api.post('/auth/register', payload)
      this.setToken(data.token)
      this.user = data.user
      return data.user as ApiUser
    },
    async login(payload: { email: string; password: string }) {
      const { data } = await api.post('/auth/login', payload)
      this.setToken(data.token)
      this.user = data.user
      return data.user as ApiUser
    },
    async fetchMe() {
      try {
        const { data } = await api.get('/auth/me')
        this.user = data.user
        return data.user as ApiUser
      } catch (err: any) {
        if (err?.response?.status === 401) {
          this.clearAuth()
        }
        throw err
      }
    },
    async logout() {
      try {
        if (this.token) await api.post('/auth/logout')
      } finally {
        this.clearAuth()
      }
    },
    async updateProfile(payload: { name?: string; bio?: string | null; avatar?: string }) {
      const { data } = await api.put('/auth/me', payload)
      this.user = data.user
      return data.user as ApiUser
    },
  },
})



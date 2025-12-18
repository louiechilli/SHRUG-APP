import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'login',
      meta: { guestOnly: true },
      component: () => import('../views/LoginView.vue'),
    },
    {
      path: '/login',
      redirect: '/',
    },
    {
      path: '/register',
      name: 'register',
      meta: { guestOnly: true },
      component: () => import('../views/RegisterView.vue'),
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      meta: { requiresAuth: true, requiresProfile: true },
      component: () => import('../views/DashboardView.vue'),
    },
    {
      path: '/onboarding',
      name: 'onboarding',
      meta: { requiresAuth: true },
      component: () => import('../views/OnboardingView.vue'),
    },
    {
      path: '/auth/callback',
      name: 'auth-callback',
      component: () => import('../views/AuthCallbackView.vue'),
    },
    { path: '/:pathMatch(.*)*', name: 'notfound', component: () => import('../views/NotFoundView.vue') },
  ],
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()

  // Ensure we resolve the current user once if a token exists.
  if (!auth.bootstrapped) await auth.bootstrap()

  if (to.meta.requiresAuth && !auth.token) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }

  // Force onboarding if gender or birthdate not set (for all authenticated routes except onboarding itself and auth callback)
  if (auth.token && to.name !== 'onboarding' && to.name !== 'auth-callback') {
    // Ensure user is loaded
    if (!auth.user) {
      try {
        await auth.fetchMe()
      } catch {
        return { name: 'login' }
      }
    }
    
    if (auth.user) {
      const needsOnboarding = !auth.user.gender || auth.user.age === null
      if (needsOnboarding) {
        return { name: 'onboarding' }
      }
    }
  }

  if (to.meta.guestOnly && auth.token) {
    return { name: 'dashboard' }
  }
})

export default router



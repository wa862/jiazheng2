import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('../views/frontend/Home.vue')
  },
  {
    path: '/services',
    name: 'Services',
    component: () => import('../views/frontend/Services.vue')
  },
  {
    path: '/worker/:id',
    name: 'WorkerDetail',
    component: () => import('../views/frontend/WorkerDetail.vue')
  },
  {
    path: '/booking',
    name: 'Booking',
    component: () => import('../views/frontend/Booking.vue')
  },
  {
    path: '/orders',
    name: 'Orders',
    component: () => import('../views/frontend/Orders.vue')
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('../views/frontend/Profile.vue')
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/auth/Login.vue')
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('../views/auth/Register.vue')
  },
  {
    path: '/forgot-password',
    name: 'ForgotPassword',
    component: () => import('../views/auth/ForgotPassword.vue')
  },
  {
    path: '/admin/login',
    name: 'AdminLogin',
    component: () => import('../views/auth/AdminLogin.vue')
  },
  {
    path: '/smart-match',
    name: 'SmartMatch',
    component: () => import('../views/frontend/SmartMatch.vue')
  },
  {
    path: '/ai-recommendation',
    name: 'AIRecommendation',
    component: () => import('../views/frontend/AIRecommendationSimplified.vue')
  },
  {
    path: '/service-map',
    name: 'ServiceMap',
    component: () => import('../views/frontend/ServiceMap.vue')
  },

  {
    path: '/test',
    name: 'TestPage',
    component: () => import('../views/frontend/TestPage.vue')
  },
  // 前台项目不再内置后台管理路由，真实后台使用根目录 admin 系统
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
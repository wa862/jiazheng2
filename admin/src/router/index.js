import { createRouter, createWebHashHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/admin/login'
  },
  {
    path: '/admin/login',
    name: 'AdminLogin',
    component: () => import('@views/auth/Login.vue'),
    meta: { title: '管理员登录', public: true }
  },
  {
    path: '/admin',
    redirect: '/admin/login'
  },
  {
    path: '/admin/login',
    name: 'AdminLogin',
    component: () => import('@views/auth/Login.vue'),
    meta: { title: '管理员登录', public: true }
  },
  {
    path: '/admin',
    redirect: '/admin/dashboard'
  },
  {
    path: '/admin/dashboard',
    name: 'Dashboard',
    component: () => import('@views/dashboard/Index.vue'),
    meta: { title: '数据看板' }
  },
  // 用户管理
  {
    path: '/admin/users',
    name: 'Users',
    component: () => import('@views/users/Index.vue'),
    meta: { title: '用户管理' }
  },
  {
    path: '/admin/user-feedback',
    name: 'UserFeedback',
    component: () => import('@views/users/Feedback.vue'),
    meta: { title: '用户反馈' }
  },
  // 家政人员管理
  {
    path: '/admin/workers',
    name: 'Workers',
    component: () => import('@views/workers/Index.vue'),
    meta: { title: '家政人员管理' }
  },
  {
    path: '/admin/worker-applications',
    name: 'WorkerApplications',
    component: () => import('@views/workers/Applications.vue'),
    meta: { title: '入驻申请' }
  },
  {
    path: '/admin/worker-certifications',
    name: 'WorkerCertifications',
    component: () => import('@views/workers/Certifications.vue'),
    meta: { title: '资质认证' }
  },
  // 订单管理
  {
    path: '/admin/orders',
    name: 'Orders',
    component: () => import('@views/orders/Index.vue'),
    meta: { title: '订单管理' }
  },
  {
    path: '/admin/order-disputes',
    name: 'OrderDisputes',
    component: () => import('@views/orders/Disputes.vue'),
    meta: { title: '纠纷处理' }
  },
  // 评价管理
  {
    path: '/admin/reviews',
    name: 'Reviews',
    component: () => import('@views/reviews/Index.vue'),
    meta: { title: '评价管理' }
  },
  // 智能算法管理
  {
    path: '/admin/algorithm',
    name: 'Algorithm',
    component: () => import('@views/algorithm/Index.vue'),
    meta: { title: '算法配置' }
  },
  {
    path: '/admin/algorithm-performance',
    name: 'AlgorithmPerformance',
    component: () => import('@views/algorithm/Performance.vue'),
    meta: { title: '性能监控' }
  },
  // 数据统计
  {
    path: '/admin/statistics',
    name: 'Statistics',
    component: () => import('@views/statistics/Index.vue'),
    meta: { title: '运营数据' }
  },
  {
    path: '/admin/financial-stats',
    name: 'FinancialStats',
    component: () => import('@views/statistics/Financial.vue'),
    meta: { title: '财务统计' }
  },
  {
    path: '/admin/user-behavior',
    name: 'UserBehavior',
    component: () => import('@views/statistics/UserBehavior.vue'),
    meta: { title: '用户行为' }
  },
  // 轮播图管理
  {
    path: '/admin/banners',
    name: 'Banners',
    component: () => import('@views/banners/Index.vue'),
    meta: { title: '轮播图管理' }
  },
  // 系统设置
  {
    path: '/admin/system-settings',
    name: 'SystemSettings',
    component: () => import('@views/settings/Index.vue'),
    meta: { title: '系统设置' }
  },
  {
    path: '/admin/notice-management',
    name: 'NoticeManagement',
    component: () => import('@views/system/Notices.vue'),
    meta: { title: '公告管理' }
  },
  {
    path: '/admin/operation-logs',
    name: 'OperationLogs',
    component: () => import('@views/system/Logs.vue'),
    meta: { title: '操作日志' }
  },
  // 个人中心
  {
    path: '/admin/profile',
    name: 'AdminProfile',
    component: () => import('@views/profile/Index.vue'),
    meta: { title: '个人中心' }
  },
  {
    path: '/admin/settings',
    name: 'AdminSettings',
    component: () => import('@views/profile/Settings.vue'),
    meta: { title: '账号设置' }
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  document.title = to.meta.title ? `${to.meta.title} - 家政服务管理系统` : '家政服务管理系统'
  
  const token = localStorage.getItem('adminToken')
  if (!to.meta.public && !token) {
    next('/admin/login')
  } else {
    next()
  }
})

export default router

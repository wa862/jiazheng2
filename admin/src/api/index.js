import request from '@utils/request'

export const login = (data) => {
  // 管理员登录：调用后端 /api/auth/admin/login
  return request.post('/auth/admin/login', data)
}

export const logout = () => {
  return request.post('/admin/logout')
}

export const getAdminInfo = () => {
  return request.get('/admin/info')
}

export const changePassword = (data) => {
  return request.post('/auth/change-password', data)
}

export const getNotices = () => request.get('/admin/notices')
export const markNoticeRead = (noticeId) => request.post(`/admin/notices/read/${encodeURIComponent(noticeId)}`)
export const markAllNoticesRead = () => request.post('/admin/notices/read-all')

export const getStatistics = () => {
  return request.get('/admin/statistics')
}

export const getTrendData = (params) => {
  return request.get('/admin/trend', { params })
}

export const getServiceDistribution = () => {
  return request.get('/admin/service-distribution')
}

export const getUsers = (params) => {
  return request.get('/admin/users', { params })
}

export const createUser = (data) => {
  return request.post('/admin/users', data)
}

export const updateUser = (id, data) => {
  return request.put(`/admin/users/${id}`, data)
}

export const updateUserStatus = (id, data) => {
  return request.put(`/admin/users/${id}/status`, data)
}

export const enableAllUsers = () => {
  return request.put('/admin/users/enable-all')
}

export const deleteUser = (id) => {
  return request.delete(`/admin/users/${id}`)
}

export const getWorkers = (params) => {
  return request.get('/admin/workers', { params })
}

export const createWorker = (data) => {
  return request.post('/admin/workers', data)
}

export const updateWorker = (id, data) => {
  return request.put(`/admin/workers/${id}`, data)
}

export const deleteWorker = (id) => {
  return request.delete(`/admin/workers/${id}`)
}

export const getOrders = (params) => {
  return request.get('/admin/orders', { params })
}

export const updateOrderStatus = (id, data) => {
  return request.put(`/admin/orders/${id}/status`, data)
}

export const getReviews = (params) => {
  return request.get('/admin/reviews', { params })
}

export const deleteReview = (id) => {
  return request.delete(`/admin/reviews/${id}`)
}

export const updateReviewStatus = (id, data) => {
  return request.put(`/admin/reviews/${id}/status`, data)
}

export const getAlgorithmConfig = () => {
  return request.get('/admin/algorithm/config')
}

export const updateAlgorithmConfig = (data) => {
  return request.put('/admin/algorithm/config', data)
}

export const getAlgorithmMetrics = () => {
  return request.get('/admin/algorithm/metrics')
}

export const getStatisticsData = (params) => {
  return request.get('/admin/statistics/data', { params })
}

// 图片上传（家政人员头像等），返回如 uploads/xxx.png
export const uploadImage = (file) => {
  const formData = new FormData()
  formData.append('file', file)
  return request.post('/upload/image', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

// 轮播图管理
export const getBanners = () => {
  return request.get('/admin/banners')
}

export const createBanner = (data) => {
  return request.post('/admin/banners', data)
}

export const updateBanner = (id, data) => {
  return request.put(`/admin/banners/${id}`, data)
}

export const deleteBanner = (id) => {
  return request.delete(`/admin/banners/${id}`)
}

// 系统设置
export const getSettings = () => {
  return request.get('/admin/settings')
}

export const updateSettings = (data) => {
  return request.put('/admin/settings', data)
}

// 用户反馈管理
export const getFeedbacks = (params) => {
  return request.get('/admin/feedbacks', { params })
}

export const getFeedbackById = (id) => {
  return request.get(`/admin/feedbacks/${id}`)
}

export const replyFeedback = (id, data) => {
  return request.post(`/admin/feedbacks/${id}/reply`, data)
}

// 家政人员入驻申请管理
export const getApplications = (params) => {
  return request.get('/admin/applications', { params })
}

export const getApplicationById = (id) => {
  return request.get(`/admin/applications/${id}`)
}

export const getApplicationStats = () => {
  return request.get('/admin/applications/stats')
}

export const approveApplication = (id, data) => {
  return request.post(`/admin/applications/${id}/approve`, data)
}

export const rejectApplication = (id, data) => {
  return request.post(`/admin/applications/${id}/reject`, data)
}

export const deleteApplication = (id) => {
  return request.delete(`/admin/applications/${id}`)
}

export const updateFeedbackStatus = (id, data) => {
  return request.put(`/admin/feedbacks/${id}/status`, data)
}

export const deleteFeedback = (id) => {
  return request.delete(`/admin/feedbacks/${id}`)
}

export const getFeedbackStats = () => {
  return request.get('/admin/feedbacks/stats')
}

import request from '../utils/request'

export const getWorkers = (params) => request.get('/workers', { params })
export const getWorkerById = (id) => request.get(`/workers/${id}`)
export const getWorkerServices = (id) => request.get(`/workers/${id}/services`)
export const getRecommendedWorkers = (userId) => request.get(`/workers/recommended/${userId}`)
export const searchWorkers = (keyword) => request.get('/workers/search', { params: { keyword } })
/** 首页展示配置（热门家政人员数量、标题等，来自管理端系统设置） */
export const getHomeConfig = () => request.get('/workers/home-config')

export const createOrder = (data) => request.post('/orders', data)
// 订单列表，统一后端返回结构为 data.list + data.total
export const getOrders = async (params) => {
  const res = await request.get('/orders', { params })
  if (res && res.data && res.data.content) {
    const page = res.data
    return {
      ...res,
      data: {
        ...page,
        list: page.list || page.content,
        total: page.total ?? page.totalElements ?? page.content.length
      }
    }
  }
  return res
}
export const getOrderById = (id) => request.get(`/orders/${id}`)
export const cancelOrder = (id) => request.put(`/orders/${id}/cancel`)
export const updateOrderStatus = (id, orderStatus) => request.put(`/orders/${id}/status`, { orderStatus })
export const updatePaymentStatus = (id, paymentStatus, paymentMethod, transactionId) => request.put(`/orders/${id}/payment`, { paymentStatus, paymentMethod, transactionId })
export const addReview = (id, rating, content) => request.put(`/orders/${id}/review`, { rating, reviewContent: content })
export const deleteOrder = (id) => request.delete(`/orders/${id}`)

export const createReview = (data) => request.post('/reviews', data)
export const getReviews = (params) => request.get('/reviews', { params })
export const getWorkerReviews = (workerId) => request.get(`/reviews/worker/${workerId}`)

export const login = (data) => request.post('/auth/login', data)
export const register = (data) => request.post('/auth/register', data)
export const adminLogin = (data) => request.post('/auth/admin/login', data)
export const getUserInfo = () => request.get('/auth/info')
export const updateUserInfo = (data) => request.post('/auth/info/update', data)

/** 上传图片（multipart/form-data），返回图片路径，如 uploads/xxx.png */
export const uploadImage = (file) => {
  const formData = new FormData()
  formData.append('file', file)
  return request.post('/upload/image', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}
export const changePassword = (data) => request.post('/auth/change-password', data)

export const getStatistics = () => request.get('/admin/statistics')
export const getTrendData = () => request.get('/admin/trend')
export const getServiceDistribution = () => request.get('/admin/service-distribution')

export const updateAlgorithmConfig = (data) => request.put('/admin/algorithm/config', data)
export const getAlgorithmConfig = () => request.get('/admin/algorithm/config')
export const getAlgorithmMetrics = () => request.get('/admin/algorithm/metrics')

// 用户管理，统一分页结构为 data.list + data.total
export const getUsers = async (params) => {
  const res = await request.get('/admin/users', { params })
  if (res && res.data && res.data.content) {
    const page = res.data
    return {
      ...res,
      data: {
        ...page,
        list: page.list || page.content,
        total: page.total ?? page.totalElements ?? page.content.length
      }
    }
  }
  return res
}
export const createUser = (data) => request.post('/admin/users', data)
export const updateUser = (id, data) => request.put(`/admin/users/${id}`, data)
export const deleteUser = (id) => request.delete(`/admin/users/${id}`)

// 家政人员管理
export const createWorker = (data) => request.post('/admin/workers', data)
export const updateWorker = (id, data) => request.put(`/admin/workers/${id}`, data)
export const deleteWorker = (id) => request.delete(`/admin/workers/${id}`)

// 评价管理
export const deleteReview = (id) => request.delete(`/admin/reviews/${id}`)

// 服务分类管理（后台）
export const getCategories = () => request.get('/admin/categories')

// 服务分类（前台公开接口）
export const getPublicCategories = () => request.get('/workers/categories')
export const createCategory = (data) => request.post('/admin/categories', data)
export const updateCategory = (id, data) => request.put(`/admin/categories/${id}`, data)
export const deleteCategory = (id) => request.delete(`/admin/categories/${id}`)

// 轮播图管理
export const getBanners = () => request.get('/admin/banners')
export const createBanner = (data) => request.post('/admin/banners', data)
export const updateBanner = (id, data) => request.put(`/admin/banners/${id}`, data)
export const deleteBanner = (id) => request.delete(`/admin/banners/${id}`)

// 系统设置
export const getSettings = () => request.get('/admin/settings')
export const updateSettings = (data) => request.put(`/admin/settings`, data)

// 收藏管理
export const addFavorite = (workerId) => request.post('/favorites', { workerId })
export const removeFavorite = (workerId) => request.delete(`/favorites/${workerId}`)
export const getUserFavorites = () => request.get('/favorites')
export const checkFavorite = (workerId) => request.get(`/favorites/check/${workerId}`)
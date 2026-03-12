import axios from 'axios'

const request = axios.create({
  baseURL: '/api',
  timeout: 5000
})

request.interceptors.request.use(
  config => {
    // 优先使用adminToken，然后使用普通token
    const adminToken = localStorage.getItem('adminToken')
    const token = localStorage.getItem('token')
    const authToken = adminToken || token
    
    if (authToken) {
      config.headers['Authorization'] = `Bearer ${authToken}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

request.interceptors.response.use(
  response => {
    return response.data
  },
  error => {
    console.error('API Error:', error)
    // 处理401错误，跳转到登录页面
    if (error.response && error.response.status === 401) {
      const adminToken = localStorage.getItem('adminToken')
      if (adminToken) {
        localStorage.removeItem('adminToken')
        window.location.href = '/admin/login'
      } else {
        localStorage.removeItem('token')
        window.location.href = '/login'
      }
    }
    return Promise.reject(error)
  }
)

export default request
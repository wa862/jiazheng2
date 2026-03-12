<template>
  <div class="admin-login-page">
    <div class="admin-login-container">
      <div class="admin-login-header">
        <div class="logo">
          <el-icon :size="48" color="#409EFF"><Setting /></el-icon>
        </div>
        <h1>管理员登录</h1>
        <p>家政服务管理后台</p>
      </div>

      <el-form :model="loginForm" :rules="rules" ref="loginFormRef" class="admin-login-form" label-position="top">
        <el-form-item label="管理员账号" prop="username">
          <el-input 
            v-model="loginForm.username" 
            placeholder="请输入管理员账号"
            size="large"
            prefix-icon="User"
          />
        </el-form-item>

        <el-form-item label="密码" prop="password">
          <el-input 
            v-model="loginForm.password" 
            type="password" 
            placeholder="请输入密码"
            size="large"
            prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item>
          <el-checkbox v-model="rememberMe">记住密码</el-checkbox>
        </el-form-item>

        <el-form-item>
          <el-button 
            type="primary" 
            size="large" 
            class="login-btn"
            :loading="loading"
            @click="handleLogin"
          >
            登录
          </el-button>
        </el-form-item>
      </el-form>

      <div class="admin-login-footer">
        <router-link to="/" class="back-link">返回前台首页</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Setting, User, Lock } from '@element-plus/icons-vue'
import { adminLogin } from '../../api'

const router = useRouter()
const loginFormRef = ref(null)
const loading = ref(false)
const rememberMe = ref(false)

const loginForm = ref({
  username: '',
  password: ''
})

const rules = {
  username: [
    { required: true, message: '请输入管理员账号', trigger: 'blur' },
    { min: 3, max: 20, message: '账号长度在3到20个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  try {
    await loginFormRef.value.validate()
    loading.value = true
    
    const response = await adminLogin({
      username: loginForm.value.username,
      password: loginForm.value.password
    })
    
    if (response.success && response.token) {
      localStorage.setItem('adminToken', response.token)
      localStorage.setItem('adminUsername', response.data?.username || loginForm.value.username)
      
      ElMessage.success('登录成功')
      router.push('/admin/dashboard')
    } else {
      ElMessage.error(response.message || '登录失败')
    }
  } catch (error) {
    console.error('登录失败:', error)
    if (error !== false) {
      ElMessage.error(error.response?.data?.message || '登录失败，请检查账号和密码')
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.admin-login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
  padding: 20px;
}

.admin-login-container {
  background: white;
  border-radius: 16px;
  padding: 48px;
  width: 100%;
  max-width: 480px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
}

.admin-login-header {
  text-align: center;
  margin-bottom: 40px;
}

.logo {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.admin-login-header h1 {
  font-size: 32px;
  color: #333;
  margin-bottom: 8px;
}

.admin-login-header p {
  font-size: 16px;
  color: #666;
  margin: 0;
}

.admin-login-form {
  margin-bottom: 32px;
}

.admin-login-form :deep(.el-form-item__label) {
  font-weight: 600;
  color: #333;
  font-size: 16px;
}

.login-btn {
  width: 100%;
  height: 48px;
  font-size: 18px;
  margin-top: 16px;
}

.admin-login-footer {
  text-align: center;
  font-size: 16px;
}

.back-link {
  color: #409EFF;
  text-decoration: none;
  font-weight: 600;
}

.back-link:hover {
  text-decoration: underline;
}
</style>

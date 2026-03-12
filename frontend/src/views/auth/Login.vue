<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-header">
        <div class="logo">
          <el-icon :size="48" color="#409EFF"><House /></el-icon>
        </div>
        <h1>用户登录</h1>
        <p>欢迎回到家政服务平台</p>
      </div>

      <el-form :model="loginForm" :rules="rules" ref="loginFormRef" class="login-form" label-position="top">
        <el-form-item label="用户名" prop="username">
          <el-input 
            v-model="loginForm.username" 
            placeholder="请输入用户名"
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
            @keyup.enter="handleLogin"
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

      <div class="login-footer">
        <div class="footer-links">
          <router-link to="/forgot-password" class="forgot-link">忘记密码</router-link>
          <span class="divider">|</span>
          <router-link to="/register" class="register-link">去注册</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { House, User, Lock } from '@element-plus/icons-vue'
import { login } from '../../api'

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
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ]
}

// 页面加载时检查是否有记住的账号
onMounted(() => {
  const savedUsername = localStorage.getItem('rememberedUsername')
  if (savedUsername) {
    loginForm.value.username = savedUsername
    rememberMe.value = true
  }
})

const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  try {
    await loginFormRef.value.validate()
    loading.value = true
    
    const response = await login({
      username: loginForm.value.username,
      password: loginForm.value.password
    })
    
    // 处理记住密码
    if (rememberMe.value) {
      localStorage.setItem('rememberedUsername', loginForm.value.username)
    } else {
      localStorage.removeItem('rememberedUsername')
    }
    
    if (response.code === 200 && response.data) {
      // 保存登录信息
      localStorage.setItem('token', response.data.token)
      localStorage.setItem('userId', response.data.userId)
      localStorage.setItem('username', response.data.username)
      localStorage.setItem('userName', response.data.name)
      localStorage.setItem('userRole', response.data.role)
      
      // 保存用户信息对象
      const user = {
        username: response.data.username,
        name: response.data.name,
        avatar: response.data.avatar || '',
        role: response.data.role
      }
      localStorage.setItem('user', JSON.stringify(user))
      
      if (response.data.avatar) {
        localStorage.setItem('userAvatar', response.data.avatar)
      }
      
      ElMessage.success(response.message || '登录成功')
      router.push('/')
    } else {
      ElMessage.error(response.message || '登录失败')
    }
  } catch (error) {
    console.error('登录失败:', error)
    if (error.response?.data) {
      ElMessage.error(error.response.data.message || '登录失败')
    } else {
      ElMessage.error('网络错误，请稍后重试')
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-container {
  background: white;
  border-radius: 16px;
  padding: 48px;
  width: 100%;
  max-width: 480px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.login-header {
  text-align: center;
  margin-bottom: 32px;
}

.logo {
  margin-bottom: 16px;
}

.login-header h1 {
  font-size: 28px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 8px 0;
}

.login-header p {
  font-size: 16px;
  color: #909399;
  margin: 0;
}

.login-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #606266;
}

.login-btn {
  width: 100%;
  height: 48px;
  font-size: 16px;
  border-radius: 8px;
}

.login-footer {
  margin-top: 24px;
  text-align: center;
}

.footer-links {
  font-size: 14px;
}

.forgot-link,
.register-link {
  color: #409EFF;
  text-decoration: none;
  transition: color 0.3s;
}

.forgot-link:hover,
.register-link:hover {
  color: #66b1ff;
}

.divider {
  margin: 0 12px;
  color: #dcdfe6;
}

@media (max-width: 576px) {
  .login-container {
    padding: 32px 24px;
  }
  
  .login-header h1 {
    font-size: 24px;
  }
}
</style>

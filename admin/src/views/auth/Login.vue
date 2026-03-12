<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-left">
        <div class="brand">
          <el-icon :size="48" color="#409EFF"><Setting /></el-icon>
          <h1>家政服务管理系统</h1>
          <p>基于智能算法的家政服务平台</p>
        </div>
      </div>
      
      <div class="login-right">
        <div class="login-form-wrapper">
          <h2>管理员登录</h2>
          <p class="subtitle">请输入您的账号和密码</p>
          
          <el-form 
            :model="loginForm" 
            :rules="rules" 
            ref="formRef"
            class="login-form"
          >
            <el-form-item prop="username">
              <el-input 
                v-model="loginForm.username" 
                placeholder="请输入用户名"
                size="large"
                :prefix-icon="User"
                @keyup.enter="handleLogin"
              />
            </el-form-item>
            
            <el-form-item prop="password">
              <el-input 
                v-model="loginForm.password" 
                type="password" 
                placeholder="请输入密码"
                size="large"
                :prefix-icon="Lock"
                show-password
                @keyup.enter="handleLogin"
              />
            </el-form-item>
            
            <el-form-item>
              <div class="form-options">
                <el-checkbox v-model="rememberMe">记住我</el-checkbox>
                <el-button link type="primary">忘记密码？</el-button>
              </div>
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
            <p>© 2026 家政服务管理系统</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Setting, CircleCheck, User, Lock } from '@element-plus/icons-vue'
import { login } from '@api'

const router = useRouter()
const formRef = ref(null)
const loading = ref(false)
const rememberMe = ref(false)

const loginForm = ref({
  username: 'admin',
  password: ''
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()
    loading.value = true

    const res = await login({
      username: loginForm.value.username,
      password: loginForm.value.password
    })

    if (res && res.code === 200 && res.data) {
      // 真实后端返回的 token 和管理员信息
      localStorage.setItem('adminToken', res.data.token)
      localStorage.setItem('adminUsername', res.data.username || loginForm.value.username)
      if (res.data.role) {
        localStorage.setItem('adminRole', res.data.role.toUpperCase())
      }

      if (rememberMe.value) {
        localStorage.setItem('adminRemember', 'true')
      } else {
        localStorage.removeItem('adminRemember')
      }

      ElMessage.success(res.message || '登录成功')
      router.push('/admin/dashboard')
    } else {
      ElMessage.error(res?.message || '用户名或密码错误')
    }
  } catch (error) {
    console.error('登录失败:', error)
    const msg = error?.response?.data?.message || '登录失败，请检查用户名或密码'
    ElMessage.error(msg)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  const remembered = localStorage.getItem('adminRemember')
  if (remembered === 'true') {
    rememberMe.value = true
  }
})
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
  display: flex;
  width: 1000px;
  min-height: 600px;
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.login-left {
  flex: 1;
  background: linear-gradient(135deg, #304156 0%, #1f2d3d 100%);
  padding: 60px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  color: white;
}

.brand {
  text-align: center;
  margin-bottom: 60px;
}

.brand h1 {
  font-size: 28px;
  margin: 20px 0 12px;
}

.brand p {
  font-size: 16px;
  opacity: 0.8;
}

.features {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 16px;
}

.login-right {
  flex: 1;
  padding: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.login-form-wrapper {
  width: 100%;
  max-width: 360px;
}

.login-form-wrapper h2 {
  font-size: 28px;
  color: #303133;
  margin-bottom: 8px;
}

.subtitle {
  color: #909399;
  margin-bottom: 32px;
}

.login-form {
  margin-bottom: 24px;
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.login-btn {
  width: 100%;
  height: 48px;
  font-size: 16px;
}

.login-footer {
  text-align: center;
  color: #909399;
  font-size: 14px;
}

@media (max-width: 768px) {
  .login-container {
    flex-direction: column;
    width: 100%;
    max-width: 400px;
  }
  
  .login-left {
    padding: 40px;
    min-height: 200px;
  }
  
  .login-right {
    padding: 40px;
  }
}
</style>

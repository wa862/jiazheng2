<template>
  <div class="forgot-password-page">
    <div class="forgot-password-container">
      <div class="forgot-password-header">
        <div class="logo">
          <el-icon :size="48" color="#409EFF"><House /></el-icon>
        </div>
        <h1>忘记密码</h1>
        <p>重置您的密码</p>
      </div>

      <el-form :model="forgotForm" :rules="rules" ref="forgotFormRef" class="forgot-password-form" label-position="top">
        <el-form-item label="手机号" prop="phone">
          <el-input 
            v-model="forgotForm.phone" 
            placeholder="请输入手机号"
            size="large"
            prefix-icon="Phone"
          />
        </el-form-item>

        <el-form-item label="验证码" prop="code">
          <div class="code-input">
            <el-input 
              v-model="forgotForm.code" 
              placeholder="请输入验证码"
              size="large"
              prefix-icon="Message"
            />
            <el-button 
              type="primary" 
              size="large" 
              :disabled="countdown > 0"
              @click="sendCode"
            >
              {{ countdown > 0 ? `${countdown}秒后重试` : '获取验证码' }}
            </el-button>
          </div>
        </el-form-item>

        <el-form-item label="新密码" prop="newPassword">
          <el-input 
            v-model="forgotForm.newPassword" 
            type="password" 
            placeholder="请输入新密码"
            size="large"
            prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input 
            v-model="forgotForm.confirmPassword" 
            type="password" 
            placeholder="请再次输入新密码"
            size="large"
            prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item>
          <el-button 
            type="primary" 
            size="large" 
            class="submit-btn"
            :loading="loading"
            @click="handleSubmit"
          >
            提交
          </el-button>
        </el-form-item>
      </el-form>

      <div class="forgot-password-footer">
        <router-link to="/login" class="back-link">返回登录</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { House, Phone, Lock, Message } from '@element-plus/icons-vue'

const router = useRouter()
const forgotFormRef = ref(null)
const loading = ref(false)
const countdown = ref(0)
let timer = null

const forgotForm = ref({
  phone: '',
  code: '',
  newPassword: '',
  confirmPassword: ''
})

const validatePhone = (rule, value, callback) => {
  if (!value) {
    callback(new Error('请输入手机号'))
  } else if (!/^1[3-9]\d{9}$/.test(value)) {
    callback(new Error('请输入正确的手机号'))
  } else {
    callback()
  }
}

const validatePassword = (rule, value, callback) => {
  if (!value) {
    callback(new Error('请输入新密码'))
  } else if (value.length < 6) {
    callback(new Error('密码长度不能少于6位'))
  } else {
    callback()
  }
}

const validateConfirmPassword = (rule, value, callback) => {
  if (!value) {
    callback(new Error('请再次输入新密码'))
  } else if (value !== forgotForm.value.newPassword) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const rules = {
  phone: [
    { required: true, validator: validatePhone, trigger: 'blur' }
  ],
  code: [
    { required: true, message: '请输入验证码', trigger: 'blur' },
    { len: 6, message: '验证码长度为6位', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, validator: validatePassword, trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const sendCode = () => {
  if (!forgotForm.value.phone) {
    ElMessage.warning('请先输入手机号')
    return
  }
  
  if (!/^1[3-9]\d{9}$/.test(forgotForm.value.phone)) {
    ElMessage.warning('请输入正确的手机号')
    return
  }

  countdown.value = 60
  timer = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) {
      clearInterval(timer)
    }
  }, 1000)

  ElMessage.success('验证码已发送')
}

const handleSubmit = async () => {
  if (!forgotFormRef.value) return
  
  try {
    await forgotFormRef.value.validate()
    loading.value = true
    
    ElMessage.success('密码重置成功，请登录')
    router.push('/login')
  } catch (error) {
    console.error('密码重置失败:', error)
    if (error !== false) {
      ElMessage.error(error.response?.data?.message || '密码重置失败，请重试')
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.forgot-password-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.forgot-password-container {
  background: white;
  border-radius: 16px;
  padding: 48px;
  width: 100%;
  max-width: 480px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.forgot-password-header {
  text-align: center;
  margin-bottom: 40px;
}

.logo {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.forgot-password-header h1 {
  font-size: 32px;
  color: #333;
  margin-bottom: 8px;
}

.forgot-password-header p {
  font-size: 16px;
  color: #666;
  margin: 0;
}

.forgot-password-form {
  margin-bottom: 32px;
}

.forgot-password-form :deep(.el-form-item__label) {
  font-weight: 600;
  color: #333;
  font-size: 16px;
}

.code-input {
  display: flex;
  gap: 12px;
}

.code-input .el-input {
  flex: 1;
}

.submit-btn {
  width: 100%;
  height: 48px;
  font-size: 18px;
  margin-top: 16px;
}

.forgot-password-footer {
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

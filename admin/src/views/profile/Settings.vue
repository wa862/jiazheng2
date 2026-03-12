<template>
  <admin-layout>
    <div class="settings-page">
      <div class="page-header">
        <h1>账号设置</h1>
        <p>修改密码和安全设置</p>
      </div>
      <el-card>
        <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
          <el-form-item label="原密码" prop="oldPassword">
            <el-input v-model="form.oldPassword" type="password" show-password />
          </el-form-item>
          <el-form-item label="新密码" prop="newPassword">
            <el-input v-model="form.newPassword" type="password" show-password />
          </el-form-item>
          <el-form-item label="确认密码" prop="confirmPassword">
            <el-input v-model="form.confirmPassword" type="password" show-password />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSubmit" :loading="submitting">修改密码</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import AdminLayout from '@/components/AdminLayout.vue'
import { changePassword } from '@api'

const router = useRouter()
const formRef = ref(null)
const form = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})
const submitting = ref(false)

const validateConfirmPassword = (rule, value, callback) => {
  if (value !== form.newPassword) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const rules = {
  oldPassword: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度至少6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

const handleSubmit = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    const res = await changePassword({
      oldPassword: form.oldPassword,
      newPassword: form.newPassword
    })
    if (res && res.code === 200) {
      ElMessage.success(res.message || '密码修改成功，请重新登录')
      form.oldPassword = ''
      form.newPassword = ''
      form.confirmPassword = ''
      localStorage.removeItem('adminToken')
      localStorage.removeItem('adminUsername')
      localStorage.removeItem('adminRole')
      router.push('/admin/login')
    } else {
      ElMessage.error(res?.message || '修改失败')
    }
  } catch (error) {
    const msg = error?.response?.data?.message || error?.message || '修改密码失败'
    ElMessage.error(msg)
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped lang="scss">
.settings-page {
  padding: 20px;
}
.page-header {
  margin-bottom: 24px;
  h1 {
    font-size: 28px;
    font-weight: 600;
    color: #1f2937;
    margin: 0 0 8px 0;
  }
  p {
    font-size: 14px;
    color: #6b7280;
    margin: 0;
  }
}
</style>

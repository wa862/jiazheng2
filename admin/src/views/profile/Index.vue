<template>
  <admin-layout>
    <div class="profile-page">
      <div class="page-header">
        <h1>个人中心</h1>
        <p>管理您的个人信息</p>
      </div>
      <el-card>
        <el-form :model="profile" label-width="100px">
          <el-form-item label="用户名">
            <el-input v-model="profile.username" disabled />
          </el-form-item>
          <el-form-item label="昵称">
            <el-input v-model="profile.nickname" />
          </el-form-item>
          <el-form-item label="邮箱">
            <el-input v-model="profile.email" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSave">保存</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import AdminLayout from '@/components/AdminLayout.vue'

const profile = ref({
  username: 'admin',
  nickname: '管理员',
  email: 'admin@example.com'
})

const handleSave = () => {
  ElMessage.success('保存成功')
}
</script>

<style scoped lang="scss">
.profile-page {
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

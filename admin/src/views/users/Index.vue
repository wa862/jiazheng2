<template>
  <admin-layout>
    <div class="users-page">
      <div class="page-header">
        <h1>用户管理</h1>
        <p>管理系统中的所有用户</p>
      </div>

      <el-card class="table-card">
        <template #header>
          <div class="table-header">
            <div class="search-section">
              <el-input 
                v-model="searchKeyword" 
                placeholder="搜索用户名 / 姓名 / 手机号" 
                class="search-input"
                clearable
                @keyup.enter="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-select
                v-model="searchRole"
                placeholder="按角色筛选"
                clearable
                class="filter-select"
              >
                <el-option label="普通用户" value="user" />
                <el-option label="普通管理员" value="admin" />
                <el-option label="超级管理员" value="superadmin" />
              </el-select>
              <el-select
                v-model="searchStatus"
                placeholder="按状态筛选"
                clearable
                class="filter-select"
              >
                <el-option label="正常" value="active" />
                <el-option label="禁用" value="disabled" />
              </el-select>
              <el-button type="primary" @click="handleSearch">
                <el-icon><Search /></el-icon>
                搜索
              </el-button>
            </div>
          </div>
        </template>

        <el-table
          :data="users"
          style="width: 100%"
          v-loading="loading"
        >
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="username" label="用户名" width="150" />
          <el-table-column prop="name" label="姓名" width="140" />
          <el-table-column prop="phone" label="手机号" width="160" />
          <el-table-column prop="role" label="角色" width="140">
            <template #default="{ row }">
              <el-tag :type="getRoleTagType(row.role)" size="small">
                {{ getRoleText(row.role) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="120">
            <template #default="{ row }">
              <el-switch
                v-model="row.statusSwitch"
                :active-value="1"
                :inactive-value="0"
                @change="handleStatusChange(row)"
              />
              <span class="status-text">
                {{ row.statusSwitch === 1 ? '正常' : '禁用' }}
              </span>
            </template>
          </el-table-column>
          <el-table-column prop="createdAt" label="创建时间" width="180" />
          <el-table-column label="操作" fixed="right" width="240">
            <template #default="{ row }">
              <el-button type="primary" size="small" @click="handleView(row)">
                详情
              </el-button>
              <el-button type="primary" size="small" @click="handleEdit(row)">
                <el-icon><Edit /></el-icon>
                编辑
              </el-button>
              <el-button type="danger" size="small" @click="handleDelete(row)">
                <el-icon><Delete /></el-icon>
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <div class="pagination">
          <el-pagination
            v-model:current-page="pagination.page"
            v-model:page-size="pagination.pageSize"
            :total="total"
            :page-sizes="[10, 20, 50, 100]"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </el-card>
    </div>

    <!-- 编辑用户对话框 -->
    <el-dialog v-model="showDialog" :title="dialogTitle" width="600px" destroy-on-close>
      <el-form :model="userForm" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="userForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="姓名" prop="name">
          <el-input v-model="userForm.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select
            v-model="userForm.role"
            placeholder="请选择角色"
            style="width: 100%"
            :disabled="!isSuperAdmin"
          >
            <el-option label="普通用户" value="user" />
            <el-option label="普通管理员" value="admin" />
            <el-option label="超级管理员" value="superadmin" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="userForm.status">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>

    <!-- 用户详情对话框 -->
    <el-dialog v-model="showDetailDialog" title="用户详情" width="520px">
      <div v-if="currentUser">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="用户ID">{{ currentUser.id }}</el-descriptions-item>
          <el-descriptions-item label="用户名">{{ currentUser.username }}</el-descriptions-item>
          <el-descriptions-item label="姓名">{{ currentUser.name }}</el-descriptions-item>
          <el-descriptions-item label="手机号">{{ currentUser.phone }}</el-descriptions-item>
          <el-descriptions-item label="角色">
            <el-tag :type="getRoleTagType(currentUser.role)" size="small">
              {{ getRoleText(currentUser.role) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="currentUser.statusSwitch === 1 ? 'success' : 'danger'" size="small">
              {{ currentUser.statusSwitch === 1 ? '正常' : '禁用' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="创建时间" :span="2">
            {{ currentUser.createdAt || '—' }}
          </el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>
  </admin-layout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Delete, Edit } from '@element-plus/icons-vue'
import AdminLayout from '@components/AdminLayout.vue'
import { getUsers, updateUser, updateUserStatus, deleteUser } from '@api'

const loading = ref(false)
const submitLoading = ref(false)
const searchKeyword = ref('')
const searchRole = ref('')
const searchStatus = ref('')
const users = ref([])
const total = ref(0)
const showDialog = ref(false)
const showDetailDialog = ref(false)
const dialogTitle = ref('编辑用户')
const formRef = ref(null)
const currentUser = ref(null)

// 当前登录管理员角色，用于控制是否可编辑角色
const adminRole = ref(localStorage.getItem('adminRole') || 'ADMIN')
const isSuperAdmin = computed(() => adminRole.value === 'SUPERADMIN')

const pagination = ref({
  page: 1,
  pageSize: 10
})

const userForm = ref({
  id: null,
  username: '',
  name: '',
  phone: '',
  role: 'user',
  status: 1
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  name: [
    { required: true, message: '请输入姓名', trigger: 'blur' }
  ]
}

const loadUsers = async () => {
  loading.value = true
  try {
    const res = await getUsers({
      page: pagination.value.page - 1,
      pageSize: pagination.value.pageSize,
      keyword: searchKeyword.value,
      role: searchRole.value,
      status: searchStatus.value
    })

    if (res && res.code === 200 && res.data) {
      const list = res.data.content || res.data.list || []
      // 后端 status 为 "active"/"disabled" 等，转为 1/0 供开关显示
      users.value = list.map(u => ({
        ...u,
        statusSwitch: (u.status != null && String(u.status).toLowerCase() === 'active') ? 1 : 0
      }))
      total.value = res.data.totalElements ?? res.data.total ?? list.length
    } else {
      users.value = []
      total.value = 0
    }
  } catch (error) {
    console.error('加载用户列表失败:', error)
    ElMessage.error('加载用户列表失败')
    users.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const getRoleTagType = (role) => {
  const r = (role || '').toLowerCase()
  if (r === 'superadmin') return 'danger'
  if (r === 'admin') return 'warning'
  return 'info'
}

const getRoleText = (role) => {
  const r = (role || '').toLowerCase()
  if (r === 'superadmin') return '超级管理员'
  if (r === 'admin') return '普通管理员'
  return '普通用户'
}

const handleSearch = () => {
  pagination.value.page = 1
  loadUsers()
}

const handleEdit = (row) => {
  dialogTitle.value = '编辑用户'
  userForm.value = {
    id: row.id,
    username: row.username,
    phone: row.phone,
    name: row.name,
    role: row.role || 'user',
    status: row.statusSwitch === 1 ? 1 : 0
  }
  showDialog.value = true
}

const handleView = (row) => {
  currentUser.value = { ...row }
  showDetailDialog.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该用户吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await deleteUser(row.id)
    ElMessage.success('删除成功')
    loadUsers()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除用户失败:', error)
      ElMessage.error('删除失败')
    }
  }
}

const handleStatusChange = async (row) => {
  try {
    const status = row.statusSwitch === 1 ? 'active' : 'disabled'
    await updateUserStatus(row.id, { status })
    ElMessage.success('状态更新成功')
  } catch (error) {
    console.error('状态更新失败:', error)
    ElMessage.error('状态更新失败')
    row.statusSwitch = row.statusSwitch === 1 ? 0 : 1 // 还原开关
  }
}

const handleSubmit = async () => {
  try {
    await formRef.value.validate()
    submitLoading.value = true
    const payload = {
      ...userForm.value,
      status: userForm.value.status === 1 ? 'active' : 'disabled'
    }
    await updateUser(userForm.value.id, payload)
    ElMessage.success('更新成功')
    showDialog.value = false
    loadUsers()
  } catch (error) {
    console.error('提交失败:', error)
    ElMessage.error('提交失败')
  } finally {
    submitLoading.value = false
  }
}

const handleSizeChange = (size) => {
  pagination.value.pageSize = size
  pagination.value.page = 1
  loadUsers()
}

const handleCurrentChange = (page) => {
  pagination.value.page = page
  loadUsers()
}

onMounted(() => {
  loadUsers()
})
</script>

<style scoped>
.users-page {
  padding: 20px;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h1 {
  font-size: 28px;
  color: #303133;
  margin-bottom: 8px;
}

.page-header p {
  color: #909399;
}

.table-card {
  background: white;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}

.search-section {
  display: flex;
  gap: 12px;
}

.search-input {
  width: 300px;
}

.filter-select {
  width: 150px;
}

.action-section {
  display: flex;
  gap: 12px;
}

.status-text {
  margin-left: 8px;
  font-size: 12px;
  color: #606266;
}

.pagination {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}
</style>

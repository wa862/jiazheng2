<template>
  <admin-layout>
    <div class="workers-page">
      <div class="page-header">
        <h1>家政人员管理</h1>
        <p>管理系统中的家政服务人员</p>
      </div>

      <el-card class="table-card">
        <template #header>
          <div class="table-header">
            <div class="search-section">
              <el-input 
                v-model="searchKeyword" 
                placeholder="搜索家政人员..." 
                class="search-input"
                clearable
                @keyup.enter="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-select v-model="filterStatus" placeholder="状态筛选" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="待审核" value="pending" />
                <el-option label="已通过" value="approved" />
                <el-option label="已拒绝" value="rejected" />
              </el-select>
              <el-button type="primary" @click="handleSearch">
                <el-icon><Search /></el-icon>
                搜索
              </el-button>
            </div>
            <div class="action-section">
              <el-button type="primary" @click="handleAdd">
                <el-icon><Plus /></el-icon>
                添加人员
              </el-button>
              <el-button type="success" @click="handleExport">
                <el-icon><Download /></el-icon>
                导出
              </el-button>
            </div>
          </div>
        </template>

        <el-table
          :data="workers"
          style="width: 100%"
          v-loading="loading"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column label="头像" width="80">
            <template #default="{ row }">
              <el-avatar :size="40" :src="row.avatar">
                {{ (row.name || '工').charAt(0) }}
              </el-avatar>
            </template>
          </el-table-column>
          <el-table-column prop="name" label="姓名" width="120" />
          <el-table-column prop="phone" label="手机号" width="150" />
          <el-table-column prop="serviceType" label="服务类型" width="120" />
          <el-table-column prop="experience" label="从业年限" width="100">
            <template #default="{ row }">
              {{ row.experience }}年
            </template>
          </el-table-column>
          <el-table-column prop="price" label="服务价格" width="120">
            <template #default="{ row }">
              ¥{{ row.price }}/小时
            </template>
          </el-table-column>
          <el-table-column prop="rating" label="评分" width="100">
            <template #default="{ row }">
              <el-rate v-model="row.rating" disabled show-score text-color="#ff9900" />
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getStatusType(row.status)">{{ getStatusText(row.status) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="入驻时间" width="180" />
          <el-table-column label="操作" fixed="right" width="250">
            <template #default="{ row }">
              <el-button type="primary" size="small" @click="handleView(row)">
                <el-icon><View /></el-icon>
                查看
              </el-button>
              <el-button type="warning" size="small" @click="handleEdit(row)">
                <el-icon><Edit /></el-icon>
                编辑
              </el-button>
              <el-button type="danger" size="small" @click="handleDelete(row)">
                <el-icon><Delete /></el-icon>
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

    <!-- 添加/编辑对话框 -->
    <el-dialog v-model="showDialog" :title="dialogTitle" width="700px" destroy-on-close>
      <el-form :model="workerForm" :rules="rules" ref="formRef" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="姓名" prop="name">
              <el-input v-model="workerForm.name" placeholder="请输入姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="workerForm.phone" placeholder="请输入手机号" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="24">
            <el-form-item label="头像" prop="avatar">
              <div class="avatar-input-wrap">
                <el-input
                  v-model="workerForm.avatar"
                  placeholder="请输入头像图片URL，或点击右侧按钮本地上传"
                />
                <el-upload
                  class="avatar-upload"
                  :show-file-list="false"
                  :before-upload="beforeWorkerAvatarUpload"
                  :http-request="handleWorkerAvatarUpload"
                  accept="image/jpeg,image/png,image/webp,image/gif"
                >
                  <el-button type="primary" plain size="small">本地上传</el-button>
                </el-upload>
                <el-avatar
                  v-if="workerForm.avatar"
                  :size="40"
                  :src="workerForm.avatar"
                  class="avatar-preview"
                >
                  <el-icon><UserFilled /></el-icon>
                </el-avatar>
              </div>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="服务类型" prop="serviceType">
              <el-select v-model="workerForm.serviceType" placeholder="请选择服务类型" style="width: 100%">
                <el-option label="保洁服务" value="保洁服务" />
                <el-option label="月嫂服务" value="月嫂服务" />
                <el-option label="护理服务" value="护理服务" />
                <el-option label="钟点工" value="钟点工" />
                <el-option label="育儿嫂" value="育儿嫂" />
                <el-option label="老人陪护" value="老人陪护" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="从业年限" prop="experience">
              <el-input-number v-model="workerForm.experience" :min="0" :max="50" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="服务价格" prop="price">
              <el-input-number v-model="workerForm.price" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-select v-model="workerForm.status" placeholder="请选择状态" style="width: 100%">
                <el-option label="待审核" value="pending" />
                <el-option label="已通过" value="approved" />
                <el-option label="已拒绝" value="rejected" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="个人简介" prop="introduction">
          <el-input 
            v-model="workerForm.introduction" 
            type="textarea" 
            :rows="4"
            placeholder="请输入个人简介"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>

    <!-- 查看详情对话框 -->
    <el-dialog v-model="showDetailDialog" title="家政人员详情" width="600px">
      <div v-if="selectedWorker" class="worker-detail">
        <div class="detail-header">
          <el-avatar :size="80" :src="selectedWorker.avatar">
            <el-icon :size="40"><UserFilled /></el-icon>
          </el-avatar>
          <div class="detail-info">
            <h3>{{ selectedWorker.name }}</h3>
            <p>{{ selectedWorker.serviceType }}</p>
            <el-rate v-model="selectedWorker.rating" disabled show-score />
          </div>
        </div>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="手机号">{{ selectedWorker.phone }}</el-descriptions-item>
          <el-descriptions-item label="从业年限">{{ selectedWorker.experience }}年</el-descriptions-item>
          <el-descriptions-item label="服务价格">¥{{ selectedWorker.price }}/小时</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="getStatusType(selectedWorker.status)">
              {{ getStatusText(selectedWorker.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="入驻时间" :span="2">{{ selectedWorker.createTime }}</el-descriptions-item>
          <el-descriptions-item label="个人简介" :span="2">{{ selectedWorker.introduction || '暂无简介' }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>
  </admin-layout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Plus, Download, Edit, Delete, View, UserFilled } from '@element-plus/icons-vue'
import AdminLayout from '@components/AdminLayout.vue'
import { getWorkers, createWorker, updateWorker, deleteWorker, uploadImage } from '@api'

const loading = ref(false)
const submitLoading = ref(false)
const searchKeyword = ref('')
const filterStatus = ref('')
const workers = ref([])
const selectedWorkers = ref([])
const total = ref(0)
const showDialog = ref(false)
const showDetailDialog = ref(false)
const dialogTitle = ref('添加家政人员')
const formRef = ref(null)
const selectedWorker = ref(null)

const pagination = ref({
  page: 1,
  pageSize: 10
})

const workerForm = ref({
  name: '',
  phone: '',
  avatar: '',
  serviceType: '',
  experience: 0,
  price: 0,
  status: 'pending',
  introduction: ''
})

const rules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  serviceType: [{ required: true, message: '请选择服务类型', trigger: 'change' }],
  experience: [{ required: true, message: '请输入从业年限', trigger: 'blur' }],
  price: [{ required: true, message: '请输入服务价格', trigger: 'blur' }]
}

const beforeWorkerAvatarUpload = (file) => {
  const isImage = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'].includes(file.type)
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('上传头像只能是 JPG/PNG/WebP/GIF 格式!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('上传头像大小不能超过 2MB!')
    return false
  }
  return true
}

const handleWorkerAvatarUpload = async (options) => {
  try {
    const res = await uploadImage(options.file)
    if (res && res.code === 200 && res.data) {
      const path = res.data
      const url = path.startsWith('http') || path.startsWith('/') ? path : '/' + path
      workerForm.value.avatar = url
      ElMessage.success('头像上传成功')
      options.onSuccess(res)
    } else {
      const err = new Error(res?.message || '上传失败')
      options.onError(err)
      ElMessage.error(err.message)
    }
  } catch (error) {
    options.onError(error)
    ElMessage.error(error?.message || '上传失败')
  }
}

const getStatusType = (status) => {
  const types = {
    pending: 'warning',
    approved: 'success',
    rejected: 'danger',
    active: 'success',
    available: 'success',
    inactive: 'info'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    pending: '待审核',
    approved: '已通过',
    rejected: '已拒绝',
    active: '已通过',
    available: '已通过',
    inactive: '已下线'
  }
  return texts[status] || (status ? String(status) : '—')
}

const loadWorkers = async () => {
  loading.value = true
  try {
    const res = await getWorkers({
      page: pagination.value.page - 1,
      pageSize: pagination.value.pageSize,
      keyword: searchKeyword.value,
      status: filterStatus.value
    })

    if (res && res.code === 200 && res.data) {
      workers.value = res.data.content || res.data.list || []
      total.value = res.data.totalElements ?? res.data.total ?? workers.value.length
    } else {
      workers.value = []
      total.value = 0
    }
  } catch (error) {
    console.error('加载家政人员列表失败:', error)
    ElMessage.error('加载失败')
    workers.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.value.page = 1
  loadWorkers()
}

const handleAdd = () => {
  dialogTitle.value = '添加家政人员'
  workerForm.value = {
    name: '',
    phone: '',
    avatar: '',
    serviceType: '',
    experience: 0,
    price: 0,
    status: 'pending',
    introduction: ''
  }
  showDialog.value = true
}

const handleEdit = (row) => {
  dialogTitle.value = '编辑家政人员'
  workerForm.value = { ...row }
  showDialog.value = true
}

const handleView = (row) => {
  selectedWorker.value = row
  showDetailDialog.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该家政人员吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const res = await deleteWorker(row.id)
    if (res && res.code !== 200) {
      ElMessage.error(res.message || '删除失败')
      return
    }
    ElMessage.success('删除成功')
    loadWorkers()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
      ElMessage.error(error.response?.data?.message || '删除失败')
    }
  }
}

const handleExport = async () => {
  try {
    const token = localStorage.getItem('adminToken') || ''
    const response = await fetch('/api/admin/workers/export', {
      method: 'GET',
      headers: { Authorization: `Bearer ${token}` }
    })
    if (!response.ok) {
      throw new Error('导出失败')
    }
    const contentDisposition = response.headers.get('content-disposition')
    let filename = '家政人员_' + new Date().toISOString().slice(0, 19).replace(/[-:T]/g, '').replace('T', '_') + '.xlsx'
    if (contentDisposition) {
      const match = contentDisposition.match(/filename\*?=(?:UTF-8'')?["']?([^"';]+)["']?/i)
      if (match) {
        try {
          filename = decodeURIComponent(match[1].trim())
          if (!filename.toLowerCase().endsWith('.xlsx')) filename += '.xlsx'
        } catch (_) {}
      }
    }
    const blob = await response.blob()
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = filename
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
  } catch (error) {
    console.error('导出失败:', error)
    ElMessage.error('导出失败')
  }
}

const handleSelectionChange = (selection) => {
  selectedWorkers.value = selection
}

const handleSubmit = async () => {
  try {
    await formRef.value.validate()
    submitLoading.value = true
    
    if (dialogTitle.value === '添加家政人员') {
      await createWorker(workerForm.value)
      ElMessage.success('添加成功')
    } else {
      await updateWorker(workerForm.value.id, workerForm.value)
      ElMessage.success('更新成功')
    }
    
    showDialog.value = false
    loadWorkers()
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
  loadWorkers()
}

const handleCurrentChange = (page) => {
  pagination.value.page = page
  loadWorkers()
}

onMounted(() => {
  loadWorkers()
})
</script>

<style scoped>
.workers-page {
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
  width: 250px;
}

.action-section {
  display: flex;
  gap: 12px;
}

.pagination {
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

.avatar-input-wrap {
  display: flex;
  align-items: center;
  gap: 12px;
}

.avatar-preview {
  border: 1px solid #ebeef5;
}

.worker-detail {
  padding: 20px;
}

.detail-header {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 24px;
  padding-bottom: 20px;
  border-bottom: 1px solid #ebeef5;
}

.detail-info h3 {
  font-size: 20px;
  margin-bottom: 8px;
}

.detail-info p {
  color: #909399;
  margin-bottom: 8px;
}
</style>

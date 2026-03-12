<template>
  <admin-layout>
    <div class="notices-page">
      <div class="page-header">
        <h1>公告管理</h1>
        <p>管理系统公告和通知信息</p>
      </div>

      <!-- 统计卡片 -->
      <el-row :gutter="20" class="stats-row">
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #409EFF 0%, #64B5F6 100%);">
                <el-icon :size="28" color="white"><Document /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">总公告数</p>
                <p class="stat-value">{{ stats.total }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #67C23A 0%, #85CE61 100%);">
                <el-icon :size="28" color="white"><CircleCheck /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">已发布</p>
                <p class="stat-value">{{ stats.published }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #E6A23C 0%, #EBB563 100%);">
                <el-icon :size="28" color="white"><Timer /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">待发布</p>
                <p class="stat-value">{{ stats.pending }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #909399 0%, #A6A9AD 100%);">
                <el-icon :size="28" color="white"><Hide /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">已下架</p>
                <p class="stat-value">{{ stats.unpublished }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 公告列表 -->
      <el-card class="table-card" style="margin-top: 20px;">
        <template #header>
          <div class="table-header">
            <div class="filter-section">
              <el-input 
                v-model="searchKeyword" 
                placeholder="搜索公告标题..." 
                class="search-input"
                clearable
                @keyup.enter="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-select v-model="filterType" placeholder="公告类型" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="系统公告" value="system" />
                <el-option label="活动通知" value="activity" />
                <el-option label="维护通知" value="maintenance" />
                <el-option label="其他" value="other" />
              </el-select>
              <el-select v-model="filterStatus" placeholder="状态" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="已发布" value="published" />
                <el-option label="待发布" value="pending" />
                <el-option label="已下架" value="unpublished" />
              </el-select>
              <el-button type="primary" @click="handleSearch">
                <el-icon><Search /></el-icon>
                搜索
              </el-button>
            </div>
            <div class="action-section">
              <el-button type="primary" @click="handleAdd">
                <el-icon><Plus /></el-icon>
                发布公告
              </el-button>
            </div>
          </div>
        </template>

        <el-table
          :data="notices"
          style="width: 100%"
          v-loading="loading"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="title" label="公告标题" min-width="200">
            <template #default="{ row }">
              <div class="notice-title">
                <el-tag :type="getTypeTag(row.type)" size="small" class="type-tag">
                  {{ getTypeText(row.type) }}
                </el-tag>
                <span class="title-text" :class="{ 'is-top': row.isTop }">
                  {{ row.title }}
                  <el-tag v-if="row.isTop" type="danger" size="small" effect="plain" class="top-tag">置顶</el-tag>
                </span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="author" label="发布人" width="120" />
          <el-table-column prop="publishTime" label="发布时间" width="180" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getStatusType(row.status)" size="small">
                {{ getStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="viewCount" label="浏览量" width="100">
            <template #default="{ row }">
              <span class="view-count">
                <el-icon><View /></el-icon>
                {{ row.viewCount }}
              </span>
            </template>
          </el-table-column>
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
              <el-button 
                :type="row.status === 'published' ? 'info' : 'success'" 
                size="small" 
                @click="handleToggleStatus(row)"
              >
                {{ row.status === 'published' ? '下架' : '发布' }}
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

      <!-- 添加/编辑公告对话框 -->
      <el-dialog
        v-model="dialogVisible"
        :title="dialogType === 'add' ? '发布公告' : '编辑公告'"
        width="700px"
        destroy-on-close
      >
        <el-form :model="noticeForm" :rules="noticeRules" ref="noticeFormRef" label-width="100px">
          <el-form-item label="公告标题" prop="title">
            <el-input v-model="noticeForm.title" placeholder="请输入公告标题" maxlength="100" show-word-limit />
          </el-form-item>
          
          <el-form-item label="公告类型" prop="type">
            <el-select v-model="noticeForm.type" placeholder="请选择公告类型" style="width: 100%">
              <el-option label="系统公告" value="system" />
              <el-option label="活动通知" value="activity" />
              <el-option label="维护通知" value="maintenance" />
              <el-option label="其他" value="other" />
            </el-select>
          </el-form-item>
          
          <el-form-item label="是否置顶">
            <el-switch v-model="noticeForm.isTop" />
          </el-form-item>
          
          <el-form-item label="发布时间" prop="publishTime">
            <el-date-picker
              v-model="noticeForm.publishTime"
              type="datetime"
              placeholder="选择发布时间"
              style="width: 100%"
            />
          </el-form-item>
          
          <el-form-item label="公告内容" prop="content">
            <el-input
              v-model="noticeForm.content"
              type="textarea"
              :rows="8"
              placeholder="请输入公告内容"
              maxlength="2000"
              show-word-limit
            />
          </el-form-item>
        </el-form>
        
        <template #footer>
          <div class="dialog-footer">
            <el-button @click="dialogVisible = false">取消</el-button>
            <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
          </div>
        </template>
      </el-dialog>

      <!-- 查看公告对话框 -->
      <el-dialog
        v-model="viewDialogVisible"
        title="公告详情"
        width="600px"
        destroy-on-close
      >
        <div class="notice-detail" v-if="currentNotice">
          <div class="notice-header">
            <h2 class="notice-title">{{ currentNotice.title }}</h2>
            <div class="notice-meta">
              <el-tag :type="getTypeTag(currentNotice.type)" size="small">
                {{ getTypeText(currentNotice.type) }}
              </el-tag>
              <span class="meta-item">
                <el-icon><User /></el-icon>
                {{ currentNotice.author }}
              </span>
              <span class="meta-item">
                <el-icon><Clock /></el-icon>
                {{ currentNotice.publishTime }}
              </span>
              <span class="meta-item">
                <el-icon><View /></el-icon>
                {{ currentNotice.viewCount }} 次浏览
              </span>
            </div>
          </div>
          <div class="notice-content">
            {{ currentNotice.content }}
          </div>
        </div>
      </el-dialog>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import AdminLayout from '@/components/AdminLayout.vue'
import {
  Document,
  CircleCheck,
  Timer,
  Hide,
  Search,
  Plus,
  View,
  Edit,
  Delete,
  User,
  Clock
} from '@element-plus/icons-vue'

// 统计数据
const stats = reactive({
  total: 156,
  published: 89,
  pending: 23,
  unpublished: 44
})

// 搜索和筛选
const searchKeyword = ref('')
const filterType = ref('')
const filterStatus = ref('')

// 表格相关
const loading = ref(false)
const pagination = reactive({
  page: 1,
  pageSize: 10
})
const total = ref(156)
const selectedNotices = ref([])

// 公告数据
const notices = ref([
  {
    id: 1,
    title: '平台系统维护通知',
    type: 'maintenance',
    author: '系统管理员',
    publishTime: '2026-01-15 10:00:00',
    status: 'published',
    viewCount: 1256,
    isTop: true,
    content: '尊敬的用户，为了提供更好的服务体验，平台将于2026年1月20日凌晨2:00-6:00进行系统维护，期间部分功能可能无法使用，请提前做好安排。'
  },
  {
    id: 2,
    title: '春节服务预约开启公告',
    type: 'activity',
    author: '运营专员',
    publishTime: '2026-01-14 09:30:00',
    status: 'published',
    viewCount: 2341,
    isTop: true,
    content: '春节将至，为满足广大用户的家庭清洁需求，平台现已开启春节服务预约通道。提前预约可享受8折优惠，名额有限，先到先得！'
  },
  {
    id: 3,
    title: '新用户注册福利升级',
    type: 'activity',
    author: '运营专员',
    publishTime: '2026-01-13 14:00:00',
    status: 'published',
    viewCount: 1890,
    isTop: false,
    content: '为感谢新老用户的支持，平台升级新用户注册福利。新用户注册即送100元优惠券包，首单立减50元！'
  },
  {
    id: 4,
    title: '家政人员资质认证通知',
    type: 'system',
    author: '系统管理员',
    publishTime: '2026-01-12 16:00:00',
    status: 'pending',
    viewCount: 0,
    isTop: false,
    content: '根据最新政策要求，所有入驻平台的家政人员需在2026年3月1日前完成资质认证。未按时完成认证的人员将无法继续接单。'
  },
  {
    id: 5,
    title: '平台服务协议更新',
    type: 'system',
    author: '法务部门',
    publishTime: '2026-01-10 11:00:00',
    status: 'unpublished',
    viewCount: 567,
    isTop: false,
    content: '平台服务协议已更新，主要涉及用户隐私保护条款和服务质量标准。请所有用户及时查阅并确认。'
  }
])

// 对话框相关
const dialogVisible = ref(false)
const dialogType = ref('add')
const submitLoading = ref(false)
const noticeFormRef = ref(null)

// 公告表单
const noticeForm = reactive({
  title: '',
  type: 'system',
  isTop: false,
  publishTime: '',
  content: ''
})

// 表单验证规则
const noticeRules = {
  title: [
    { required: true, message: '请输入公告标题', trigger: 'blur' },
    { min: 2, max: 100, message: '标题长度在2-100个字符之间', trigger: 'blur' }
  ],
  type: [
    { required: true, message: '请选择公告类型', trigger: 'change' }
  ],
  content: [
    { required: true, message: '请输入公告内容', trigger: 'blur' },
    { min: 10, max: 2000, message: '内容长度在10-2000个字符之间', trigger: 'blur' }
  ]
}

// 查看对话框
const viewDialogVisible = ref(false)
const currentNotice = ref(null)

// 获取类型标签样式
const getTypeTag = (type) => {
  const types = {
    system: 'primary',
    activity: 'success',
    maintenance: 'warning',
    other: 'info'
  }
  return types[type] || 'info'
}

// 获取类型文本
const getTypeText = (type) => {
  const texts = {
    system: '系统公告',
    activity: '活动通知',
    maintenance: '维护通知',
    other: '其他'
  }
  return texts[type] || type
}

// 获取状态标签样式
const getStatusType = (status) => {
  const types = {
    published: 'success',
    pending: 'warning',
    unpublished: 'info'
  }
  return types[status] || 'info'
}

// 获取状态文本
const getStatusText = (status) => {
  const texts = {
    published: '已发布',
    pending: '待发布',
    unpublished: '已下架'
  }
  return texts[status] || status
}

// 搜索
const handleSearch = () => {
  loading.value = true
  setTimeout(() => {
    loading.value = false
    ElMessage.success('搜索完成')
  }, 500)
}

// 选择变化
const handleSelectionChange = (selection) => {
  selectedNotices.value = selection
}

// 添加公告
const handleAdd = () => {
  dialogType.value = 'add'
  Object.assign(noticeForm, {
    title: '',
    type: 'system',
    isTop: false,
    publishTime: new Date(),
    content: ''
  })
  dialogVisible.value = true
}

// 编辑公告
const handleEdit = (row) => {
  dialogType.value = 'edit'
  Object.assign(noticeForm, {
    id: row.id,
    title: row.title,
    type: row.type,
    isTop: row.isTop,
    publishTime: row.publishTime,
    content: row.content
  })
  dialogVisible.value = true
}

// 查看公告
const handleView = (row) => {
  currentNotice.value = row
  viewDialogVisible.value = true
  // 增加浏览量
  row.viewCount++
}

// 切换状态
const handleToggleStatus = (row) => {
  const newStatus = row.status === 'published' ? 'unpublished' : 'published'
  const actionText = row.status === 'published' ? '下架' : '发布'
  
  ElMessageBox.confirm(
    `确定要${actionText}该公告吗？`,
    '提示',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    row.status = newStatus
    // 更新统计数据
    if (newStatus === 'published') {
      stats.published++
      stats.unpublished--
    } else {
      stats.published--
      stats.unpublished++
    }
    ElMessage.success(`${actionText}成功`)
  }).catch(() => {})
}

// 删除公告
const handleDelete = (row) => {
  ElMessageBox.confirm(
    '确定要删除该公告吗？删除后无法恢复！',
    '警告',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    const index = notices.value.findIndex(item => item.id === row.id)
    if (index > -1) {
      notices.value.splice(index, 1)
      total.value--
      stats.total--
      if (row.status === 'published') stats.published--
      else if (row.status === 'pending') stats.pending--
      else stats.unpublished--
    }
    ElMessage.success('删除成功')
  }).catch(() => {})
}

// 提交表单
const handleSubmit = async () => {
  const valid = await noticeFormRef.value.validate().catch(() => false)
  if (!valid) return

  submitLoading.value = true
  setTimeout(() => {
    submitLoading.value = false
    dialogVisible.value = false
    
    if (dialogType.value === 'add') {
      const newNotice = {
        id: notices.value.length + 1,
        ...noticeForm,
        author: '当前管理员',
        status: 'published',
        viewCount: 0
      }
      notices.value.unshift(newNotice)
      total.value++
      stats.total++
      stats.published++
      ElMessage.success('发布成功')
    } else {
      const index = notices.value.findIndex(item => item.id === noticeForm.id)
      if (index > -1) {
        Object.assign(notices.value[index], noticeForm)
      }
      ElMessage.success('更新成功')
    }
  }, 1000)
}

// 分页
const handleSizeChange = (val) => {
  pagination.pageSize = val
  handleSearch()
}

const handleCurrentChange = (val) => {
  pagination.page = val
  handleSearch()
}
</script>

<style scoped lang="scss">
.notices-page {
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

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  .stat-content {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .stat-icon {
    width: 56px;
    height: 56px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .stat-info {
    .stat-label {
      font-size: 14px;
      color: #6b7280;
      margin: 0 0 4px 0;
    }

    .stat-value {
      font-size: 24px;
      font-weight: 700;
      color: #1f2937;
      margin: 0;
    }
  }
}

.table-card {
  .table-header {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .filter-section {
      display: flex;
      gap: 12px;
      align-items: center;

      .search-input {
        width: 220px;
      }
    }

    .action-section {
      display: flex;
      gap: 12px;
    }
  }

  .notice-title {
    display: flex;
    align-items: center;
    gap: 8px;

    .type-tag {
      flex-shrink: 0;
    }

    .title-text {
      font-weight: 500;

      &.is-top {
        color: #f56c6c;
      }
    }

    .top-tag {
      margin-left: 8px;
    }
  }

  .view-count {
    display: flex;
    align-items: center;
    gap: 4px;
    color: #909399;
  }

  .pagination {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
  }
}

.notice-detail {
  .notice-header {
    margin-bottom: 24px;
    padding-bottom: 16px;
    border-bottom: 1px solid #e5e7eb;

    .notice-title {
      font-size: 20px;
      font-weight: 600;
      color: #1f2937;
      margin: 0 0 16px 0;
    }

    .notice-meta {
      display: flex;
      align-items: center;
      gap: 16px;
      flex-wrap: wrap;

      .meta-item {
        display: flex;
        align-items: center;
        gap: 4px;
        color: #6b7280;
        font-size: 13px;
      }
    }
  }

  .notice-content {
    font-size: 14px;
    line-height: 1.8;
    color: #374151;
    white-space: pre-wrap;
  }
}

:deep(.el-card__header) {
  border-bottom: 1px solid #e5e7eb;
  padding: 16px 20px;
}

:deep(.el-card__body) {
  padding: 20px;
}
</style>

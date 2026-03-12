<template>
  <admin-layout>
    <div class="feedback-page">
      <div class="page-header">
        <h1>用户反馈</h1>
        <p>查看和处理用户反馈信息</p>
      </div>

      <!-- 统计卡片 -->
      <el-row :gutter="20" class="stats-row">
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #409EFF 0%, #64B5F6 100%);">
                <el-icon :size="28" color="white"><Message /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">总反馈数</p>
                <p class="stat-value">{{ stats.total }}</p>
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
                <p class="stat-label">待处理</p>
                <p class="stat-value">{{ stats.pending }}</p>
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
                <p class="stat-label">已处理</p>
                <p class="stat-value">{{ stats.resolved }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #F56C6C 0%, #F78989 100%);">
                <el-icon :size="28" color="white"><Star /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">满意度</p>
                <p class="stat-value">{{ stats.satisfaction }}%</p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 反馈列表 -->
      <el-card class="table-card" style="margin-top: 20px;">
        <template #header>
          <div class="table-header">
            <div class="filter-section">
              <el-input 
                v-model="searchKeyword" 
                placeholder="搜索用户/内容..." 
                class="search-input"
                clearable
                @keyup.enter="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-select v-model="filterType" placeholder="反馈类型" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="功能建议" value="suggestion" />
                <el-option label="问题反馈" value="bug" />
                <el-option label="投诉" value="complaint" />
                <el-option label="其他" value="other" />
              </el-select>
              <el-select v-model="filterStatus" placeholder="处理状态" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="待处理" value="pending" />
                <el-option label="处理中" value="processing" />
                <el-option label="已解决" value="resolved" />
                <el-option label="已关闭" value="closed" />
              </el-select>
              <el-button type="primary" @click="handleSearch">
                <el-icon><Search /></el-icon>
                搜索
              </el-button>
            </div>
            <div class="action-section">
              <el-button type="success" @click="handleExport">
                <el-icon><Download /></el-icon>
                导出
              </el-button>
            </div>
          </div>
        </template>

        <el-table
          :data="feedbacks"
          style="width: 100%"
          v-loading="loading"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="userName" label="用户" width="120">
            <template #default="{ row }">
              <div class="user-info">
                <el-avatar :size="32" :src="row.userAvatar">
                  <el-icon><UserFilled /></el-icon>
                </el-avatar>
                <span>{{ row.userName }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="type" label="类型" width="100">
            <template #default="{ row }">
              <el-tag :type="getTypeType(row.type)" size="small">
                {{ getTypeText(row.type) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="title" label="标题" min-width="180">
            <template #default="{ row }">
              <span class="feedback-title" :class="{ 'is-urgent': row.isUrgent }">
                {{ row.title }}
                <el-tag v-if="row.isUrgent" type="danger" size="small" effect="plain">紧急</el-tag>
              </span>
            </template>
          </el-table-column>
          <el-table-column prop="content" label="反馈内容" min-width="250">
            <template #default="{ row }">
              <el-tooltip :content="row.content" placement="top">
                <span class="content-text">{{ row.content }}</span>
              </el-tooltip>
            </template>
          </el-table-column>
          <el-table-column prop="contact" label="联系方式" width="140" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getStatusType(row.status)" size="small">
                {{ getStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="提交时间" width="180" />
          <el-table-column label="操作" fixed="right" width="200">
            <template #default="{ row }">
              <el-button type="primary" size="small" @click="handleView(row)">
                <el-icon><View /></el-icon>
                查看
              </el-button>
              <el-button type="warning" size="small" @click="handleReply(row)" v-if="row.status !== 'resolved'">
                <el-icon><ChatDotRound /></el-icon>
                回复
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

      <!-- 查看详情对话框 -->
      <el-dialog v-model="viewDialogVisible" title="反馈详情" width="560px">
        <div v-if="currentFeedback" class="feedback-detail">
          <p><strong>用户：</strong>{{ currentFeedback.userName }}</p>
          <p><strong>类型：</strong>{{ getTypeText(currentFeedback.type) }}</p>
          <p><strong>标题：</strong>{{ currentFeedback.title }}</p>
          <p><strong>内容：</strong>{{ currentFeedback.content }}</p>
          <p><strong>联系方式：</strong>{{ currentFeedback.contact || '—' }}</p>
          <p><strong>状态：</strong>{{ getStatusText(currentFeedback.status) }}</p>
          <p><strong>提交时间：</strong>{{ currentFeedback.createTime || '—' }}</p>
          <template v-if="currentFeedback.replyContent">
            <el-divider />
            <p><strong>回复内容：</strong>{{ currentFeedback.replyContent }}</p>
            <p v-if="currentFeedback.repliedAt"><strong>回复时间：</strong>{{ currentFeedback.repliedAt }}</p>
          </template>
        </div>
        <template #footer>
          <el-button @click="viewDialogVisible = false">关闭</el-button>
          <el-button type="primary" @click="viewDialogVisible = false; handleReply(currentFeedback)">回复</el-button>
        </template>
      </el-dialog>

      <!-- 回复对话框 -->
      <el-dialog
        v-model="replyDialogVisible"
        title="回复反馈"
        width="600px"
        destroy-on-close
      >
        <div class="reply-content" v-if="currentFeedback">
          <div class="original-feedback">
            <h4>原始反馈</h4>
            <p><strong>用户：</strong>{{ currentFeedback.userName }}</p>
            <p><strong>标题：</strong>{{ currentFeedback.title }}</p>
            <p><strong>内容：</strong>{{ currentFeedback.content }}</p>
          </div>
          <el-divider />
          <el-form :model="replyForm" label-width="80px">
            <el-form-item label="回复内容">
              <el-input
                v-model="replyForm.content"
                type="textarea"
                :rows="4"
                placeholder="请输入回复内容"
              />
            </el-form-item>
            <el-form-item label="处理状态">
              <el-radio-group v-model="replyForm.status">
                <el-radio label="processing">处理中</el-radio>
                <el-radio label="resolved">已解决</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-form>
        </div>
        <template #footer>
          <div class="dialog-footer">
            <el-button @click="replyDialogVisible = false">取消</el-button>
            <el-button type="primary" @click="handleSubmitReply" :loading="replyLoading">提交回复</el-button>
          </div>
        </template>
      </el-dialog>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import AdminLayout from '@/components/AdminLayout.vue'
import {
  Message,
  Timer,
  CircleCheck,
  Star,
  Search,
  Download,
  View,
  ChatDotRound,
  Delete,
  UserFilled
} from '@element-plus/icons-vue'
import { getFeedbacks, getFeedbackStats, replyFeedback, updateFeedbackStatus, deleteFeedback } from '@api'

// 统计数据
const stats = reactive({
  total: 0,
  pending: 0,
  resolved: 0,
  satisfaction: 0
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
const total = ref(0)
const selectedFeedbacks = ref([])

// 反馈数据
const feedbacks = ref([])

// 加载统计数据
const loadStats = async () => {
  try {
    const res = await getFeedbackStats()
    if (res && res.code === 200 && res.data) {
      stats.total = res.data.total || 0
      stats.pending = res.data.pending || 0
      stats.resolved = res.data.resolved || 0
      stats.satisfaction = res.data.satisfaction || 0
    } else {
      stats.total = 0
      stats.pending = 0
      stats.resolved = 0
      stats.satisfaction = 0
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

// 加载反馈列表
const loadFeedbacks = async () => {
  loading.value = true
  try {
    const res = await getFeedbacks({
      page: pagination.page - 1,
      pageSize: pagination.pageSize,
      keyword: searchKeyword.value,
      type: filterType.value,
      status: filterStatus.value
    })
    
    if (res && res.code === 200 && res.data) {
      feedbacks.value = (res.data.content || []).map(item => ({
        id: item.id,
        userName: item.userName,
        userAvatar: item.userAvatar,
        type: item.type,
        title: item.title,
        content: item.content,
        contact: item.contact,
        status: item.status,
        createTime: item.createdAt,
        isUrgent: item.isUrgent === 1,
        replyContent: item.replyContent,
        repliedBy: item.repliedBy,
        repliedAt: item.repliedAt
      }))
      total.value = res.data.totalElements || 0
    } else {
      feedbacks.value = []
      total.value = 0
    }
  } catch (error) {
    console.error('加载反馈列表失败:', error)
    ElMessage.error('加载反馈列表失败')
  } finally {
    loading.value = false
  }
}

// 回复对话框
const replyDialogVisible = ref(false)
const replyLoading = ref(false)
const currentFeedback = ref(null)
const replyForm = reactive({
  content: '',
  status: 'processing'
})

// 获取类型标签样式
const getTypeType = (type) => {
  const types = {
    suggestion: 'success',
    bug: 'danger',
    complaint: 'warning',
    other: 'info'
  }
  return types[type] || 'info'
}

// 获取类型文本
const getTypeText = (type) => {
  const texts = {
    suggestion: '功能建议',
    bug: '问题反馈',
    complaint: '投诉',
    other: '其他'
  }
  return texts[type] || type
}

// 获取状态标签样式
const getStatusType = (status) => {
  const types = {
    pending: 'danger',
    processing: 'warning',
    resolved: 'success',
    closed: 'info'
  }
  return types[status] || 'info'
}

// 获取状态文本
const getStatusText = (status) => {
  const texts = {
    pending: '待处理',
    processing: '处理中',
    resolved: '已解决',
    closed: '已关闭'
  }
  return texts[status] || status
}

// 搜索
const handleSearch = () => {
  pagination.page = 1
  loadFeedbacks()
}

// 选择变化
const handleSelectionChange = (selection) => {
  selectedFeedbacks.value = selection
}

const viewDialogVisible = ref(false)
// 查看反馈
const handleView = (row) => {
  currentFeedback.value = row
  viewDialogVisible.value = true
}

// 回复反馈
const handleReply = (row) => {
  currentFeedback.value = row
  replyForm.content = ''
  replyForm.status = row.status === 'pending' ? 'processing' : 'resolved'
  replyDialogVisible.value = true
}

// 提交回复
const handleSubmitReply = async () => {
  if (!replyForm.content.trim()) {
    ElMessage.warning('请输入回复内容')
    return
  }
  
  replyLoading.value = true
  try {
    await replyFeedback(currentFeedback.value.id, {
      content: replyForm.content,
      repliedBy: '管理员'
    })
    
    replyLoading.value = false
    replyDialogVisible.value = false
    
    // 更新本地状态
    if (currentFeedback.value) {
      currentFeedback.value.status = replyForm.status
      currentFeedback.value.replyContent = replyForm.content
    }
    
    // 重新加载统计数据
    loadStats()
    
    loadFeedbacks()
    ElMessage.success('回复成功')
  } catch (error) {
    replyLoading.value = false
    console.error('回复失败:', error)
    ElMessage.error('回复失败')
  }
}

// 删除反馈
const handleDelete = (row) => {
  ElMessageBox.confirm(
    '确定要删除该反馈吗？',
    '提示',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      await deleteFeedback(row.id)
      
      const index = feedbacks.value.findIndex(item => item.id === row.id)
      if (index > -1) {
        feedbacks.value.splice(index, 1)
        total.value--
      }
      
      // 重新加载统计数据
      loadStats()
      
      ElMessage.success('删除成功')
    } catch (error) {
      console.error('删除失败:', error)
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

// 导出
const handleExport = () => {
  ElMessage.success('导出成功')
}

// 分页
const handleSizeChange = (val) => {
  pagination.pageSize = val
  pagination.page = 1
  loadFeedbacks()
}

const handleCurrentChange = (val) => {
  pagination.page = val
  loadFeedbacks()
}

// 页面加载时获取数据
onMounted(() => {
  loadStats()
  loadFeedbacks()
})
</script>

<style scoped lang="scss">
.feedback-page {
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
        width: 200px;
      }
    }

    .action-section {
      display: flex;
      gap: 12px;
    }
  }

  .user-info {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .feedback-title {
    display: flex;
    align-items: center;
    gap: 8px;

    &.is-urgent {
      color: #f56c6c;
      font-weight: 600;
    }
  }

  .content-text {
    display: inline-block;
    max-width: 300px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .pagination {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
  }
}

.reply-content {
  .original-feedback {
    background: #f5f7fa;
    padding: 16px;
    border-radius: 8px;
    margin-bottom: 16px;

    h4 {
      margin: 0 0 12px 0;
      font-size: 14px;
      color: #1f2937;
    }

    p {
      margin: 8px 0;
      font-size: 13px;
      color: #606266;
    }
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

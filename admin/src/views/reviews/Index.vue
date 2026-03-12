<template>
  <admin-layout>
    <div class="reviews-page">
      <div class="page-header">
        <h1>评价管理</h1>
        <p>管理用户对家政人员的评价</p>
      </div>

      <el-card class="table-card">
        <template #header>
          <div class="table-header">
            <div class="filter-section">
              <el-input 
                v-model="searchKeyword" 
                placeholder="搜索评价内容..." 
                class="search-input"
                clearable
                @keyup.enter="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-select v-model="filterRating" placeholder="评分筛选" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="5星" :value="5" />
                <el-option label="4星" :value="4" />
                <el-option label="3星" :value="3" />
                <el-option label="2星" :value="2" />
                <el-option label="1星" :value="1" />
              </el-select>
              <el-select v-model="filterStatus" placeholder="状态筛选" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="显示中" value="visible" />
                <el-option label="已隐藏" value="hidden" />
              </el-select>
              <el-button type="primary" @click="handleSearch">
                <el-icon><Search /></el-icon>
                搜索
              </el-button>
            </div>
            <div class="action-section">
              <el-button type="danger" @click="handleBatchDelete" :disabled="selectedReviews.length === 0">
                <el-icon><Delete /></el-icon>
                批量删除
              </el-button>
            </div>
          </div>
        </template>

        <el-table
          :data="reviews"
          style="width: 100%"
          v-loading="loading"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="userName" label="用户" width="120" />
          <el-table-column prop="workerName" label="家政人员" width="120" />
          <el-table-column prop="orderNo" label="订单号" width="180" />
          <el-table-column prop="rating" label="评分" width="150">
            <template #default="{ row }">
              <el-rate v-model="row.rating" disabled show-score />
            </template>
          </el-table-column>
          <el-table-column prop="content" label="评价内容" min-width="200">
            <template #default="{ row }">
              <el-tooltip :content="row.content" placement="top">
                <span class="content-ellipsis">{{ row.content }}</span>
              </el-tooltip>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="row.status === 'visible' ? 'success' : 'info'">
                {{ row.status === 'visible' ? '显示中' : '已隐藏' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="评价时间" width="180" />
          <el-table-column label="操作" fixed="right" width="200">
            <template #default="{ row }">
              <el-button type="primary" size="small" @click="handleView(row)">
                <el-icon><View /></el-icon>
                查看
              </el-button>
              <el-button 
                :type="row.status === 'visible' ? 'warning' : 'success'" 
                size="small" 
                @click="handleToggleStatus(row)"
              >
                {{ row.status === 'visible' ? '隐藏' : '显示' }}
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

      <!-- 评价统计 -->
      <el-row :gutter="20" class="stats-row">
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                <el-icon :size="32" color="white"><ChatDotRound /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">总评价数</p>
                <p class="stat-value">{{ stats.total }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                <el-icon :size="32" color="white"><StarFilled /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">平均评分</p>
                <p class="stat-value">{{ stats.avgRating }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                <el-icon :size="32" color="white"><CircleCheck /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">好评率</p>
                <p class="stat-value">{{ stats.goodRate }}%</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);">
                <el-icon :size="32" color="white"><Hide /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">已隐藏</p>
                <p class="stat-value">{{ stats.hidden }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 评价详情对话框 -->
    <el-dialog v-model="showDetailDialog" title="评价详情" width="600px">
      <div v-if="selectedReview" class="review-detail">
        <div class="detail-header">
          <div class="user-info">
            <el-avatar :size="50" :src="selectedReview.userAvatar">
              <el-icon><User /></el-icon>
            </el-avatar>
            <div>
              <h4>{{ selectedReview.userName }}</h4>
              <p>{{ selectedReview.createTime }}</p>
            </div>
          </div>
          <el-rate v-model="selectedReview.rating" disabled show-score />
        </div>

        <el-divider />

        <div class="detail-content">
          <h4>评价内容</h4>
          <p class="review-content">{{ selectedReview.content }}</p>
        </div>

        <div class="detail-order">
          <h4>关联订单</h4>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="订单号">{{ selectedReview.orderNo }}</el-descriptions-item>
            <el-descriptions-item label="家政人员">{{ selectedReview.workerName }}</el-descriptions-item>
            <el-descriptions-item label="服务类型">{{ selectedReview.serviceType }}</el-descriptions-item>
            <el-descriptions-item label="订单金额">¥{{ selectedReview.orderAmount }}</el-descriptions-item>
          </el-descriptions>
        </div>

        <div class="detail-actions">
          <el-button 
            :type="selectedReview.status === 'visible' ? 'warning' : 'success'"
            @click="handleToggleStatus(selectedReview)"
          >
            {{ selectedReview.status === 'visible' ? '隐藏评价' : '显示评价' }}
          </el-button>
          <el-button type="danger" @click="handleDelete(selectedReview)">删除评价</el-button>
        </div>
      </div>
    </el-dialog>
  </admin-layout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Delete, View, ChatDotRound, StarFilled, CircleCheck, Hide, User } from '@element-plus/icons-vue'
import AdminLayout from '@components/AdminLayout.vue'
import { getReviews, updateReviewStatus, deleteReview } from '@api'

const loading = ref(false)
const searchKeyword = ref('')
const filterRating = ref('')
const filterStatus = ref('')
const reviews = ref([])
const selectedReviews = ref([])
const total = ref(0)
const showDetailDialog = ref(false)
const selectedReview = ref(null)

const stats = ref({
  total: 1256,
  avgRating: 4.6,
  goodRate: 92.5,
  hidden: 23
})

const pagination = ref({
  page: 1,
  pageSize: 10
})

const loadReviews = async () => {
  loading.value = true
  try {
    const res = await getReviews({
      page: pagination.value.page - 1,
      size: pagination.value.pageSize,
      keyword: searchKeyword.value,
      rating: filterRating.value,
      status: filterStatus.value
    })

    if (res && res.code === 200 && res.data) {
      reviews.value = res.data.content || []
      total.value = res.data.totalElements || 0
    } else {
      reviews.value = []
      total.value = 0
    }
  } catch (error) {
    console.error('加载评价列表失败:', error)
    ElMessage.error('加载失败')
    reviews.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.value.page = 1
  loadReviews()
}

const handleView = (row) => {
  selectedReview.value = row
  showDetailDialog.value = true
}

const handleToggleStatus = async (row) => {
  try {
    const newStatus = row.status === 'visible' ? 'hidden' : 'visible'
    await updateReviewStatus(row.id, newStatus)
    row.status = newStatus
    ElMessage.success(row.status === 'visible' ? '评价已显示' : '评价已隐藏')
  } catch (error) {
    console.error('操作失败:', error)
    ElMessage.error('操作失败')
  }
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该评价吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await deleteReview(row.id)
    ElMessage.success('删除成功')
    loadReviews()
    showDetailDialog.value = false
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
      ElMessage.error('删除失败')
    }
  }
}

const handleBatchDelete = async () => {
  if (selectedReviews.value.length === 0) {
    ElMessage.warning('请选择要删除的评价')
    return
  }
  
  try {
    await ElMessageBox.confirm(`确定要删除选中的 ${selectedReviews.value.length} 条评价吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    for (const review of selectedReviews.value) {
      await deleteReview(review.id)
    }
    
    ElMessage.success('批量删除成功')
    loadReviews()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('批量删除失败:', error)
      ElMessage.error('批量删除失败')
    }
  }
}

const handleSelectionChange = (selection) => {
  selectedReviews.value = selection
}

const handleSizeChange = (size) => {
  pagination.value.pageSize = size
  pagination.value.page = 1
  loadReviews()
}

const handleCurrentChange = (page) => {
  pagination.value.page = page
  loadReviews()
}

onMounted(() => {
  loadReviews()
})
</script>

<style scoped>
.reviews-page {
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
  margin-bottom: 20px;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}

.filter-section {
  display: flex;
  gap: 12px;
}

.search-input {
  width: 220px;
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

.content-ellipsis {
  display: block;
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.stats-row {
  margin-top: 20px;
}

.stat-card :deep(.el-card__body) {
  padding: 20px;
}

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
}

.stat-info {
  flex: 1;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #303133;
}

.review-detail {
  padding: 20px;
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-info h4 {
  margin: 0 0 4px 0;
}

.user-info p {
  margin: 0;
  color: #909399;
  font-size: 13px;
}

.detail-content {
  margin: 20px 0;
}

.detail-content h4 {
  margin-bottom: 12px;
}

.review-content {
  background: #f5f7fa;
  padding: 16px;
  border-radius: 8px;
  line-height: 1.6;
}

.detail-order {
  margin: 20px 0;
}

.detail-order h4 {
  margin-bottom: 12px;
}

.detail-actions {
  margin-top: 24px;
  display: flex;
  justify-content: center;
  gap: 16px;
}
</style>

<template>
  <admin-layout>
    <div class="applications-page">
      <div class="page-header">
        <h1>入驻申请</h1>
        <p>审核和管理家政人员入驻申请</p>
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
                <p class="stat-label">总申请数</p>
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
                <p class="stat-label">待审核</p>
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
                <p class="stat-label">已通过</p>
                <p class="stat-value">{{ stats.approved }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #F56C6C 0%, #F78989 100%);">
                <el-icon :size="28" color="white"><CircleClose /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">已拒绝</p>
                <p class="stat-value">{{ stats.rejected }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 申请列表 -->
      <el-card class="table-card" style="margin-top: 20px;">
        <template #header>
          <div class="table-header">
            <div class="filter-section">
              <el-input 
                v-model="searchKeyword" 
                placeholder="搜索姓名/手机号..." 
                class="search-input"
                clearable
                @keyup.enter="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-select v-model="filterStatus" placeholder="审核状态" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="待审核" value="pending" />
                <el-option label="已通过" value="approved" />
                <el-option label="已拒绝" value="rejected" />
              </el-select>
              <el-select v-model="filterServiceType" placeholder="服务类型" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="保洁" value="cleaning" />
                <el-option label="月嫂" value="maternity" />
                <el-option label="护工" value="nursing" />
                <el-option label="育儿嫂" value="childcare" />
              </el-select>
              <el-button type="primary" @click="handleSearch">
                <el-icon><Search /></el-icon>
                搜索
              </el-button>
            </div>
            <div class="action-section"></div>
          </div>
        </template>

        <el-table
          :data="applications"
          style="width: 100%"
          v-loading="loading"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column label="申请人" min-width="150">
            <template #default="{ row }">
              <div class="applicant-info">
                <el-avatar :size="40" :src="row.avatar">
                  <el-icon><UserFilled /></el-icon>
                </el-avatar>
                <div class="applicant-detail">
                  <p class="name">{{ row.name }}</p>
                  <p class="phone">{{ row.phone }}</p>
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="serviceType" label="服务类型" width="120">
            <template #default="{ row }">
              <el-tag size="small">{{ row.serviceType }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="experience" label="从业经验" width="100">
            <template #default="{ row }">
              {{ row.experience }}年
            </template>
          </el-table-column>
          <el-table-column prop="idCard" label="身份证号" width="180">
            <template #default="{ row }">
              {{ maskIdCard(row.idCard) }}
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getStatusType(row.status)" size="small">
                {{ getStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="applyTime" label="申请时间" width="180" />
          <el-table-column label="操作" fixed="right" width="250">
            <template #default="{ row }">
              <el-button type="primary" size="small" @click="handleView(row)">
                <el-icon><View /></el-icon>
                查看
              </el-button>
              <template v-if="row.status === 'pending'">
                <el-button type="success" size="small" @click="handleApprove(row)">
                  <el-icon><CircleCheck /></el-icon>
                  通过
                </el-button>
                <el-button type="danger" size="small" @click="handleReject(row)">
                  <el-icon><CircleClose /></el-icon>
                  拒绝
                </el-button>
              </template>
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

      <!-- 申请详情对话框 -->
      <el-dialog
        v-model="detailDialogVisible"
        title="申请详情"
        width="700px"
        destroy-on-close
      >
        <div class="application-detail" v-if="currentApplication">
          <el-descriptions :column="2" border>
            <el-descriptions-item label="姓名">{{ currentApplication.name }}</el-descriptions-item>
            <el-descriptions-item label="性别">{{ currentApplication.gender }}</el-descriptions-item>
            <el-descriptions-item label="手机号">{{ currentApplication.phone }}</el-descriptions-item>
            <el-descriptions-item label="身份证号">{{ currentApplication.idCard }}</el-descriptions-item>
            <el-descriptions-item label="服务类型">{{ currentApplication.serviceType }}</el-descriptions-item>
            <el-descriptions-item label="从业经验">{{ currentApplication.experience }}年</el-descriptions-item>
            <el-descriptions-item label="期望薪资">¥{{ currentApplication.expectedSalary }}/小时</el-descriptions-item>
            <el-descriptions-item label="工作状态">{{ currentApplication.workStatus }}</el-descriptions-item>
            <el-descriptions-item label="服务区域" :span="2">{{ currentApplication.serviceArea }}</el-descriptions-item>
            <el-descriptions-item label="个人简介" :span="2">{{ currentApplication.introduction }}</el-descriptions-item>
          </el-descriptions>

          <div class="cert-section">
            <h4>资质证书</h4>
            <div class="cert-list">
              <div v-for="(cert, index) in currentApplication.certificates" :key="index" class="cert-item">
                <el-image 
                  :src="cert.url" 
                  :preview-src-list="currentApplication.certificates.map(c => c.url)"
                  fit="cover"
                  class="cert-image"
                />
                <p class="cert-name">{{ cert.name }}</p>
              </div>
            </div>
          </div>
        </div>
        <template #footer>
          <div class="dialog-footer">
            <el-button @click="detailDialogVisible = false">关闭</el-button>
            <template v-if="currentApplication && currentApplication.status === 'pending'">
              <el-button type="danger" @click="handleReject(currentApplication)">拒绝</el-button>
              <el-button type="success" @click="handleApprove(currentApplication)">通过</el-button>
            </template>
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
  Document,
  Timer,
  CircleCheck,
  CircleClose,
  Search,
  View,
  UserFilled
} from '@element-plus/icons-vue'
import {
  getApplications,
  getApplicationStats,
  approveApplication,
  rejectApplication,
  deleteApplication
} from '@/api/index.js'

// 统计数据
const stats = reactive({
  total: 0,
  pending: 0,
  approved: 0,
  rejected: 0
})

// 搜索和筛选
const searchKeyword = ref('')
const filterStatus = ref('')
const filterServiceType = ref('')

// 表格相关
const loading = ref(false)
const pagination = reactive({
  page: 1,
  pageSize: 10
})
const total = ref(156)
const selectedApplications = ref([])

// 申请数据
const applications = ref([])

// 详情对话框
const detailDialogVisible = ref(false)
const currentApplication = ref(null)

// 获取状态标签样式
const getStatusType = (status) => {
  const types = {
    pending: 'warning',
    approved: 'success',
    rejected: 'danger'
  }
  return types[status] || 'info'
}

// 获取状态文本
const getStatusText = (status) => {
  const texts = {
    pending: '待审核',
    approved: '已通过',
    rejected: '已拒绝'
  }
  return texts[status] || status
}

// 身份证号脱敏
const maskIdCard = (idCard) => {
  if (!idCard || idCard.length !== 18) return idCard
  return idCard.slice(0, 6) + '********' + idCard.slice(14)
}

// 加载统计数据
const loadStats = async () => {
  try {
    const res = await getApplicationStats()
    if (res && res.code === 200 && res.data) {
      stats.total = res.data.total || 0
      stats.pending = res.data.pending || 0
      stats.approved = res.data.approved || 0
      stats.rejected = res.data.rejected || 0
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

// 加载申请列表
const loadApplications = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.page - 1,
      size: pagination.pageSize,
      keyword: searchKeyword.value,
      status: filterStatus.value
    }
    const res = await getApplications(params)
    if (res && res.code === 200 && res.data) {
      applications.value = res.data.content || []
      total.value = res.data.totalElements || 0
    }
  } catch (error) {
    console.error('加载申请列表失败:', error)
    ElMessage.error('加载申请列表失败')
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.page = 1
  loadApplications()
}

// 选择变化
const handleSelectionChange = (selection) => {
  selectedApplications.value = selection
}

// 查看详情
const handleView = (row) => {
  currentApplication.value = row
  detailDialogVisible.value = true
}

// 通过申请
const handleApprove = async (row) => {
  ElMessageBox.confirm(
    `确定要通过 ${row.name} 的入驻申请吗？通过后该申请将被删除，家政人员将自动加入工作人员列表。`,
    '确认通过',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'success'
    }
  ).then(async () => {
    try {
      await approveApplication(row.id, { reviewer: '管理员' })
      ElMessage.success('已通过申请，家政人员已加入工作人员列表')
      // 重新加载数据
      loadApplications()
      loadStats()
      detailDialogVisible.value = false
    } catch (error) {
      console.error('通过申请失败:', error)
      ElMessage.error('通过申请失败')
    }
  }).catch(() => {})
}

// 拒绝申请
const handleReject = async (row) => {
  ElMessageBox.prompt(
    `确定要拒绝 ${row.name} 的入驻申请吗？请输入拒绝原因：`,
    '确认拒绝',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
      inputPlaceholder: '请输入拒绝原因'
    }
  ).then(async ({ value }) => {
    try {
      await rejectApplication(row.id, { reviewer: '管理员', reason: value })
      ElMessage.success('已拒绝申请')
      // 重新加载数据
      loadApplications()
      loadStats()
      detailDialogVisible.value = false
    } catch (error) {
      console.error('拒绝申请失败:', error)
      ElMessage.error('拒绝申请失败')
    }
  }).catch(() => {})
}

// 批量通过
const handleBatchApprove = async () => {
  const count = selectedApplications.value.length
  ElMessageBox.confirm(
    `确定要通过选中的 ${count} 个申请吗？通过后这些申请将被删除，家政人员将自动加入工作人员列表。`,
    '批量通过',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'success'
    }
  ).then(async () => {
    try {
      let successCount = 0
      for (const row of selectedApplications.value) {
        if (row.status === 'pending') {
          await approveApplication(row.id, { reviewer: '管理员' })
          successCount++
        }
      }
      ElMessage.success(`已成功通过 ${successCount} 个申请，家政人员已加入工作人员列表`)
      // 重新加载数据
      loadApplications()
      loadStats()
      selectedApplications.value = []
    } catch (error) {
      console.error('批量通过申请失败:', error)
      ElMessage.error('批量通过申请失败')
    }
  }).catch(() => {})
}

// 分页
const handleSizeChange = (val) => {
  pagination.pageSize = val
  loadApplications()
}

const handleCurrentChange = (val) => {
  pagination.page = val
  loadApplications()
}

// 页面加载时获取数据
onMounted(() => {
  loadStats()
  loadApplications()
})
</script>

<style scoped lang="scss">
.applications-page {
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

  .applicant-info {
    display: flex;
    align-items: center;
    gap: 12px;

    .applicant-detail {
      .name {
        font-weight: 500;
        color: #1f2937;
        margin: 0 0 4px 0;
      }

      .phone {
        font-size: 12px;
        color: #6b7280;
        margin: 0;
      }
    }
  }

  .pagination {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
  }
}

.application-detail {
  .cert-section {
    margin-top: 20px;

    h4 {
      font-size: 14px;
      font-weight: 600;
      color: #1f2937;
      margin: 0 0 16px 0;
    }

    .cert-list {
      display: flex;
      gap: 16px;
      flex-wrap: wrap;

      .cert-item {
        text-align: center;

        .cert-image {
          width: 150px;
          height: 100px;
          border-radius: 8px;
          cursor: pointer;
        }

        .cert-name {
          margin: 8px 0 0 0;
          font-size: 12px;
          color: #6b7280;
        }
      }
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

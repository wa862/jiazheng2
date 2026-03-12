<template>
  <admin-layout>
    <div class="orders-page">
      <div class="page-header">
        <h1>订单管理</h1>
        <p>管理所有用户订单</p>
      </div>

      <el-card class="table-card">
        <template #header>
          <div class="table-header">
            <div class="filter-section">
              <el-input 
                v-model="searchKeyword" 
                placeholder="搜索订单号/用户..." 
                class="search-input"
                clearable
                @keyup.enter="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-select v-model="filterStatus" placeholder="订单状态" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="待接单" value="pending" />
                <el-option label="已接单" value="accepted" />
                <el-option label="服务中" value="in_progress" />
                <el-option label="已完成" value="completed" />
                <el-option label="已取消" value="cancelled" />
              </el-select>
              <el-date-picker
                v-model="dateRange"
                type="daterange"
                range-separator="至"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                value-format="YYYY-MM-DD"
                style="width: 240px"
              />
              <el-button type="primary" @click="handleSearch">
                <el-icon><Search /></el-icon>
                搜索
              </el-button>
            </div>
            <div class="action-section">
              <el-button type="success" @click="handleExport">
                <el-icon><Download /></el-icon>
                导出订单
              </el-button>
            </div>
          </div>
        </template>

        <el-table
          :data="orders"
          style="width: 100%"
          v-loading="loading"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column prop="orderNo" label="订单号" width="180" />
          <el-table-column prop="userName" label="用户" width="120" />
          <el-table-column prop="workerName" label="家政人员" width="120" />
          <el-table-column prop="serviceType" label="服务类型" width="120" />
          <el-table-column prop="totalAmount" label="订单金额" width="120">
            <template #default="{ row }">
              <span class="amount">¥{{ row.totalAmount }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="orderStatus" label="订单状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getStatusType(row.orderStatus)">{{ getStatusText(row.orderStatus) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createdAt" label="下单时间" width="180">
            <template #default="{ row }">
              {{ formatDateTime(row.createdAt) }}
            </template>
          </el-table-column>
          <el-table-column prop="serviceDate" label="服务日期" width="120">
            <template #default="{ row }">
              {{ row.serviceDate }}
            </template>
          </el-table-column>
          <el-table-column label="操作" fixed="right" width="200">
            <template #default="{ row }">
              <el-button type="primary" size="small" @click="handleView(row)">
                <el-icon><View /></el-icon>
                详情
              </el-button>
              <el-button type="warning" size="small" @click="handleUpdateStatus(row)">
                <el-icon><Refresh /></el-icon>
                更新
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

    <!-- 订单详情对话框 -->
    <el-dialog v-model="showDetailDialog" title="订单详情" width="700px">
      <div v-if="selectedOrder" class="order-detail">
        <el-steps :active="getStepActive(selectedOrder.orderStatus)" finish-status="success">
          <el-step title="待接单" />
          <el-step title="已接单" />
          <el-step title="服务中" />
          <el-step title="已完成" />
        </el-steps>

        <el-descriptions :column="2" border class="detail-info">
          <el-descriptions-item label="订单号">{{ selectedOrder.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="订单状态">
            <el-tag :type="getStatusType(selectedOrder.orderStatus)">
              {{ getStatusText(selectedOrder.orderStatus) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="用户">{{ selectedOrder.userName }}</el-descriptions-item>
          <el-descriptions-item label="家政人员">{{ selectedOrder.workerName }}</el-descriptions-item>
          <el-descriptions-item label="服务类型">{{ selectedOrder.serviceType }}</el-descriptions-item>
          <el-descriptions-item label="订单金额">
            <span class="amount-large">¥{{ selectedOrder.totalAmount }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="服务地址" :span="2">{{ selectedOrder.userAddress }}</el-descriptions-item>
          <el-descriptions-item label="下单时间">{{ formatDateTime(selectedOrder.createdAt) }}</el-descriptions-item>
          <el-descriptions-item label="服务时间">
            {{ selectedOrder.serviceDate }} {{ selectedOrder.startTime }}-{{ selectedOrder.endTime }}
          </el-descriptions-item>
          <el-descriptions-item label="支付状态">
            <el-tag :type="getPaymentStatusType(selectedOrder.paymentStatus)">
              {{ getPaymentStatusText(selectedOrder.paymentStatus) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="支付方式">{{ selectedOrder.paymentMethod || '-' }}</el-descriptions-item>
          <el-descriptions-item label="服务时长">{{ selectedOrder.duration }}小时</el-descriptions-item>
          <el-descriptions-item label="服务单价">¥{{ selectedOrder.servicePrice }}/小时</el-descriptions-item>
          <el-descriptions-item label="用户电话">{{ selectedOrder.userPhone }}</el-descriptions-item>
          <el-descriptions-item label="家政人员电话">{{ selectedOrder.workerPhone }}</el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ selectedOrder.notes || '无' }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>

    <!-- 更新状态对话框 -->
    <el-dialog v-model="showStatusDialog" title="更新订单状态" width="400px">
      <el-form :model="statusForm" label-width="100px">
        <el-form-item label="当前状态">
          <el-tag :type="getStatusType(statusForm.currentStatus)">
            {{ getStatusText(statusForm.currentStatus) }}
          </el-tag>
        </el-form-item>
        <el-form-item label="新状态">
          <el-select v-model="statusForm.newStatus" placeholder="请选择新状态" style="width: 100%">
            <el-option label="待接单" value="pending" />
            <el-option label="已接单" value="accepted" />
            <el-option label="服务中" value="in_progress" />
            <el-option label="已完成" value="completed" />
            <el-option label="已取消" value="cancelled" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="statusForm.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showStatusDialog = false">取消</el-button>
        <el-button type="primary" @click="submitStatusUpdate">确定</el-button>
      </template>
    </el-dialog>
  </admin-layout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Download, View, Refresh } from '@element-plus/icons-vue'
import AdminLayout from '@components/AdminLayout.vue'
import { getOrders, updateOrderStatus } from '@api'

const loading = ref(false)
const searchKeyword = ref('')
const filterStatus = ref('')
const dateRange = ref(null)
const orders = ref([])
const selectedOrders = ref([])
const total = ref(0)
const showDetailDialog = ref(false)
const showStatusDialog = ref(false)
const selectedOrder = ref(null)

const statusForm = ref({
  orderId: null,
  currentStatus: '',
  newStatus: '',
  remark: ''
})

const pagination = ref({
  page: 1,
  pageSize: 10
})

const getStatusType = (status) => {
  const types = {
    pending: 'warning',
    accepted: 'primary',
    in_progress: 'info',
    completed: 'success',
    cancelled: 'danger'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    pending: '待接单',
    accepted: '已接单',
    in_progress: '服务中',
    completed: '已完成',
    cancelled: '已取消'
  }
  return texts[status] || status
}

const getStepActive = (status) => {
  const steps = { pending: 0, accepted: 1, in_progress: 2, completed: 3, cancelled: 0 }
  return steps[status] || 0
}

const getPaymentStatusType = (status) => {
  const types = {
    unpaid: 'warning',
    paid: 'success',
    refunded: 'info'
  }
  return types[status] || 'info'
}

const getPaymentStatusText = (status) => {
  const texts = {
    unpaid: '未支付',
    paid: '已支付',
    refunded: '已退款'
  }
  return texts[status] || status
}

const formatDateTime = (dateTime) => {
  if (!dateTime) return '-'
  const date = new Date(dateTime)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  }).replace(/\//g, '-')
}

const loadOrders = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.value.page - 1,
      pageSize: pagination.value.pageSize,
      keyword: searchKeyword.value,
      status: filterStatus.value
    }
    if (dateRange.value && dateRange.value.length === 2) {
      params.startDate = dateRange.value[0]
      params.endDate = dateRange.value[1]
    }
    const res = await getOrders(params)

    if (res && res.code === 200 && res.data) {
      orders.value = res.data.content || res.data.list || []
      total.value = res.data.totalElements ?? res.data.total ?? 0
    } else {
      orders.value = []
      total.value = 0
    }
  } catch (error) {
    console.error('加载订单列表失败:', error)
    ElMessage.error('加载失败')
    orders.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.value.page = 1
  loadOrders()
}

const handleView = (row) => {
  selectedOrder.value = row
  showDetailDialog.value = true
}

const handleUpdateStatus = (row) => {
  statusForm.value = {
    orderId: row.id,
    currentStatus: row.orderStatus,
    newStatus: '',
    remark: ''
  }
  showStatusDialog.value = true
}

const submitStatusUpdate = async () => {
  try {
    await updateOrderStatus(statusForm.value.orderId, {
      status: statusForm.value.newStatus,
      remark: statusForm.value.remark
    })
    ElMessage.success('状态更新成功')
    showStatusDialog.value = false
    loadOrders()
  } catch (error) {
    console.error('更新失败:', error)
    ElMessage.error('更新失败')
  }
}

const handleExport = async () => {
  try {
    // 调用导出API
    const response = await fetch('/api/admin/orders/export', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('adminToken') || ''}`
      }
    })
    
    if (!response.ok) {
      throw new Error('导出失败')
    }
    
    // 获取文件名
    const contentDisposition = response.headers.get('content-disposition')
    let filename = '订单数据.xlsx'
    if (contentDisposition) {
      const match = contentDisposition.match(/filename=(.+)/)
      if (match) {
        filename = decodeURIComponent(match[1])
      }
    }
    
    // 下载文件
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
  selectedOrders.value = selection
}

const handleSizeChange = (size) => {
  pagination.value.pageSize = size
  pagination.value.page = 1
  loadOrders()
}

const handleCurrentChange = (page) => {
  pagination.value.page = page
  loadOrders()
}

onMounted(() => {
  loadOrders()
})
</script>

<style scoped>
.orders-page {
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

.amount {
  color: #f56c6c;
  font-weight: 600;
}

.order-detail {
  padding: 20px;
}

.detail-info {
  margin-top: 24px;
}

.amount-large {
  color: #f56c6c;
  font-size: 18px;
  font-weight: 700;
}

</style>

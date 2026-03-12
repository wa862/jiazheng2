<template>
  <div class="orders-page">
    <div class="page-header">
      <h1>我的订单</h1>
      <p>管理您的所有订单</p>
    </div>

    <div class="order-tabs">
      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <el-tab-pane label="全部订单" name="all"></el-tab-pane>
        <el-tab-pane label="待支付" name="unpaid"></el-tab-pane>
        <el-tab-pane label="待服务" name="pending"></el-tab-pane>
        <el-tab-pane label="服务中" name="processing"></el-tab-pane>
        <el-tab-pane label="已完成" name="completed"></el-tab-pane>
        <el-tab-pane label="已取消" name="cancelled"></el-tab-pane>
      </el-tabs>
    </div>

    <div v-if="loading" class="loading-container">
      <el-icon class="is-loading" :size="80"><Loading /></el-icon>
      <p>加载中...</p>
    </div>

    <div v-else-if="orders.length === 0" class="empty-container">
      <el-empty description="暂无订单">
        <el-button type="primary" @click="$router.push('/services')">去预约服务</el-button>
      </el-empty>
    </div>

    <div v-else class="order-list">
      <div v-for="order in orders" :key="order.id" class="order-card">
        <div class="order-header">
          <div class="order-info">
            <span class="order-id">订单号：{{ order.orderNo }}</span>
            <span class="order-time">{{ order.createTime }}</span>
          </div>
          <el-tag :type="getStatusType(order)" size="large">{{ getOrderStatusText(order) }}</el-tag>
        </div>

        <div class="order-content">
          <div class="worker-info">
            <el-image :src="order.workerAvatar" :alt="order.workerName" class="worker-avatar" fit="cover">
              <template #error>
                <div class="image-error"><el-icon :size="40"><User /></el-icon></div>
              </template>
            </el-image>
            <div class="worker-details">
              <h3>{{ order.workerName }}</h3>
              <p>{{ order.serviceName }}</p>
              <p>服务时间：{{ order.serviceTime }}</p>
              <p>服务时长：{{ order.duration }}分钟</p>
            </div>
          </div>

          <div class="order-price">
            <span class="price-label">订单金额</span>
            <span class="price-value">¥{{ order.amount }}</span>
          </div>
        </div>

        <div class="order-address">
          <el-icon><Location /></el-icon>
          <span>{{ order.address }}</span>
        </div>

        <div class="order-actions">
          <template v-if="isUnpaid(order)">
            <el-button type="primary" @click="handlePay(order)">去支付</el-button>
            <el-button @click="handleCancel(order.id)">取消订单</el-button>
          </template>
          <template v-else-if="order.orderStatus === 'pending'">
            <el-button @click="handleCancel(order.id)">取消订单</el-button>
          </template>
          <template v-else-if="order.orderStatus === 'processing'">
            <el-button type="primary" @click="handleComplete(order.id)">确认完成</el-button>
          </template>
          <template v-else-if="order.orderStatus === 'completed'">
            <el-button v-if="!order.reviewed && !order.rating" type="primary" @click="handleReview(order)">去评价</el-button>
            <el-button v-else-if="order.reviewed || order.rating" type="success" disabled>已评价</el-button>
            <el-button @click="handleRebook(order)">再次预约</el-button>
          </template>
          <template v-else-if="order.orderStatus === 'cancelled'">
            <el-button @click="handleRebook(order)">再次预约</el-button>
          </template>
        </div>
      </div>
    </div>

    <div v-if="total > 0" class="pagination">
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.pageSize"
        :total="total"
        :page-sizes="[10, 20, 30, 50]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </div>

    <el-dialog v-model="showReviewDialog" title="评价服务" width="600px">
      <el-form :model="reviewForm" label-width="100px">
        <el-form-item label="评分">
          <el-rate v-model="reviewForm.rating" show-score text-color="#ff9900" score-template="{value}分"></el-rate>
        </el-form-item>
        <el-form-item label="评价内容">
          <el-input 
            v-model="reviewForm.content" 
            type="textarea" 
            :rows="5"
            placeholder="请输入您的评价"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="收藏家政人员">
          <el-checkbox v-model="reviewForm.isFavorite">收藏该家政人员</el-checkbox>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showReviewDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmitReview">提交评价</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Loading, User, Location } from '@element-plus/icons-vue'
import { getOrders, cancelOrder, updateOrderStatus, updatePaymentStatus, addReview, getUserInfo, addFavorite } from '../../api'

const router = useRouter()
const route = useRoute()
const userInfo = ref({ username: '用户' })
const userId = ref(null)
const orders = ref([])
const total = ref(0)
const loading = ref(false)
const activeTab = ref('all')
const showReviewDialog = ref(false)
const currentOrder = ref(null)

const pagination = ref({
  page: 1,
  pageSize: 10
})

const reviewForm = ref({
  rating: 5,
  content: '',
  isFavorite: false
})

const loadUserInfo = async () => {
  try {
    const result = await getUserInfo()
    if (result.code === 200 && result.data) {
      userInfo.value = result.data
      userId.value = result.data.userId
    } else {
      console.error('获取用户信息失败:', result.message)
      ElMessage.error('获取用户信息失败')
      router.push('/login')
    }
  } catch (error) {
    console.error('加载用户信息失败:', error)
    ElMessage.error('请先登录')
    router.push('/login')
  }
}

const loadOrders = async () => {
  loading.value = true
  try {
    const params = {
      page: pagination.value.page,
      pageSize: pagination.value.pageSize,
      userId: userId.value
    }
    if (activeTab.value === 'unpaid') {
      params.orderStatus = 'pending'
      params.paymentStatus = 'unpaid'
    } else if (activeTab.value === 'pending') {
      params.orderStatus = 'pending'
      params.paymentStatus = 'paid'
    } else if (activeTab.value !== 'all') {
      params.orderStatus = activeTab.value
    }

    const result = await getOrders(params)

    if (result.code === 200 && result.data) {
      const orderList = result.data.list || []
      orders.value = orderList.map(order => ({
        ...order,
        createTime: order.createdAt,
        serviceName: order.serviceType,
        serviceTime: `${order.serviceDate} ${order.startTime}-${order.endTime}`,
        amount: order.totalAmount,
        address: order.userAddress,
        workerAvatar: order.workerAvatar || getAvatar(order.workerName),
        reviewed: !!order.rating,
        paymentStatus: order.paymentStatus || 'unpaid'
      }))
      total.value = result.data.total ?? 0
    } else {
      orders.value = []
      total.value = 0
    }
  } catch (error) {
    console.error('加载订单失败:', error)
    orders.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const getAvatar = (workerName) => {
  // 生成包含三个字的SVG头像（带随机鲜艳背景色）
  const name = workerName || '未知'
  const bgColors = ['#E3F2FD', '#E8F5E9', '#FFF3E0', '#FFEBEE', '#F3E5F5', '#E0F2F1', '#FFF8E1', '#E1F5FE']
  const textColors = ['#1976D2', '#388E3C', '#F57C00', '#D32F2F', '#7B1FA2', '#00796B', '#FBC02D', '#0288D1']
  const randomIndex = Math.floor(Math.random() * bgColors.length)
  const bgColor = bgColors[randomIndex]
  const textColor = textColors[randomIndex]
  const svg = `
    <svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">
      <rect width="100" height="100" fill="${bgColor}" rx="8"/>
      <text x="50" y="55" font-size="28" fill="${textColor}" text-anchor="middle" dominant-baseline="middle" font-family="Arial, sans-serif" font-weight="bold">${name.substring(0, 3)}</text>
    </svg>
  `
  return `data:image/svg+xml;base64,${btoa(unescape(encodeURIComponent(svg)))}`
}

const handleTabChange = () => {
  pagination.value.page = 1
  loadOrders()
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

const isUnpaid = (order) => {
  return order && order.orderStatus === 'pending' && (order.paymentStatus || 'unpaid') === 'unpaid'
}

const getStatusType = (order) => {
  if (isUnpaid(order)) return 'danger'
  const status = order?.orderStatus
  const typeMap = {
    'pending': 'warning',
    'processing': 'primary',
    'completed': 'info',
    'cancelled': 'danger'
  }
  return typeMap[status] || 'info'
}

const getOrderStatusText = (order) => {
  if (isUnpaid(order)) return '待支付'
  const status = order?.orderStatus
  const textMap = {
    'pending': '待服务',
    'processing': '服务中',
    'completed': '已完成',
    'cancelled': '已取消'
  }
  return textMap[status] || status
}

const handlePay = async (order) => {
  try {
    await ElMessageBox.confirm(`确认支付 ¥${order.amount}？`, '去支付', {
      confirmButtonText: '确认支付',
      cancelButtonText: '取消',
      type: 'info'
    })
    await updatePaymentStatus(order.id, 'paid', 'wechat', 'pay-' + Date.now())
    ElMessage.success('支付成功')
    loadOrders()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('支付失败:', error)
      ElMessage.error('支付失败，请重试')
    }
  }
}

const handleCancel = async (orderId) => {
  try {
    await ElMessageBox.confirm('确定要取消这个订单吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await cancelOrder(orderId)
    ElMessage.success('订单已取消')
    loadOrders()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('取消订单失败:', error)
      ElMessage.error('取消订单失败')
    }
  }
}

const handleComplete = async (orderId) => {
  try {
    await ElMessageBox.confirm('确认服务已完成？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'info'
    })
    
    // 调用后端API更新订单状态
    await updateOrderStatus(orderId, 'completed')
    
    ElMessage.success('订单已完成')
    loadOrders()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('完成订单失败:', error)
      ElMessage.error('完成订单失败')
    }
  }
}

const handleReview = (order) => {
  currentOrder.value = order
  reviewForm.value = {
    rating: 5,
    content: '',
    isFavorite: false
  }
  showReviewDialog.value = true
}

const handleSubmitReview = async () => {
  try {
    await addReview(currentOrder.value.id, reviewForm.value.rating, reviewForm.value.content)
    
    // 如果勾选了收藏，则调用收藏接口
    if (reviewForm.value.isFavorite && currentOrder.value.workerId) {
      try {
        await addFavorite(currentOrder.value.workerId)
        ElMessage.success('评价提交成功，已收藏该家政人员')
      } catch (favoriteError) {
        console.error('收藏失败:', favoriteError)
        ElMessage.success('评价提交成功，但收藏失败')
      }
    } else {
      ElMessage.success('评价提交成功')
    }
    
    showReviewDialog.value = false
    loadOrders()
  } catch (error) {
    console.error('提交评价失败:', error)
    ElMessage.error('提交评价失败')
  }
}

const handleRebook = (order) => {
  router.push({ path: '/booking', query: { workerId: order.workerId } })
}

onMounted(async () => {
  if (route.query.tab === 'unpaid') {
    activeTab.value = 'unpaid'
  }
  await loadUserInfo()
  if (userId.value) {
    await loadOrders()
  }
})
</script>

<style scoped>
.orders-page {
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-header h1 {
  font-size: 48px;
  margin-bottom: 12px;
  color: #333;
}

.page-header p {
  font-size: 20px;
  color: #666;
}

.order-tabs {
  margin-bottom: 32px;
}

.order-tabs :deep(.el-tabs__nav-wrap::after) {
  height: 2px;
}

.order-tabs :deep(.el-tabs__item) {
  font-size: 18px;
  padding: 0 32px;
  height: 56px;
  line-height: 56px;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 150px 0;
  color: #999;
}

.loading-container p {
  margin-top: 20px;
  font-size: 20px;
}

.empty-container {
  padding: 150px 0;
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.order-card {
  background: white;
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  transition: all 0.3s;
}

.order-card:hover {
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 20px;
  border-bottom: 2px solid #f0f0f0;
  margin-bottom: 24px;
}

.order-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.order-id {
  font-size: 16px;
  color: #666;
}

.order-time {
  font-size: 14px;
  color: #999;
}

.order-content {
  display: flex;
  justify-content: space-between;
  gap: 32px;
  margin-bottom: 20px;
}

.worker-info {
  display: flex;
  gap: 20px;
  flex: 1;
}

.worker-avatar {
  width: 100px;
  height: 100px;
  border-radius: 12px;
  flex-shrink: 0;
}

.image-error {
  width: 100px;
  height: 100px;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ccc;
  border-radius: 12px;
}

.worker-details {
  flex: 1;
}

.worker-details h3 {
  margin: 0 0 12px 0;
  font-size: 22px;
  color: #333;
}

.worker-details p {
  margin: 8px 0;
  color: #666;
  font-size: 16px;
}

.order-price {
  text-align: right;
  flex-shrink: 0;
}

.price-label {
  display: block;
  color: #999;
  font-size: 16px;
  margin-bottom: 8px;
}

.price-value {
  display: block;
  color: #ff6600;
  font-size: 36px;
  font-weight: bold;
}

.order-address {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
  margin-bottom: 20px;
  color: #666;
  font-size: 16px;
}

.order-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  padding-top: 20px;
  border-top: 2px solid #f0f0f0;
}

.order-actions .el-button {
  height: 44px;
  padding: 0 32px;
  font-size: 16px;
}

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 48px;
}
</style>
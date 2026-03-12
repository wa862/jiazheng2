<template>
  <div class="worker-detail-page">
    <div v-if="loading" class="loading-container">
      <el-icon class="is-loading" :size="80"><Loading /></el-icon>
      <p>加载中...</p>
    </div>

    <div v-else-if="worker" class="detail-container">
      <div class="breadcrumb">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item @click="$router.push('/')">首页</el-breadcrumb-item>
          <el-breadcrumb-item @click="$router.push('/services')">服务分类</el-breadcrumb-item>
          <el-breadcrumb-item>{{ worker.name }}</el-breadcrumb-item>
        </el-breadcrumb>
      </div>

      <!-- 中间主要内容区域 -->
      <div class="main-content-wrapper">
        <!-- 左侧：家政人员卡片 -->
        <div class="worker-profile-card">
          <div class="profile-header">
            <div class="avatar-wrapper">
              <img :src="getAvatar(worker)" :alt="worker.name" class="profile-avatar">
              <div class="status-badge" :class="worker.status === 'active' ? 'active' : 'inactive'">
                {{ worker.status === 'active' ? '可预约' : '休息中' }}
              </div>
            </div>
            <h1 class="profile-name">{{ worker.name }}</h1>
            <div class="profile-rating">
              <el-rate v-model="worker.rating" disabled show-score text-color="#ff9900" score-template="{value}分" />
              <span class="order-count">已服务 {{ worker.orderCount || 0 }} 单</span>
            </div>
          </div>

          <div class="profile-stats">
            <div class="stat-item">
              <span class="stat-value">{{ worker.experience || 0 }}年</span>
              <span class="stat-label">从业经验</span>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item">
              <span class="stat-value">¥{{ worker.price || 0 }}</span>
              <span class="stat-label">每小时</span>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item">
              <span class="stat-value">{{ worker.age || '--' }}岁</span>
              <span class="stat-label">年龄</span>
            </div>
          </div>

          <div class="profile-actions">
            <el-button type="primary" size="large" @click="showBookingDialog = true" class="book-btn">
              <el-icon><CalendarCheck /></el-icon>
              立即预约
            </el-button>
            <el-button size="large" @click="toggleFavorite" :type="isFavorite ? 'warning' : 'default'" class="favorite-btn">
              <el-icon><Star /></el-icon>
              {{ isFavorite ? '已收藏' : '收藏' }}
            </el-button>
            <el-button size="large" @click="showReviewDialog = true" type="success" class="review-btn">
              <el-icon><Edit /></el-icon>
              写评价
            </el-button>
            <el-button size="large" @click="toggleBlock" :type="isBlocked ? 'danger' : 'default'" class="block-btn">
              <el-icon><CircleClose /></el-icon>
              {{ isBlocked ? '已拉黑' : '拉黑' }}
            </el-button>
          </div>
        </div>

        <!-- 右侧：详细介绍 -->
        <div class="worker-detail-content">
          <!-- 个人简介 -->
          <div class="detail-section">
            <div class="section-title">
              <el-icon><User /></el-icon>
              <span>个人简介</span>
            </div>
            <div class="section-content">
              <p class="intro-text">{{ worker.description || `${worker.name}是一位经验丰富的家政服务人员，从业${worker.experience || 0}年，服务过众多家庭，深受客户好评。擅长各类家政服务，工作认真负责，态度亲切。` }}</p>
              <div class="info-tags">
                <el-tag v-for="tag in worker.tags" :key="tag" type="success" effect="light" size="large">{{ tag }}</el-tag>
              </div>
            </div>
          </div>

          <!-- 基本信息 -->
          <div class="detail-section">
            <div class="section-title">
              <el-icon><Document /></el-icon>
              <span>基本信息</span>
            </div>
            <div class="section-content">
              <div class="info-grid">
                <div class="info-row">
                  <span class="info-label">性别</span>
                  <span class="info-value">{{ worker.gender === 'M' ? '男' : worker.gender === 'F' ? '女' : '未知' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">年龄</span>
                  <span class="info-value">{{ worker.age || '--' }}岁</span>
                </div>
                <div class="info-row">
                  <span class="info-label">联系电话</span>
                  <span class="info-value phone">{{ worker.phone }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">服务价格</span>
                  <span class="info-value price">¥{{ worker.price || 0 }}/小时</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 专业技能 -->
          <div class="detail-section">
            <div class="section-title">
              <el-icon><Medal /></el-icon>
              <span>专业技能</span>
            </div>
            <div class="section-content">
              <div class="skills-list">
                <div v-for="(skill, index) in workerSkills" :key="index" class="skill-item">
                  <el-icon><Check /></el-icon>
                  <span>{{ skill }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 服务评价 -->
          <div class="detail-section">
            <div class="section-title">
              <el-icon><ChatDotRound /></el-icon>
              <span>客户评价 ({{ reviews.length }})</span>
            </div>
            <div class="section-content">
              <div v-if="reviews.length === 0" class="empty-reviews">
                <el-empty description="暂无评价，快来预约体验吧！" />
              </div>
              <div v-else class="review-list">
                <div v-for="review in reviews.slice(0, 3)" :key="review.id" class="review-card">
                  <div class="review-header">
                    <div class="reviewer-info">
                      <el-avatar :size="40" :src="getAvatar({ name: review.userName })" />
                      <div class="reviewer-meta">
                        <span class="reviewer-name">{{ review.userName }}</span>
                        <span class="review-date">{{ review.createTime }}</span>
                      </div>
                    </div>
                    <el-rate v-model="review.rating" disabled size="small" />
                  </div>
                  <p class="review-text">{{ review.content }}</p>
                </div>
                <el-button v-if="reviews.length > 3" type="text" @click="showAllReviews = true">
                  查看全部 {{ reviews.length }} 条评价
                </el-button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 相似推荐 -->
      <div class="similar-section" v-if="similarWorkers.length > 0">
        <div class="section-title">
          <el-icon><MagicStick /></el-icon>
          <span>相似推荐</span>
        </div>
        <div class="similar-grid">
          <div v-for="similarWorker in similarWorkers" :key="similarWorker.id" class="similar-card" @click="$router.push(`/worker/${similarWorker.id}`)">
            <img :src="getAvatar(similarWorker)" :alt="similarWorker.name" class="similar-avatar">
            <div class="similar-info">
              <h4>{{ similarWorker.name }}</h4>
              <el-rate v-model="similarWorker.rating" disabled size="small" />
              <p class="similar-price">¥{{ similarWorker.price }}/小时</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="empty-container">
      <el-empty description="家政人员不存在">
        <el-button type="primary" @click="$router.push('/services')">返回服务列表</el-button>
      </el-empty>
    </div>

    <el-dialog v-model="showBookingDialog" title="预约服务" width="600px">
      <el-form :model="bookingForm" label-width="100px">
        <el-form-item label="服务项目">
          <el-select v-model="bookingForm.serviceId" placeholder="请选择服务项目" style="width: 100%;">
            <el-option 
              v-for="service in worker.services" 
              :key="service.id" 
              :label="service.name" 
              :value="service.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="服务时间">
          <el-date-picker
            v-model="bookingForm.serviceTime"
            type="datetime"
            placeholder="选择日期时间"
            style="width: 100%;"
            :disabled-date="disabledDate"
          />
        </el-form-item>
        <el-form-item label="服务时长">
          <el-input-number v-model="bookingForm.duration" :min="1" :max="24" />
          <span style="margin-left: 10px;">小时</span>
        </el-form-item>
        <el-form-item label="服务地址">
          <el-input v-model="bookingForm.address" placeholder="请输入服务地址" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="bookingForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input 
            v-model="bookingForm.remark" 
            type="textarea" 
            :rows="3"
            placeholder="请输入备注信息（可选）"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showBookingDialog = false">取消</el-button>
        <el-button type="primary" @click="handleBooking">确认预约</el-button>
      </template>
    </el-dialog>

    <!-- 评价对话框 -->
    <el-dialog v-model="showReviewDialog" title="评价家政人员" width="500px">
      <div class="review-dialog-content">
        <div class="worker-info-summary">
          <img :src="getAvatar(worker)" :alt="worker.name" class="review-avatar">
          <span class="review-worker-name">{{ worker.name }}</span>
        </div>
        <div class="rating-section">
          <span class="rating-label">总体评分</span>
          <el-rate v-model="reviewForm.rating" :max="5" show-score />
        </div>
        <div class="tags-section">
          <span class="tags-label">服务标签（可多选）</span>
          <div class="tags-list">
            <el-check-tag 
              v-for="tag in reviewTags" 
              :key="tag"
              :checked="reviewForm.tags.includes(tag)"
              @change="(checked) => {
                if (checked) {
                  reviewForm.tags.push(tag)
                } else {
                  reviewForm.tags = reviewForm.tags.filter(t => t !== tag)
                }
              }"
            >
              {{ tag }}
            </el-check-tag>
          </div>
        </div>
        <div class="content-section">
          <span class="content-label">评价内容</span>
          <el-input
            v-model="reviewForm.content"
            type="textarea"
            :rows="4"
            placeholder="请分享您的服务体验，帮助其他用户更好地了解这位家政人员..."
            maxlength="200"
            show-word-limit
          />
        </div>
      </div>
      <template #footer>
        <el-button @click="showReviewDialog = false">取消</el-button>
        <el-button type="primary" @click="submitReview">提交评价</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Loading, Calendar, Location, Phone, CalendarCheck, Star, Document, Briefcase, List, ChatDotRound, MagicStick, TrendCharts } from '@element-plus/icons-vue'
import { getWorkerById, getWorkers, createOrder, getWorkerReviews } from '../../api'

const router = useRouter()
const route = useRoute()
const isLoggedIn = ref(!!localStorage.getItem('token'))
const worker = ref(null)
const loading = ref(true)
const reviews = ref([])
const similarWorkers = ref([])
const predictedSatisfaction = ref(0)
const isFavorite = ref(false)
const showBookingDialog = ref(false)

const bookingForm = ref({
  serviceId: null,
  serviceTime: null,
  duration: 2,
  address: '',
  phone: '',
  remark: ''
})

const getAvatar = (worker) => {
  if (worker.avatar) {
    return worker.avatar
  }
  // 生成包含三个字的SVG头像（带随机鲜艳背景色）
  const name = worker.name || '未知'
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

const loadWorkerDetail = async () => {
  loading.value = true
  try {
    const workerId = route.params.id
    const data = await getWorkerById(workerId)
    worker.value = {
      ...data,
      tags: ['专业', '可靠', '经验丰富'],
      experiences: [
        { period: '2020-2024', company: '家政服务公司A', position: '高级家政师', description: '负责高端家庭日常保洁和深度清洁工作' },
        { period: '2018-2020', company: '家政服务公司B', position: '家政师', description: '负责家庭日常保洁工作' }
      ],
      services: [
        { id: 1, name: '日常保洁', price: 50, description: '家庭日常清洁服务，包括客厅、卧室、厨房、卫生间等' },
        { id: 2, name: '深度清洁', price: 80, description: '深度清洁服务，包括油烟机清洗、玻璃清洁等' },
        { id: 3, name: '收纳整理', price: 60, description: '家庭物品收纳整理服务' }
      ]
    }
    predictedSatisfaction.value = Math.floor(Math.random() * 20) + 80
  } catch (error) {
    console.error('加载家政人员详情失败:', error)
  } finally {
    loading.value = false
  }
}

const loadReviews = async () => {
  try {
    const workerId = route.params.id
    const data = await getWorkerReviews(workerId)
    reviews.value = data
  } catch (error) {
    console.error('加载评价失败:', error)
    reviews.value = []
  }
}

const loadSimilarWorkers = async () => {
  try {
    const data = await getWorkers({ categoryId: worker.value.categoryId, limit: 4 })
    const filteredWorkers = data.filter(w => w.id !== worker.value.id).slice(0, 3)
    similarWorkers.value = filteredWorkers
  } catch (error) {
    console.error('加载相似家政人员失败:', error)
  }
}

const disabledDate = (time) => {
  return time.getTime() < Date.now() - 24 * 60 * 60 * 1000
}

const handleBooking = async () => {
  try {
    if (!isLoggedIn.value) {
      router.push('/login')
      return
    }
    
    const orderData = {
      workerId: worker.value.id,
      serviceId: bookingForm.value.serviceId,
      serviceTime: bookingForm.value.serviceTime,
      duration: bookingForm.value.duration,
      address: bookingForm.value.address,
      phone: bookingForm.value.phone,
      remark: bookingForm.value.remark,
      amount: worker.value.price * bookingForm.value.duration
    }
    
    await createOrder(orderData)
    showBookingDialog.value = false
    router.push('/orders')
  } catch (error) {
    console.error('预约失败:', error)
  }
}

const toggleFavorite = () => {
  isFavorite.value = !isFavorite.value
  // 保存收藏状态到本地存储
  const favorites = JSON.parse(localStorage.getItem('favoriteWorkers') || '[]')
  if (isFavorite.value) {
    if (!favorites.includes(worker.value.id)) {
      favorites.push(worker.value.id)
    }
    ElMessage.success('已收藏该家政人员')
  } else {
    const index = favorites.indexOf(worker.value.id)
    if (index > -1) {
      favorites.splice(index, 1)
    }
    ElMessage.info('已取消收藏')
  }
  localStorage.setItem('favoriteWorkers', JSON.stringify(favorites))
}

// 检查是否已收藏
const checkFavoriteStatus = () => {
  const favorites = JSON.parse(localStorage.getItem('favoriteWorkers') || '[]')
  isFavorite.value = favorites.includes(worker.value?.id)
}

// 评价相关
const showReviewDialog = ref(false)
const reviewForm = ref({
  rating: 5,
  content: '',
  tags: []
})
const reviewTags = ['服务态度好', '专业技能强', '准时到达', '清洁彻底', '沟通顺畅', '性价比高']

const submitReview = async () => {
  try {
    if (!reviewForm.value.content.trim()) {
      ElMessage.warning('请输入评价内容')
      return
    }
    
    // 模拟提交评价
    const newReview = {
      id: Date.now(),
      userName: '当前用户',
      rating: reviewForm.value.rating,
      content: reviewForm.value.content,
      createTime: new Date().toLocaleDateString(),
      tags: reviewForm.value.tags
    }
    
    reviews.value.unshift(newReview)
    
    // 更新家政人员评分
    const totalRating = reviews.value.reduce((sum, r) => sum + r.rating, 0)
    worker.value.rating = parseFloat((totalRating / reviews.value.length).toFixed(1))
    worker.value.orderCount = (worker.value.orderCount || 0) + 1
    
    showReviewDialog.value = false
    reviewForm.value = { rating: 5, content: '', tags: [] }
    ElMessage.success('评价提交成功！')
  } catch (error) {
    console.error('提交评价失败:', error)
    ElMessage.error('评价提交失败')
  }
}

// 拉黑功能
const isBlocked = ref(false)
const toggleBlock = () => {
  isBlocked.value = !isBlocked.value
  const blocked = JSON.parse(localStorage.getItem('blockedWorkers') || '[]')
  if (isBlocked.value) {
    if (!blocked.includes(worker.value.id)) {
      blocked.push(worker.value.id)
    }
    ElMessage.warning('已将该家政人员加入黑名单')
  } else {
    const index = blocked.indexOf(worker.value.id)
    if (index > -1) {
      blocked.splice(index, 1)
    }
    ElMessage.info('已将该家政人员移出黑名单')
  }
  localStorage.setItem('blockedWorkers', JSON.stringify(blocked))
}

onMounted(() => {
  loadWorkerDetail().then(() => {
    checkFavoriteStatus()
  })
  loadReviews()
})
</script>

<style scoped>
.worker-detail-page {
  min-height: 100%;
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

.detail-container {
  max-width: 1200px;
  margin: 0 auto;
}

.breadcrumb {
  margin-bottom: 32px;
}

.worker-basic-info {
  display: flex;
  gap: 48px;
  margin-bottom: 48px;
}

.worker-avatar-section {
  flex-shrink: 0;
  text-align: center;
}

.worker-avatar-container {
  width: 300px;
  height: 300px;
  border-radius: 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  margin-bottom: 16px;
}

.worker-avatar-img {
  width: 100%;
  height: 100%;
  border-radius: 16px;
  object-fit: cover;
}

.image-error {
  width: 300px;
  height: 300px;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ccc;
  border-radius: 16px;
}

.worker-details {
  flex: 1;
}

.worker-name {
  font-size: 48px;
  margin-bottom: 24px;
  color: #333;
}

.worker-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 24px;
  margin-bottom: 24px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  color: #666;
}

.worker-rating-section {
  display: flex;
  align-items: center;
  gap: 24px;
  margin-bottom: 24px;
}

.order-count {
  color: #999;
  font-size: 16px;
}

.worker-price-section {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 24px;
  border-radius: 12px;
  margin-bottom: 24px;
}

.price-label {
  font-size: 18px;
  opacity: 0.9;
}

.price-value {
  font-size: 48px;
  font-weight: bold;
  margin: 0 8px;
}

.price-unit {
  font-size: 18px;
  opacity: 0.9;
}

.worker-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 32px;
}

.action-buttons {
  display: flex;
  gap: 16px;
}

.book-btn {
  flex: 1;
  height: 56px;
  font-size: 20px;
}

.favorite-btn {
  height: 56px;
  font-size: 20px;
}

.info-sections {
  display: flex;
  flex-direction: column;
  gap: 64px;
}

.info-section h2 {
  font-size: 32px;
  margin-bottom: 32px;
  color: #333;
  display: flex;
  align-items: center;
  gap: 12px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
}

.info-item {
  background: white;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.info-item .label {
  display: block;
  color: #999;
  font-size: 16px;
  margin-bottom: 8px;
}

.info-item .value {
  display: block;
  color: #333;
  font-size: 20px;
  font-weight: 600;
}

.service-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.service-item {
  background: white;
  padding: 32px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.service-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.service-header h3 {
  margin: 0;
  font-size: 24px;
  color: #333;
}

.service-price {
  font-size: 28px;
  color: #ff6600;
  font-weight: bold;
}

.service-item p {
  margin: 0;
  color: #666;
  font-size: 16px;
  line-height: 1.6;
}

.empty-reviews {
  padding: 60px 0;
}

.review-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.review-item {
  background: white;
  padding: 32px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.reviewer-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.reviewer-details {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.reviewer-name {
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.review-date {
  font-size: 14px;
  color: #999;
}

.review-content {
  margin: 0;
  color: #666;
  font-size: 16px;
  line-height: 1.8;
}

.similar-workers {
  background: white;
  padding: 32px;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.prediction-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 32px;
  border-radius: 12px;
  margin-bottom: 32px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.prediction-header {
  display: flex;
  align-items: center;
  gap: 20px;
}

.prediction-header h3 {
  margin: 0 0 8px 0;
  font-size: 24px;
}

.prediction-header p {
  margin: 0;
  opacity: 0.9;
  font-size: 16px;
}

.prediction-value {
  text-align: right;
}

.prediction-value .value {
  display: block;
  font-size: 56px;
  font-weight: bold;
  line-height: 1;
}

.prediction-value .label {
  display: block;
  font-size: 16px;
  opacity: 0.9;
  margin-top: 8px;
}

.similar-workers h3 {
  margin: 0 0 24px 0;
  font-size: 24px;
  color: #333;
}

.similar-worker-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.similar-worker-card {
  background: #f8f9fa;
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s;
}

.similar-worker-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0,0,0,0.15);
}

.similar-avatar-container {
  width: 100%;
  height: 200px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.similar-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.similar-info {
  padding: 20px;
}

.similar-info h4 {
  margin: 0 0 8px 0;
  font-size: 20px;
  color: #333;
}

.similar-info p {
  margin: 8px 0;
  color: #666;
  font-size: 16px;
}

.similar-price {
  color: #ff6600;
  font-size: 20px;
  font-weight: bold;
  margin: 8px 0 !important;
}
</style>
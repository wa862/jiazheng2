<template>
  <div class="home">
    <el-carousel height="500px" class="carousel" :interval="5000">
      <el-carousel-item v-for="item in carouselItems" :key="item.id">
        <div class="carousel-item" :style="{ backgroundImage: `url(${item.image})` }">
        </div>
      </el-carousel-item>
    </el-carousel>

    <div class="section service-categories">
      <div class="section-header">
        <h2>服务分类</h2>
        <p>专业服务，品质保证</p>
      </div>
      <div class="category-list">
        <div v-for="category in categories" :key="category.id" class="category-item" @click="handleCategoryClick(category.id)">
          <div class="category-icon" :style="{ background: category.color }">
            <el-icon :size="48" color="white"><component :is="category.icon" /></el-icon>
          </div>
          <h3>{{ category.name }}</h3>
          <p>{{ category.description }}</p>
        </div>
      </div>
    </div>

    <div class="section recommendation-section">
      <div class="section-header">
        <h2>智能推荐</h2>
        <p>为您推荐最适合的家政人员</p>
      </div>
      <div v-if="isLoggedIn" class="worker-grid">
        <div v-for="worker in recommendedWorkers" :key="worker.id" class="worker-card" @click="showWorkerDetail(worker)">
          <div class="worker-avatar-container">
            <img :src="getAvatar(worker)" :alt="worker.name" class="worker-avatar-img">
          </div>
          <div class="worker-info">
            <h3>{{ worker.name }}</h3>
            <p class="worker-experience">从业{{ worker.experience }}年</p>
            <p class="worker-price">¥{{ worker.price }}/小时</p>
            <el-rate v-model="worker.rating" disabled show-score text-color="#ff9900" score-template="{value}分"></el-rate>
            <el-button type="primary" class="book-btn" @click.stop="goToBooking(worker.id)">立即预约</el-button>
          </div>
        </div>
      </div>
      <div v-else class="login-tip">
        <el-empty description="请先登录以获取个性化推荐">
          <el-button type="primary" @click="handleLogin">立即登录</el-button>
        </el-empty>
      </div>
    </div>

    <div class="section hot-workers-section">
      <div class="section-header">
        <h2>{{ homeConfig.hotWorkersTitle }}</h2>
        <p>{{ homeConfig.hotWorkersSubtitle }}</p>
      </div>
      <div class="worker-grid">
        <div v-for="worker in hotWorkers" :key="worker.id" class="worker-card" @click="showWorkerDetail(worker)">
          <div class="worker-avatar-container">
            <img :src="getAvatar(worker)" :alt="worker.name" class="worker-avatar-img">
          </div>
          <div class="worker-info">
            <h3>{{ worker.name }}</h3>
            <p class="worker-experience">从业{{ worker.experience }}年</p>
            <p class="worker-price">¥{{ worker.price }}/小时</p>
            <el-rate v-model="worker.rating" disabled show-score text-color="#ff9900" score-template="{value}分"></el-rate>
            <el-button type="primary" class="book-btn" @click.stop="goToBooking(worker.id)">立即预约</el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 家政人员详情对话框 -->
    <el-dialog 
      v-model="detailDialogVisible" 
      :title="currentWorker?.name" 
      width="700px" 
      class="worker-detail-dialog"
      :close-on-click-modal="false"
      :destroy-on-close="true"
    >
      <div v-if="currentWorker" class="detail-content">
        <div class="detail-header">
          <img :src="getAvatar(currentWorker)" :alt="currentWorker.name" class="detail-avatar">
          <div class="detail-info">
            <h3>{{ currentWorker.name }}</h3>
            <div class="detail-meta">
              <el-tag :type="currentWorker.status === 'available' ? 'success' : 'info'">
                {{ currentWorker.status === 'available' ? '可预约' : '休息中' }}
              </el-tag>
              <span class="experience">从业{{ currentWorker.experience }}年</span>
              <span class="age">{{ currentWorker.age }}岁</span>
            </div>
          </div>
        </div>

        <el-divider />

        <div class="detail-body">
          <div class="detail-section">
            <h4>基本信息</h4>
            <div class="info-grid">
              <div class="info-item">
                <span class="label">年龄</span>
                <span class="value">{{ currentWorker.age }}岁</span>
              </div>
              <div class="info-item">
                <span class="label">联系电话</span>
                <span class="value">{{ currentWorker.phone }}</span>
              </div>
              <div class="info-item">
                <span class="label">从业经验</span>
                <span class="value">{{ currentWorker.experience }}年</span>
              </div>
              <div class="info-item">
                <span class="label">服务价格</span>
                <span class="value price">¥{{ currentWorker.price }}/小时</span>
              </div>
            </div>
          </div>

          <div class="detail-section">
            <h4>服务评价</h4>
            <div class="rating-display">
              <el-rate v-model="currentWorker.rating" disabled show-score text-color="#ff9900" score-template="{value}分" />
              <span class="order-count">已服务 {{ Math.floor(Math.random() * 100) + 1 }} 单</span>
            </div>
          </div>

          <div class="detail-section">
            <h4>个人简介</h4>
            <p class="description">{{ currentWorker.description || getWorkerDescription(currentWorker) }}</p>
          </div>

          <div class="detail-section">
            <h4>服务标签</h4>
            <div class="tags-container">
              <el-tag v-if="currentWorker.categoryId === 1" type="success">保洁服务</el-tag>
              <el-tag v-else-if="currentWorker.categoryId === 2" type="success">月嫂服务</el-tag>
              <el-tag v-else-if="currentWorker.categoryId === 3" type="success">护理服务</el-tag>
              <el-tag v-else-if="currentWorker.categoryId === 4" type="success">钟点工</el-tag>
              <el-tag type="primary">经验丰富</el-tag>
              <el-tag type="warning">专业服务</el-tag>
              <el-tag type="info">态度亲切</el-tag>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="goToDetailPage">查看完整详情</el-button>
        <el-button type="success" @click="goToBooking(currentWorker.id)">立即预约</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Brush, Monitor, Tools, HomeFilled } from '@element-plus/icons-vue'
import { getRecommendedWorkers, getWorkers, searchWorkers, getBanners, getHomeConfig } from '../../api'

const router = useRouter()
const isLoggedIn = ref(!!localStorage.getItem('token'))
const userInfo = ref({ username: '用户' })
const recommendedWorkers = ref([])
const hotWorkers = ref([])
const homeConfig = ref({
  hotWorkersCount: 4,
  hotWorkersTitle: '热门家政人员',
  hotWorkersSubtitle: '评分最高的优质服务'
})

// 轮播图：默认三张作为兜底，优先使用后台配置
const defaultCarouselItems = [
  { id: 1, title: '专业家政服务', subtitle: '让生活更美好', image: 'https://pub-141831e61e69445289222976a15b6fb3.r2.dev/Image_to_url_V2/QQ20260228-141301-imagetourl.cloud-1772260094486-4u01be.png' },
  { id: 2, title: '智能匹配', subtitle: '为您推荐最适合的家政人员', image: 'https://pub-141831e61e69445289222976a15b6fb3.r2.dev/Image_to_url_V2/QQ20260228-141338-imagetourl.cloud-1772259461373-c9kyqi.png' },
  { id: 3, title: '品质保证', subtitle: '严格审核，放心选择', image: 'https://pub-141831e61e69445289222976a15b6fb3.r2.dev/Image_to_url_V2/QQ20260228-141536-imagetourl.cloud-1772259488169-ldgkwz.png' }
]

const carouselItems = ref([...defaultCarouselItems])

const categories = ref([
  { id: 1, name: '保洁服务', icon: Brush, color: '#4CAF50', description: '家庭保洁、深度清洁' },
  { id: 2, name: '月嫂服务', icon: User, color: '#2196F3', description: '专业月嫂、母婴护理' },
  { id: 3, name: '护理服务', icon: Monitor, color: '#FF9800', description: '老人陪护、康复护理' },
  { id: 4, name: '钟点工', icon: Tools, color: '#9C27B0', description: '临时帮工、日常杂务' },
  { id: 5, name: '育儿嫂', icon: User, color: '#E91E63', description: '婴幼儿照护、早教' },
  { id: 6, name: '家电清洗', icon: Tools, color: '#00BCD4', description: '空调、油烟机清洗' }
])

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

const loadRecommendedWorkers = async () => {
  try {
    const userId = localStorage.getItem('userId')
    if (userId) {
      const result = await getRecommendedWorkers(userId)
      let workers = []
      if (result.code === 200 && result.data) {
        workers = Array.isArray(result.data) ? result.data.slice(0, 4) : []
      } else if (Array.isArray(result)) {
        workers = result.slice(0, 4)
      }
      recommendedWorkers.value = workers
    }
  } catch (error) {
    console.error('加载推荐失败:', error)
  }
}

const loadHotWorkers = async () => {
  try {
    const count = homeConfig.value.hotWorkersCount || 4
    const result = await getWorkers({ page: 1, pageSize: count, ratingSort: 'desc' })
    let workers = []
    if (result.code === 200 && result.data) {
      workers = result.data.list || []
    } else if (result && result.list) {
      workers = result.list
    }
    hotWorkers.value = workers
  } catch (error) {
    console.error('加载热门家政人员失败:', error)
  }
}

// 从后台加载轮播图配置
const loadBanners = async () => {
  try {
    const res = await getBanners()
    let list = []
    if (res && res.code === 200 && res.data) {
      list = Array.isArray(res.data) ? res.data : (res.data.content || [])
    } else if (Array.isArray(res)) {
      list = res
    }
    if (list.length > 0) {
      carouselItems.value = list
        .map((b, index) => ({
          id: b.id ?? index + 1,
          title: b.title || '',
          subtitle: b.subtitle || '',
          image: b.image || ''
        }))
        .filter(item => item.image)
    }
  } catch (error) {
    console.error('加载轮播图失败:', error)
    // 失败时保留默认轮播图
  }
}

const handleCategoryClick = (categoryId) => {
  router.push({ path: '/services', query: { categoryId } })
}

const handleLogin = () => {
  router.push('/login')
}

const detailDialogVisible = ref(false)
const currentWorker = ref(null)

const showWorkerDetail = (worker) => {
  console.log('点击家政人员:', worker)
  currentWorker.value = worker
  detailDialogVisible.value = true
  console.log('对话框状态:', detailDialogVisible.value)
}

const goToDetailPage = () => {
  if (currentWorker.value) {
    router.push(`/worker/${currentWorker.value.id}`)
    detailDialogVisible.value = false
  }
}

const goToBooking = (workerId) => {
  router.push(`/booking?workerId=${workerId}`)
}

const getWorkerDescription = (worker) => {
  const gender = worker.gender || '女'
  const title = gender === '男' ? '师傅' : '阿姨'
  const pronoun = gender === '男' ? '他' : '她'
  return `${worker.name}${title}是一位经验丰富的家政服务人员，从业${worker.experience}年，服务过众多家庭，深受客户好评。${pronoun}擅长各类家政服务，工作认真负责，态度亲切。`
}

onMounted(async () => {
  loadBanners()
  try {
    const res = await getHomeConfig()
    if (res && res.code === 200 && res.data) {
      homeConfig.value = { ...homeConfig.value, ...res.data }
    }
  } catch (e) {
    // 使用默认 homeConfig
  }
  if (isLoggedIn.value) {
    loadRecommendedWorkers()
  }
  loadHotWorkers()
})
</script>

<style scoped>
.home {
  max-width: 100%;
  margin: 0 auto;
  padding: 0 20px;
}

.carousel {
  margin-bottom: 60px;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
}

.carousel-item {
  width: 100%;
  height: 100%;
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
  background-color: #f5f5f5;
}

/* 响应式轮播图高度 */
@media (max-width: 768px) {
  .el-carousel {
    height: 300px !important;
  }
}

@media (max-width: 576px) {
  .el-carousel {
    height: 200px !important;
  }
  
  .carousel-text h1 {
    font-size: 32px !important;
  }
  
  .carousel-text p {
    font-size: 18px !important;
  }
}



.section {
  margin-bottom: 80px;
}

.section-header {
  text-align: center;
  margin-bottom: 40px;
}

.section-header h2 {
  font-size: 40px;
  margin-bottom: 12px;
  color: #333;
}

.section-header p {
  font-size: 18px;
  color: #666;
}

.category-list {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 32px;
}

.category-item {
  text-align: center;
  padding: 40px 24px;
  background: white;
  border-radius: 16px;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}

.category-item:hover {
  transform: translateY(-8px);
  box-shadow: 0 12px 32px rgba(0,0,0,0.2);
}

.category-icon {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 24px;
}

.category-item h3 {
  margin: 0 0 12px 0;
  font-size: 24px;
  color: #333;
}

.category-item p {
  margin: 0;
  color: #666;
  font-size: 16px;
}

.worker-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 32px;
}

.worker-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}

.worker-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 12px 32px rgba(0,0,0,0.2);
}

.worker-avatar-container {
  width: 100%;
  height: 280px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.worker-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-error {
  width: 100%;
  height: 280px;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ccc;
}

.worker-info {
  padding: 24px;
}

.worker-info h3 {
  margin: 0 0 12px 0;
  font-size: 22px;
  color: #333;
}

.worker-experience {
  color: #666;
  margin: 8px 0;
  font-size: 16px;
}

.worker-price {
  color: #ff6600;
  font-size: 24px;
  font-weight: bold;
  margin: 8px 0;
}

.book-btn {
  width: 100%;
  margin-top: 16px;
  height: 48px;
  font-size: 18px;
}

.login-tip {
  text-align: center;
  padding: 60px;
  background: white;
  border-radius: 16px;
}

/* 响应式布局 */
@media (max-width: 1200px) {
  .category-list {
    grid-template-columns: repeat(3, 1fr);
  }
  
  .worker-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 768px) {
  .category-list {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .worker-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .worker-avatar-container {
    height: 200px;
  }
  
  .image-error {
    height: 200px;
  }
}

@media (max-width: 576px) {
  .category-list {
    grid-template-columns: 1fr;
  }
  
  .worker-grid {
    grid-template-columns: 1fr;
  }
  
  .worker-avatar-container {
    height: 250px;
  }
  
  .image-error {
    height: 250px;
  }
  
  .section-header h2 {
    font-size: 32px;
  }
  
  .section-header p {
    font-size: 16px;
  }
  
  .category-item {
    padding: 32px 16px;
  }
  
  .category-icon {
    width: 80px;
    height: 80px;
  }
  
  .category-item h3 {
    font-size: 20px;
  }
  
  .worker-info h3 {
    font-size: 20px;
  }
  
  .worker-price {
    font-size: 20px;
  }
  
  .book-btn {
    height: 40px;
    font-size: 16px;
  }
}

/* 家政人员详情对话框样式 */
.worker-detail-dialog :deep(.el-dialog) {
  z-index: 9999;
}

.worker-detail-dialog :deep(.el-dialog__body) {
  padding: 0;
}

.detail-content {
  padding: 24px;
}

.detail-header {
  display: flex;
  gap: 20px;
  align-items: center;
}

.detail-avatar {
  width: 120px;
  height: 120px;
  border-radius: 12px;
  object-fit: cover;
  border: 3px solid #409EFF;
}

.detail-info h3 {
  margin: 0 0 12px 0;
  font-size: 28px;
  color: #303133;
}

.detail-meta {
  display: flex;
  gap: 16px;
  align-items: center;
}

.detail-meta .experience,
.detail-meta .age {
  color: #606266;
  font-size: 14px;
}

.detail-body {
  margin-top: 24px;
}

.detail-section {
  margin-bottom: 24px;
}

.detail-section h4 {
  font-size: 16px;
  color: #303133;
  margin: 0 0 12px 0;
  padding-left: 8px;
  border-left: 3px solid #409EFF;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background: #f5f7fa;
  border-radius: 8px;
}

.info-item .label {
  color: #606266;
  font-size: 14px;
}

.info-item .value {
  color: #303133;
  font-weight: 600;
  font-size: 14px;
}

.info-item .value.price {
  color: #f56c6c;
  font-size: 16px;
}

.rating-display {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: #fff7e6;
  border-radius: 8px;
}

.description {
  color: #606266;
  line-height: 1.8;
  font-size: 14px;
  margin: 0;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
</style>
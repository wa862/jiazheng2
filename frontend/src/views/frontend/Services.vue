<template>
  <div class="services-page">
    <div class="page-header">
      <h1>服务分类</h1>
      <p>找到最适合您的家政服务</p>

      <!-- 仅在本页显示的搜索框 -->
      <div class="search-bar">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索家政服务人员"
          class="search-input"
          size="large"
          @keyup.enter="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
          <template #suffix>
            <el-button type="primary" @click="handleSearch">搜索</el-button>
          </template>
        </el-input>
      </div>
      
      <!-- 智能功能入口 -->
      <div class="smart-features">
        <div class="feature-card" @click="$router.push('/smart-match')">
          <div class="feature-icon">
            <el-icon :size="32" color="#409EFF"><Cpu /></el-icon>
          </div>
          <div class="feature-info">
            <h3>智能匹配</h3>
            <p>多目标优化算法精准匹配</p>
          </div>
          <el-icon class="arrow"><ArrowRight /></el-icon>
        </div>
        
        <div class="feature-card" @click="$router.push('/ai-recommendation')">
          <div class="feature-icon">
            <el-icon :size="32" color="#67C23A"><Star /></el-icon>
          </div>
          <div class="feature-info">
            <h3>AI智能问答</h3>
            <p>个性化智能推荐系统</p>
          </div>
          <el-icon class="arrow"><ArrowRight /></el-icon>
        </div>
        
        <div class="feature-card" @click="$router.push('/service-map')">
          <div class="feature-icon">
            <el-icon :size="32" color="#E6A23C"><MapLocation /></el-icon>
          </div>
          <div class="feature-info">
            <h3>服务地图</h3>
            <p>地图可视化找附近服务</p>
          </div>
          <el-icon class="arrow"><ArrowRight /></el-icon>
        </div>
      </div>
    </div>

    <div class="content-layout">
      <el-aside class="filter-sidebar" width="280px">
        <div class="filter-section">
          <h3>服务分类</h3>
          <el-radio-group v-model="filters.categoryId" @change="handleFilterChange">
            <el-radio :label="null">全部</el-radio>
            <el-radio v-for="cat in categories" :key="cat.id" :label="cat.id">{{ cat.name }}</el-radio>
          </el-radio-group>
        </div>

        <div class="filter-section">
          <h3>价格排序</h3>
          <el-radio-group v-model="filters.priceSort" @change="handleFilterChange">
            <el-radio label="">默认</el-radio>
            <el-radio label="asc">价格从低到高</el-radio>
            <el-radio label="desc">价格从高到低</el-radio>
          </el-radio-group>
        </div>

        <div class="filter-section">
          <h3>评分排序</h3>
          <el-radio-group v-model="filters.ratingSort" @change="handleFilterChange">
            <el-radio label="">默认</el-radio>
            <el-radio label="desc">评分从高到低</el-radio>
            <el-radio label="asc">评分从低到高</el-radio>
          </el-radio-group>
        </div>

        <div class="filter-section">
          <h3>价格区间</h3>
          <el-slider 
            v-model="priceRange" 
            :min="0" 
            :max="800" 
            :step="10"
            range
            @change="handleFilterChange"
          />
          <div class="price-display">
            <span>¥{{ priceRange[0] }}</span>
            <span>-</span>
            <span>¥{{ priceRange[1] }}</span>
          </div>
        </div>

        <el-button type="primary" class="reset-btn" @click="resetFilters">重置筛选</el-button>
      </el-aside>

      <el-main class="worker-list">
        <div class="result-info">
          <span>共找到 <strong>{{ total }}</strong> 位家政人员</span>
        </div>

        <div v-if="loading" class="loading-container">
          <el-icon class="is-loading" :size="60"><Loading /></el-icon>
          <p>加载中...</p>
        </div>

        <div v-else-if="workers.length === 0" class="empty-container">
          <el-empty description="暂无符合条件的家政人员">
            <el-button type="primary" @click="resetFilters">重置筛选条件</el-button>
          </el-empty>
        </div>

        <div v-else class="worker-grid">
          <div v-for="worker in workers" :key="worker.id" class="worker-card" @click="showWorkerDetail(worker)">
            <div class="worker-avatar-container">
              <img :src="getAvatar(worker)" :alt="worker.name" class="worker-avatar-img">
            </div>
            <div class="worker-info">
              <div class="worker-header">
                <h3>{{ worker.name }}</h3>
                <el-tag :type="worker.status === 'available' ? 'success' : 'info'">{{ worker.status === 'available' ? '已上架' : '未被预约' }}</el-tag>
              </div>
              <p class="worker-experience">从业{{ worker.experience }}年 | {{ getCategoryName(worker.categoryId) }}</p>
              <div class="worker-tags">
                <el-tag v-if="worker.categoryId === 1" size="small">保洁</el-tag>
                <el-tag v-else-if="worker.categoryId === 2" size="small">月嫂</el-tag>
                <el-tag v-else-if="worker.categoryId === 3" size="small">护理</el-tag>
                <el-tag v-else-if="worker.categoryId === 4" size="small">钟点工</el-tag>
                <el-tag size="small">经验丰富</el-tag>
                <el-tag size="small">专业服务</el-tag>
              </div>
              <div class="worker-rating">
                <el-rate v-model="worker.rating" disabled show-score text-color="#ff9900" score-template="{value}分"></el-rate>
                <span class="order-count">{{ Math.floor(Math.random() * 100) + 1 }}单</span>
              </div>
              <p class="worker-price">¥{{ worker.price }}/小时</p>
              <el-button type="primary" class="book-btn" size="large" @click.stop="goToBooking(worker.id)">立即预约</el-button>
            </div>
          </div>
        </div>

        <div v-if="total > 0" class="pagination">
          <el-pagination
            v-model:current-page="pagination.page"
            v-model:page-size="pagination.pageSize"
            :total="total"
            :page-sizes="[8, 16, 24, 32]"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </el-main>
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
        <el-button type="warning" :disabled="!currentWorker" @click="handleFavorite">
          收藏
        </el-button>
        <el-button type="success" @click="goToBooking(currentWorker.id)">立即预约</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Loading, User, Cpu, MapLocation, ArrowRight, Star, Search } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { getWorkers, getPublicCategories, addFavorite, searchWorkers } from '../../api'

const router = useRouter()
const route = useRoute()
const workers = ref([])
const total = ref(0)
const loading = ref(false)
const categories = ref([])
const searchKeyword = ref('')

const filters = ref({
  categoryId: null,
  priceSort: '',
  ratingSort: ''
})

const priceRange = ref([0, 200])

const pagination = ref({
  page: 1,
  pageSize: 8
})

const categoryMap = ref({})

const getCategoryName = (categoryId) => {
  return categoryMap.value[categoryId] || '其他'
}

const loadCategories = async () => {
  try {
    const result = await getPublicCategories()
    if (result.code === 200 && result.data) {
      // 统一在前端过滤掉“管家服务”等不需要展示的分类
      const list = (Array.isArray(result.data) ? result.data : []).filter(
        (cat) => cat.name !== '管家服务'
      )
      categories.value = list
      // 构建分类映射
      const map = {}
      list.forEach((cat) => {
        map[cat.id] = cat.name
      })
      categoryMap.value = map
    }
  } catch (error) {
    console.error('加载分类失败:', error)
    // 使用默认分类（不含管家服务）
    categories.value = [
      { id: 1, name: '保洁服务' },
      { id: 2, name: '月嫂服务' },
      { id: 3, name: '护理服务' },
      { id: 4, name: '钟点工' },
      { id: 5, name: '育儿嫂' },
      { id: 6, name: '家电清洗' }
    ]
    categoryMap.value = {
      1: '保洁服务',
      2: '月嫂服务',
      3: '护理服务',
      4: '钟点工',
      5: '育儿嫂',
      6: '家电清洗'
    }
  }
}

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

const loadWorkers = async () => {
  loading.value = true
  try {
    let workerList = []
    // 如果有搜索关键字，优先按关键字搜索
    if (searchKeyword.value.trim()) {
      const result = await searchWorkers(searchKeyword.value.trim())
      if (result && Array.isArray(result)) {
        workerList = result
        total.value = result.length
      } else if (result && result.data && Array.isArray(result.data)) {
        workerList = result.data
        total.value = result.data.length
      }
    } else {
      const fs = filters.value
      const params = {
        page: pagination.value.page,
        pageSize: pagination.value.pageSize,
        priceSort: fs.priceSort || undefined,
        ratingSort: fs.ratingSort || undefined,
        minPrice: priceRange.value[0],
        maxPrice: priceRange.value[1]
      }
      if (fs.categoryId != null && fs.categoryId !== '') {
        params.categoryId = Number(fs.categoryId)
      }
      const result = await getWorkers(params)
      if (result.code === 200 && result.data) {
        workerList = result.data.list || []
        total.value = result.data.total ?? 0
      } else if (result && result.list) {
        workerList = result.list
        total.value = result.total ?? 0
      } else if (Array.isArray(result)) {
        workerList = result
        total.value = result.length
      } else {
        workerList = []
        total.value = 0
      }
    }

    workers.value = workerList
    
  } catch (error) {
    console.error('加载家政人员失败:', error)
    workers.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleFilterChange = () => {
  pagination.value.page = 1
  loadWorkers()
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

const resetFilters = () => {
  filters.value = {
    categoryId: null,
    priceSort: '',
    ratingSort: ''
  }
  searchKeyword.value = ''
  priceRange.value = [0, 200]
  pagination.value.page = 1
  loadWorkers()
}

const handleSearch = () => {
  pagination.value.page = 1
  loadWorkers()
  // 搜索完成后清空输入框
  searchKeyword.value = ''
}

const goToBooking = (workerId) => {
  router.push(`/booking?workerId=${workerId}`)
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

const handleFavorite = async () => {
  if (!currentWorker.value) return
  try {
    await addFavorite(currentWorker.value.id)
    ElMessage.success('已收藏该家政人员')
  } catch (error) {
    console.error('收藏失败:', error)
    const msg = error?.response?.data?.message || '收藏失败，请稍后重试'
    ElMessage.error(msg)
  }
}

const getWorkerDescription = (worker) => {
  const gender = worker.gender || '女'
  const title = gender === '男' ? '师傅' : '阿姨'
  const pronoun = gender === '男' ? '他' : '她'
  return `${worker.name}${title}是一位经验丰富的家政服务人员，从业${worker.experience}年，服务过众多家庭，深受客户好评。${pronoun}擅长各类家政服务，工作认真负责，态度亲切。`
}

watch(() => route.query, (newQuery) => {
  if (newQuery.categoryId) {
    filters.value.categoryId = parseInt(newQuery.categoryId)
  }
  if (newQuery.keyword) {
    searchKeyword.value = String(newQuery.keyword)
  }
  loadWorkers()
}, { immediate: true })

onMounted(() => {
  loadCategories()
  loadWorkers()
})
</script>

<style scoped>
.services-page {
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

.search-bar {
  max-width: 600px;
  margin: 16px auto 0;
}

.search-input {
  width: 100%;
}

.page-header p {
  font-size: 20px;
  color: #666;
}

/* 智能功能入口 */
.smart-features {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  margin-top: 40px;
  max-width: 1000px;
  margin-left: auto;
  margin-right: auto;
}

.feature-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 24px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  cursor: pointer;
  transition: all 0.3s;
  border: 2px solid transparent;
}

.feature-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
  border-color: #409EFF;
}

.feature-icon {
  width: 64px;
  height: 64px;
  background: #f5f7fa;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.feature-info {
  flex: 1;
  text-align: left;
}

.feature-info h3 {
  font-size: 18px;
  color: #303133;
  margin: 0 0 4px 0;
}

.feature-info p {
  font-size: 14px;
  color: #909399;
  margin: 0;
}

.arrow {
  color: #c0c4cc;
  transition: all 0.3s;
}

.feature-card:hover .arrow {
  color: #409EFF;
  transform: translateX(4px);
}

@media (max-width: 768px) {
  .smart-features {
    grid-template-columns: 1fr;
  }
}

.content-layout {
  display: flex;
  gap: 40px;
  margin-top: 40px;
}

.filter-sidebar {
  background: white;
  border-radius: 16px;
  padding: 32px 24px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  height: fit-content;
  position: sticky;
  top: 100px;
}

.filter-section {
  margin-bottom: 32px;
}

.filter-section:last-of-type {
  margin-bottom: 24px;
}

.filter-section h3 {
  font-size: 20px;
  margin-bottom: 20px;
  color: #333;
  font-weight: 600;
}

.filter-section .el-radio-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.filter-section .el-radio {
  margin: 0;
  font-size: 16px;
}

.price-display {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 16px;
  font-size: 16px;
  color: #666;
  font-weight: 600;
}

.reset-btn {
  width: 100%;
  height: 48px;
  font-size: 16px;
}

.worker-list {
  flex: 1;
}

.result-info {
  margin-bottom: 24px;
  font-size: 18px;
  color: #666;
}

.result-info strong {
  color: #409EFF;
  font-size: 24px;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 100px 0;
  color: #999;
}

.loading-container p {
  margin-top: 20px;
  font-size: 18px;
}

.empty-container {
  padding: 80px 0;
}

.worker-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 32px;
}

.worker-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  position: relative;
  z-index: 1;
}

.worker-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 12px 32px rgba(0,0,0,0.2);
}

.worker-avatar-container {
  width: 100%;
  height: 320px;
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
  height: 320px;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ccc;
}

.worker-info {
  padding: 24px;
}

.worker-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.worker-header h3 {
  margin: 0;
  font-size: 24px;
  color: #333;
}

.worker-experience {
  color: #666;
  margin: 8px 0;
  font-size: 16px;
}

.worker-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin: 12px 0;
}

.worker-rating {
  display: flex;
  align-items: center;
  gap: 16px;
  margin: 12px 0;
}

.order-count {
  color: #999;
  font-size: 14px;
}

.worker-price {
  color: #ff6600;
  font-size: 28px;
  font-weight: bold;
  margin: 12px 0;
}

.book-btn {
  width: 100%;
  margin-top: 16px;
  height: 52px;
  font-size: 18px;
}

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 48px;
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
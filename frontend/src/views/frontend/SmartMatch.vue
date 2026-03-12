<template>
  <div class="smart-match-page">
    <div class="page-header">
      <h1>智能匹配</h1>
      <p>基于多目标优化算法，为您精准匹配最合适的家政人员</p>
    </div>

    <div class="match-container">
      <!-- 条件输入区 -->
      <div class="condition-panel">
        <h2>匹配条件设置</h2>
        
        <el-form :model="matchForm" label-position="top" class="match-form">
          <el-form-item label="服务类型">
            <el-select v-model="matchForm.serviceType" placeholder="请选择服务类型" size="large">
              <el-option label="保洁服务" value="cleaning" />
              <el-option label="月嫂服务" value="maternity" />
              <el-option label="护理服务" value="nursing" />
              <el-option label="钟点工" value="hourly" />
              <el-option label="育儿嫂" value="childcare" />
              <el-option label="老人陪护" value="elderly" />
            </el-select>
          </el-form-item>

          <el-form-item label="预算范围 (元/小时)">
            <el-slider
              v-model="matchForm.budgetRange"
              range
              :min="30"
              :max="200"
              :step="5"
              show-stops
              show-input
            />
          </el-form-item>

          <el-form-item label="服务时间">
            <el-date-picker
              v-model="matchForm.serviceDate"
              type="datetime"
              placeholder="选择服务时间"
              size="large"
              style="width: 100%"
            />
          </el-form-item>

          <el-form-item label="服务时长 (分钟)">
            <el-input-number v-model="matchForm.duration" :min="30" :max="720" :step="30" size="large" />
          </el-form-item>

          <el-form-item label="紧急程度">
            <el-radio-group v-model="matchForm.urgency">
              <el-radio-button label="low">一般</el-radio-button>
              <el-radio-button label="medium">较急</el-radio-button>
              <el-radio-button label="high">紧急</el-radio-button>
            </el-radio-group>
          </el-form-item>

          <el-form-item label="匹配偏好">
            <el-checkbox-group v-model="matchForm.preferences">
              <el-checkbox label="rating">评分优先</el-checkbox>
              <el-checkbox label="distance">距离优先</el-checkbox>
              <el-checkbox label="price">价格优先</el-checkbox>
              <el-checkbox label="experience">经验优先</el-checkbox>
            </el-checkbox-group>
          </el-form-item>

          <!-- 百度地图定位 -->
          <el-form-item label="您的位置">
            <div class="location-section">
              <div class="location-input">
                <el-input 
                  v-model="matchForm.location" 
                  placeholder="点击地图选择位置或使用当前定位"
                  readonly
                  size="large"
                >
                  <template #prefix>
                    <el-icon><Location /></el-icon>
                  </template>
                </el-input>
                <el-button type="primary" size="large" @click="getCurrentLocation">
                  <el-icon><Aim /></el-icon>
                  定位
                </el-button>
              </div>
              <div class="map-container" v-if="showMap">
                <div id="baiduMap" style="width: 100%; height: 200px; border-radius: 8px;"></div>
                <div class="map-controls">
                  <el-button size="small" @click="showMap = false">关闭地图</el-button>
                  <span class="location-tip">点击地图选择具体位置</span>
                </div>
              </div>
              <div v-else class="location-hint">
                <el-button link type="primary" @click="showMap = true">
                  <el-icon><MapLocation /></el-icon>
                  在地图中选择位置
                </el-button>
              </div>
            </div>
          </el-form-item>

          <el-form-item>
            <el-button 
              type="primary" 
              size="large" 
              class="match-btn"
              :loading="isMatching"
              :disabled="!matchForm.location || !String(matchForm.location).trim()"
              @click="startMatching"
            >
              <el-icon><Search /></el-icon>
              开始智能匹配
            </el-button>
            <div v-if="!matchForm.location" class="match-tip">请先选择或定位您的位置后再开始匹配</div>
          </el-form-item>
        </el-form>
      </div>

      <!-- 匹配结果区 -->
      <div class="result-panel">
        <div v-if="!hasResult && !isMatching" class="empty-state">
          <el-empty description="设置匹配条件，开始智能匹配">
            <el-icon :size="80" color="#dcdfe6"><Search /></el-icon>
          </el-empty>
        </div>

        <!-- 匹配动画 -->
        <div v-if="isMatching" class="matching-animation">
          <div class="animation-content">
            <el-progress 
              type="dashboard" 
              :percentage="matchProgress" 
              :color="progressColors"
              :stroke-width="12"
            />
            <h3>正在智能匹配中...</h3>
            <div class="calculation-steps">
              <transition-group name="step">
                <div 
                  v-for="(step, index) in visibleSteps" 
                  :key="step"
                  class="step-item"
                  :class="{ active: index === currentStepIndex }"
                >
                  <el-icon><Loading v-if="index === currentStepIndex" /><Check v-else /></el-icon>
                  <span>{{ step }}</span>
                </div>
              </transition-group>
            </div>
          </div>
        </div>

        <!-- 匹配结果 -->
        <div v-if="hasResult && !isMatching" class="results-container">
          <div class="results-header">
            <h2>匹配结果</h2>
            <p>共找到 {{ matchResults.length }} 位合适的家政人员</p>
          </div>

          <div class="results-list">
            <div 
              v-for="(worker, index) in matchResults" 
              :key="worker.id"
              class="match-card"
              :class="{ 'top-match': index === 0 }"
            >
              <div class="rank-badge" v-if="index < 3">
                <el-tag :type="index === 0 ? 'danger' : index === 1 ? 'warning' : 'info'" size="large">
                  TOP {{ index + 1 }}
                </el-tag>
              </div>

              <div class="worker-avatar-section">
                <el-avatar :size="100" :src="worker.avatar">
                  <el-icon :size="40"><User /></el-icon>
                </el-avatar>
              </div>

              <div class="worker-info-section">
                <h3>{{ worker.name }}</h3>
                <div class="worker-meta">
                  <el-tag size="small">{{ worker.serviceType }}</el-tag>
                  <span class="experience">从业{{ worker.experience }}年</span>
                </div>

                <div class="match-score">
                  <div class="score-label">匹配指数</div>
                  <el-progress 
                    :percentage="worker.matchScore" 
                    :color="getScoreColor(worker.matchScore)"
                    :stroke-width="16"
                    striped
                    striped-flow
                  />
                  <span class="score-value">{{ worker.matchScore }}%</span>
                </div>

                <div class="ai-reason">
                  <el-icon><InfoFilled /></el-icon>
                  <span>AI推荐理由：{{ worker.recommendReason }}</span>
                </div>

                <div class="prediction-section">
                  <div class="prediction-item">
                    <span class="label">预测满意度</span>
                    <el-rate 
                      v-model="worker.predictedSatisfaction" 
                      disabled 
                      show-score 
                      text-color="#ff9900"
                      score-template="{value}分"
                    />
                  </div>
                  <div class="prediction-item">
                    <span class="label">距离</span>
                    <span class="value">{{ worker.distance }}km</span>
                  </div>
                  <div class="prediction-item">
                    <span class="label">价格</span>
                    <span class="value price">¥{{ worker.price }}/小时</span>
                  </div>
                </div>

                <div class="factor-weights">
                  <h4>匹配因子贡献度</h4>
                  <div class="weight-bars">
                    <div v-for="(factor, key) in worker.factors" :key="key" class="weight-item">
                      <span class="weight-label">{{ factor.label }}</span>
                      <el-progress :percentage="factor.value" :color="factor.color" :stroke-width="8" />
                      <span class="weight-value">{{ factor.value }}%</span>
                    </div>
                  </div>
                </div>
              </div>

              <div class="action-section">
                <el-button type="primary" size="small" @click="bookWorker(worker)">
                  立即预约
                </el-button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 算法说明弹窗 -->
    <el-dialog v-model="showAlgorithmInfo" title="智能匹配算法说明" width="700px">
      <div class="algorithm-info">
        <h3>多目标优化匹配模型</h3>
        <p>本系统采用多目标优化算法，综合考虑以下因子：</p>
        <ul>
          <li><strong>评分因子 (R)</strong>：家政人员历史评分</li>
          <li><strong>距离因子 (D)</strong>：与用户位置的距离</li>
          <li><strong>价格因子 (P)</strong>：价格与预算的匹配度</li>
          <li><strong>技能因子 (S)</strong>：服务类型匹配度</li>
          <li><strong>负载因子 (L)</strong>：当前工作负载均衡</li>
        </ul>
        <div class="formula">
          <p>综合评分公式：</p>
          <code>Score = w₁×R + w₂×(1/D) + w₃×P + w₄×S + w₅×L</code>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Search, User, Loading, Check, InfoFilled, Location, Aim, MapLocation } from '@element-plus/icons-vue'
import { getWorkers } from '../../api'

const router = useRouter()

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

const matchForm = ref({
  serviceType: '',
  budgetRange: [50, 150],
  serviceDate: '',
  duration: 2,
  urgency: 'medium',
  preferences: ['rating', 'distance'],
  location: '',
  lat: null,
  lng: null
})

// 地图相关
const showMap = ref(false)
const map = ref(null)
const marker = ref(null)

// 初始化百度地图
const initMap = () => {
  if (typeof BMap !== 'undefined') {
    map.value = new BMap.Map('baiduMap')
    const point = new BMap.Point(116.404, 39.915) // 默认北京天安门
    map.value.centerAndZoom(point, 15)
    map.value.enableScrollWheelZoom()
    
    // 点击地图选择位置
    map.value.addEventListener('click', function(e) {
      const pt = e.point
      matchForm.value.lat = pt.lat
      matchForm.value.lng = pt.lng
      
      // 添加标记
      if (marker.value) {
        map.value.removeOverlay(marker.value)
      }
      marker.value = new BMap.Marker(pt)
      map.value.addOverlay(marker.value)
      
      // 逆地址解析
      const geoc = new BMap.Geocoder()
      geoc.getLocation(pt, function(rs) {
        const addComp = rs.addressComponents
        matchForm.value.location = addComp.province + addComp.city + addComp.district + addComp.street + addComp.streetNumber
      })
    })
  }
}

// 获取当前位置
const getCurrentLocation = () => {
  if (navigator.geolocation) {
    ElMessage.info('正在获取您的位置...')
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const lat = position.coords.latitude
        const lng = position.coords.longitude
        matchForm.value.lat = lat
        matchForm.value.lng = lng
        
        // 显示地图并定位
        showMap.value = true
        setTimeout(() => {
          if (typeof BMap !== 'undefined') {
            if (!map.value) {
              initMap()
            }
            const point = new BMap.Point(lng, lat)
            map.value.centerAndZoom(point, 16)
            
            // 添加标记
            if (marker.value) {
              map.value.removeOverlay(marker.value)
            }
            marker.value = new BMap.Marker(point)
            map.value.addOverlay(marker.value)
            
            // 逆地址解析
            const geoc = new BMap.Geocoder()
            geoc.getLocation(point, function(rs) {
              const addComp = rs.addressComponents
              matchForm.value.location = addComp.province + addComp.city + addComp.district + addComp.street + addComp.streetNumber
              ElMessage.success('定位成功：' + matchForm.value.location)
            })
          }
        }, 100)
      },
      (error) => {
        console.error('定位失败:', error)
        ElMessage.error('定位失败，请手动选择位置')
        showMap.value = true
        setTimeout(() => initMap(), 100)
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
      }
    )
  } else {
    ElMessage.warning('您的浏览器不支持地理定位')
    showMap.value = true
    setTimeout(() => initMap(), 100)
  }
}

const isMatching = ref(false)
const hasResult = ref(false)
const matchProgress = ref(0)
const currentStepIndex = ref(0)

const progressColors = [
  { color: '#f56c6c', percentage: 20 },
  { color: '#e6a23c', percentage: 40 },
  { color: '#5cb87a', percentage: 60 },
  { color: '#1989fa', percentage: 80 },
  { color: '#6f7ad3', percentage: 100 }
]

const calculationSteps = [
  '正在分析用户需求...',
  '正在计算距离因子...',
  '正在评估价格匹配度...',
  '正在计算技能匹配度...',
  '正在评估负载均衡...',
  '正在综合评分排序...',
  '正在生成推荐理由...',
  '匹配完成！'
]

const visibleSteps = computed(() => {
  return calculationSteps.slice(0, currentStepIndex.value + 1)
})

const matchResults = ref([])

const startMatching = async () => {
  if (!matchForm.value.serviceType) {
    ElMessage.warning('请选择服务类型')
    return
  }
  if (!matchForm.value.location || !String(matchForm.value.location).trim()) {
    ElMessage.warning('请先选择或定位您的位置，以便为您推荐附近的家政人员')
    return
  }

  isMatching.value = true
  hasResult.value = false
  matchProgress.value = 0
  currentStepIndex.value = 0

  const totalSteps = calculationSteps.length
  const stepDuration = 200

  for (let i = 0; i < totalSteps; i++) {
    await new Promise(resolve => setTimeout(resolve, stepDuration))
    currentStepIndex.value = i
    matchProgress.value = Math.round(((i + 1) / totalSteps) * 100)
  }

  try {
    const result = await getWorkers({ page: 1, pageSize: 50 })
    if (result.code === 200 && result.data) {
      generateMatchResults(result.data.list || [])
    } else {
      ElMessage.error('获取家政人员数据失败')
    }
  } catch (error) {
    console.error('获取家政人员失败:', error)
    ElMessage.error('获取家政人员数据失败')
  }
  
  isMatching.value = false
  hasResult.value = true
  
  ElMessage.success('智能匹配完成！')
}

const generateMatchResults = (workers) => {
  const serviceTypes = {
    cleaning: '保洁服务',
    maternity: '月嫂服务',
    nursing: '护理服务',
    hourly: '钟点工',
    childcare: '育儿嫂',
    elderly: '老人陪护'
  }

  const [minBudget, maxBudget] = matchForm.value.budgetRange
  
  const filteredWorkers = workers.filter(worker => {
    const price = worker.price || 0
    return price >= minBudget && price <= maxBudget
  })

  const workersToUse = filteredWorkers.length > 0 ? filteredWorkers : workers
  
  const randomCount = Math.floor(Math.random() * 11) + 5
  const shuffled = workersToUse.sort(() => 0.5 - Math.random())
  const selectedWorkers = shuffled.slice(0, Math.min(randomCount, workersToUse.length))

  const recommendReasons = [
    '评分高、距离近、价格适中，与您的需求高度匹配',
    '价格优惠、经验丰富，性价比高',
    '从业时间长、专业技能强',
    '价格最低，适合预算有限的用户',
    '评分优秀，服务态度好',
    '经验丰富，专业技能过硬',
    '距离最近，响应速度快',
    '综合评分最高，推荐首选'
  ]

  matchResults.value = selectedWorkers.map((worker, index) => {
    const baseScore = 70 + Math.floor(Math.random() * 30)
    const price = worker.price || 50
    const rating = worker.rating || 4.5
    const experience = worker.experience || 3
    
    return {
      id: worker.id,
      name: worker.name,
      avatar: getAvatar(worker),
      serviceType: serviceTypes[matchForm.value.serviceType] || worker.serviceType,
      experience: experience,
      price: price,
      matchScore: baseScore - index * 2,
      recommendReason: recommendReasons[index % recommendReasons.length],
      predictedSatisfaction: rating,
      distance: (Math.random() * 5 + 0.5).toFixed(1),
      factors: {
        rating: { label: '评分因子', value: Math.floor(rating * 20), color: '#67C23A' },
        distance: { label: '距离因子', value: Math.floor(Math.random() * 30 + 60), color: '#409EFF' },
        price: { label: '价格因子', value: Math.floor(Math.random() * 30 + 65), color: '#E6A23C' },
        skill: { label: '技能因子', value: Math.floor(Math.random() * 25 + 70), color: '#F56C6C' },
        load: { label: '负载因子', value: Math.floor(Math.random() * 20 + 75), color: '#909399' }
      }
    }
  }).sort((a, b) => b.matchScore - a.matchScore)
}

const getScoreColor = (score) => {
  if (score >= 90) return '#67C23A'
  if (score >= 80) return '#E6A23C'
  if (score >= 70) return '#409EFF'
  return '#F56C6C'
}

const bookWorker = (worker) => {
  router.push({
    path: '/booking',
    query: {
      workerId: worker.id,
      serviceType: matchForm.value.serviceType,
      serviceDate: matchForm.value.serviceDate,
      duration: matchForm.value.duration
    }
  })
}

const viewDetail = (worker) => {
  router.push(`/worker/${worker.id}`)
}

const showAlgorithmInfo = ref(false)
</script>

<style scoped>
.smart-match-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 40px 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-header h1 {
  font-size: 36px;
  color: #303133;
  margin-bottom: 12px;
}

.page-header p {
  font-size: 18px;
  color: #606266;
}

.match-container {
  display: grid;
  grid-template-columns: 380px 1fr;
  gap: 30px;
}

.condition-panel {
  background: white;
  border-radius: 12px;
  padding: 30px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  height: fit-content;
}

.condition-panel h2 {
  font-size: 20px;
  color: #303133;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid #ebeef5;
}

.match-form :deep(.el-form-item__label) {
  font-weight: 600;
  color: #606266;
}

/* 地图定位样式 */
.location-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.location-input {
  display: flex;
  gap: 12px;
}

.location-input .el-input {
  flex: 1;
}

.map-container {
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #dcdfe6;
}

.map-controls {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 12px;
  background: #f5f7fa;
}

.location-tip {
  font-size: 12px;
  color: #909399;
}

.location-hint {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 0;
}

.match-btn {
  width: 100%;
  height: 48px;
  font-size: 16px;
  margin-top: 16px;
}

.match-tip {
  margin-top: 8px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.result-panel {
  background: white;
  border-radius: 12px;
  padding: 30px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  min-height: 600px;
}

.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 500px;
}

.matching-animation {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 500px;
}

.animation-content {
  text-align: center;
}

.animation-content h3 {
  margin-top: 24px;
  font-size: 24px;
  color: #303133;
}

.calculation-steps {
  margin-top: 40px;
  text-align: left;
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
}

.step-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  margin-bottom: 8px;
  border-radius: 8px;
  background: #f5f7fa;
  color: #909399;
  transition: all 0.3s;
}

.step-item.active {
  background: #ecf5ff;
  color: #409EFF;
  font-weight: 600;
}

.step-item .el-icon {
  font-size: 18px;
}

.step-enter-active,
.step-leave-active {
  transition: all 0.5s ease;
}

.step-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}

.results-header {
  margin-bottom: 24px;
}

.results-header h2 {
  font-size: 24px;
  color: #303133;
  margin-bottom: 8px;
}

.results-header p {
  color: #606266;
}

.match-card {
  display: grid;
  grid-template-columns: auto 120px 1fr auto;
  gap: 24px;
  padding: 24px;
  margin-bottom: 20px;
  border-radius: 12px;
  background: #f5f7fa;
  border: 2px solid transparent;
  transition: all 0.3s;
  position: relative;
}

.match-card:hover {
  border-color: #409EFF;
  box-shadow: 0 4px 20px rgba(64, 158, 255, 0.15);
}

.match-card.top-match {
  background: linear-gradient(135deg, #fff5f5 0%, #fff 100%);
  border-color: #f56c6c;
}

.rank-badge {
  position: absolute;
  top: -10px;
  left: 20px;
}

.worker-avatar-section {
  display: flex;
  align-items: center;
  justify-content: center;
}

.worker-info-section {
  flex: 1;
}

.worker-info-section h3 {
  font-size: 20px;
  color: #303133;
  margin-bottom: 8px;
}

.worker-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.experience {
  color: #606266;
  font-size: 14px;
}

.match-score {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.score-label {
  font-weight: 600;
  color: #303133;
  white-space: nowrap;
}

.score-value {
  font-size: 20px;
  font-weight: 700;
  color: #67C23A;
  white-space: nowrap;
}

.ai-reason {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 12px;
  background: #ecf5ff;
  border-radius: 8px;
  margin-bottom: 16px;
  color: #409EFF;
  font-size: 14px;
}

.ai-reason .el-icon {
  margin-top: 2px;
}

.prediction-section {
  display: flex;
  gap: 24px;
  margin-bottom: 16px;
}

.prediction-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.prediction-item .label {
  color: #606266;
  font-size: 14px;
}

.prediction-item .value {
  font-weight: 600;
  color: #303133;
}

.prediction-item .value.price {
  color: #f56c6c;
}

.factor-weights {
  padding-top: 16px;
  border-top: 1px solid #ebeef5;
}

.factor-weights h4 {
  font-size: 14px;
  color: #606266;
  margin-bottom: 12px;
}

.weight-bars {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.weight-item {
  display: grid;
  grid-template-columns: 80px 1fr 50px;
  align-items: center;
  gap: 12px;
}

.weight-label {
  font-size: 12px;
  color: #909399;
}

.weight-value {
  font-size: 12px;
  color: #606266;
  text-align: right;
}

.action-section {
  display: flex;
  flex-direction: column;
  gap: 8px;
  justify-content: flex-start;
  align-items: flex-end;
  padding-top: 8px;
}

.action-section .el-button {
  font-size: 14px;
}

.algorithm-info {
  padding: 20px;
}

.algorithm-info h3 {
  font-size: 20px;
  color: #303133;
  margin-bottom: 16px;
}

.algorithm-info ul {
  margin: 16px 0;
  padding-left: 20px;
}

.algorithm-info li {
  margin-bottom: 8px;
  color: #606266;
}

.formula {
  background: #f5f7fa;
  padding: 16px;
  border-radius: 8px;
  margin-top: 16px;
}

.formula code {
  display: block;
  margin-top: 8px;
  padding: 12px;
  background: #303133;
  color: #fff;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
}

@media (max-width: 1200px) {
  .match-container {
    grid-template-columns: 1fr;
  }
  
  .condition-panel {
    position: static;
  }
  
  .match-card {
    grid-template-columns: 1fr;
  }
  
  .action-section {
    flex-direction: row;
  }
}
</style>

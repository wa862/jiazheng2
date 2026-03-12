<template>
  <div class="service-map-page">
    <div class="page-header">
      <h1>服务地图</h1>
      <p>地图可视化展示附近家政人员，快速找到离您最近的服务</p>
    </div>

    <div class="map-container">
      <!-- 左侧筛选面板 -->
      <div class="filter-panel">
        <h2>筛选条件</h2>
        
        <el-form :model="filterForm" label-position="top">
          <el-form-item label="搜索位置">
            <el-input
              v-model="searchKeyword"
              placeholder="请输入位置名称，如学校、小区等"
              clearable
              @keyup.enter="searchLocation"
            >
              <template #suffix>
                <el-icon class="search-location-icon" @click="searchLocation">
                  <Search />
                </el-icon>
              </template>
            </el-input>
          </el-form-item>

          <el-form-item label="服务类型">
            <el-select v-model="filterForm.serviceType" placeholder="全部类型" clearable>
              <el-option label="保洁服务" value="cleaning" />
              <el-option label="月嫂服务" value="maternity" />
              <el-option label="护理服务" value="nursing" />
              <el-option label="钟点工" value="hourly" />
              <el-option label="育儿嫂" value="childcare" />
              <el-option label="老人陪护" value="elderly" />
            </el-select>
          </el-form-item>

          <el-form-item label="价格范围">
            <el-slider
              v-model="filterForm.priceRange"
              range
              :min="30"
              :max="200"
              :step="10"
              show-stops
            />
            <div class="price-labels">
              <span>¥{{ filterForm.priceRange[0] }}</span>
              <span>¥{{ filterForm.priceRange[1] }}</span>
            </div>
          </el-form-item>

          <el-form-item label="最低评分">
            <el-rate v-model="filterForm.minRating" show-score />
          </el-form-item>

          <el-form-item label="搜索范围">
            <el-radio-group v-model="filterForm.radius">
              <el-radio-button :value="1">1公里</el-radio-button>
              <el-radio-button :value="3">3公里</el-radio-button>
              <el-radio-button :value="5">5公里</el-radio-button>
              <el-radio-button :value="10">10公里</el-radio-button>
            </el-radio-group>
          </el-form-item>

          <el-form-item>
            <el-button type="primary" @click="applyFilter" style="width: 100%">
              <el-icon><Search /></el-icon>
              应用筛选
            </el-button>
          </el-form-item>
        </el-form>

        <!-- 电子围栏控制 -->
        <div class="fence-control">
          <h3>电子围栏</h3>
          <div class="fence-actions">
            <el-button 
              :type="showFence ? 'success' : 'default'" 
              @click="toggleFence"
              size="small"
            >
              {{ showFence ? '隐藏围栏' : '显示围栏' }}
            </el-button>
            <el-button 
              type="primary" 
              @click="drawFence"
              size="small"
              :disabled="isDrawing"
            >
              {{ isDrawing ? '点击地图绘制' : '绘制围栏' }}
            </el-button>
          </div>
          <div v-if="fenceCenter" class="fence-info">
            <p>中心点: {{ fenceCenter.lng.toFixed(4) }}, {{ fenceCenter.lat.toFixed(4) }}</p>
            <p>半径: {{ fenceRadius }}米</p>
            <p>范围内人数: {{ workersInFence }}人</p>
          </div>
        </div>
      </div>

      <!-- 地图区域 -->
      <div class="map-wrapper">
        <div id="allmap" class="baidu-map"></div>
        
        <!-- 地图控件 -->
        <div class="map-controls">
          <el-button circle @click="locateMe">
            <el-icon><Location /></el-icon>
          </el-button>
          <el-button circle @click="zoomIn">
            <el-icon><Plus /></el-icon>
          </el-button>
          <el-button circle @click="zoomOut">
            <el-icon><Minus /></el-icon>
          </el-button>
          <el-button circle @click="resetView">
            <el-icon><Refresh /></el-icon>
          </el-button>
        </div>

        <!-- 绘制提示 -->
        <div v-if="isDrawing" class="draw-hint">
          <el-alert
            title="请在地图上点击选择围栏中心点"
            type="info"
            :closable="false"
            show-icon
          />
        </div>
      </div>
    </div>

    <!-- 家政人员列表浮窗 - 筛选后才显示 -->
    <div class="worker-list-float" v-if="showWorkerList && hasFiltered">
      <div class="float-header">
        <h3>附近家政人员 ({{ filteredWorkers.length }})</h3>
        <el-button text @click="showWorkerList = false">
          <el-icon><Close /></el-icon>
        </el-button>
      </div>
      <div class="float-content">
        <div 
          v-for="worker in filteredWorkers" 
          :key="worker.id"
          class="worker-list-item"
          :class="{ 
            active: selectedWorker?.id === worker.id,
            inFence: isWorkerInFence(worker)
          }"
          @click="selectWorker(worker)"
        >
          <div class="worker-avatar" :style="{ background: getWorkerColor(worker.id) }">
            {{ worker.name[0] }}
          </div>
          <div class="worker-info">
            <h4>{{ worker.name }}</h4>
            <div class="worker-tags">
              <el-tag size="small">{{ worker.serviceType }}</el-tag>
              <span class="distance">{{ worker.distance }}km</span>
            </div>
            <div class="worker-meta">
              <el-rate v-model="worker.rating" disabled size="small" />
              <span class="price">¥{{ worker.price }}/小时</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 显示列表按钮 - 当列表隐藏但有筛选结果时显示 -->
    <div class="show-list-btn" v-if="!showWorkerList && hasFiltered && filteredWorkers.length > 0">
      <el-button type="primary" @click="showWorkerList = true">
        <el-icon><List /></el-icon>
        显示家政人员列表 ({{ filteredWorkers.length }})
      </el-button>
    </div>

    <!-- 家政人员详情卡片 -->
    <div class="worker-detail-card" v-if="selectedWorker">
      <div class="card-header" :style="{ background: getWorkerColor(selectedWorker.id) }">
        <div class="header-info">
          <h3>{{ selectedWorker.name }}</h3>
          <el-tag size="small" effect="dark">{{ selectedWorker.serviceType }}</el-tag>
        </div>
        <el-button text @click="selectedWorker = null">
          <el-icon><Close /></el-icon>
        </el-button>
      </div>
      
      <div class="card-body">
        <div class="info-row">
          <span class="label">距离</span>
          <span class="value highlight">{{ selectedWorker.distance }}km</span>
        </div>
        <div class="info-row">
          <span class="label">评分</span>
          <el-rate v-model="selectedWorker.rating" disabled show-score />
        </div>
        <div class="info-row">
          <span class="label">经验</span>
          <span class="value">{{ selectedWorker.experience }}年</span>
        </div>
        <div class="info-row">
          <span class="label">价格</span>
          <span class="value price">¥{{ selectedWorker.price }}/小时</span>
        </div>
        <div class="info-row">
          <span class="label">服务次数</span>
          <span class="value">{{ selectedWorker.serviceCount }}次</span>
        </div>
        <div v-if="fenceCenter" class="info-row">
          <span class="label">围栏状态</span>
          <el-tag :type="isWorkerInFence(selectedWorker) ? 'success' : 'info'" size="small">
            {{ isWorkerInFence(selectedWorker) ? '在围栏内' : '在围栏外' }}
          </el-tag>
        </div>
      </div>

      <div class="card-footer">
        <el-button type="primary" size="large" @click="contactWorker(selectedWorker)">
          联系TA
        </el-button>
        <el-button size="large" @click="bookWorker(selectedWorker)">
          立即预约
        </el-button>
      </div>
    </div>


  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, onUnmounted } from 'vue'
import { Search, Location, Plus, Minus, Refresh, Close, List } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import { getWorkers } from '../../api'

// 百度地图API密钥
const BAIDU_MAP_AK = import.meta.env.VITE_BAIDU_MAP_AK || 'S32mnPt9bygJ8kW0OtyyPfzjTdZXAc3R'

// 筛选表单
const filterForm = ref({
  serviceType: '',
  priceRange: [30, 200],
  minRating: 3,
  radius: 5
})

// 位置搜索
const searchKeyword = ref('')

// 地图实例
let map = null
let markers = []
let searchMarker = null
let circle = null
let fenceCenter = ref(null)
let fenceRadius = ref(1000)
let showFence = ref(false)
let isDrawing = ref(false)

// 附近家政人员
const nearbyWorkers = ref([])

// 从数据库获取家政服务人员
const loadWorkersFromDatabase = async () => {
  try {
    const serviceTypeMap = {
      '保洁服务': 1,
      '月嫂服务': 2,
      '护理服务': 3,
      '钟点工': 4,
      '育儿嫂': 5,
      '家电清洗': 6,
      '管家服务': 7
    }

    const params = { page: 1, pageSize: 50 }
    if (filterForm.value.serviceType && serviceTypeMap[filterForm.value.serviceType]) {
      params.categoryId = serviceTypeMap[filterForm.value.serviceType]
    }

    const result = await getWorkers(params)
    if (result.code === 200 && result.data && result.data.list) {
      let workers = result.data.list

      // 随机选择5-10个家政服务人员
      const randomCount = Math.floor(Math.random() * 6) + 5
      const shuffled = workers.sort(() => 0.5 - Math.random())
      const selectedWorkers = shuffled.slice(0, Math.min(randomCount, workers.length))

      // 为每个家政服务人员添加随机位置信息（衡阳地区）
      const baseLng = 112.595384
      const baseLat = 26.904631

      nearbyWorkers.value = selectedWorkers.map(worker => ({
        id: worker.id,
        name: worker.name,
        serviceType: filterForm.value.serviceType || '保洁服务',
        price: worker.price || 80,
        distance: (Math.random() * 5 + 0.5).toFixed(1),
        rating: worker.rating || 4.5,
        experience: worker.experience || 3,
        serviceCount: Math.floor(Math.random() * 100) + 50,
        lng: baseLng + (Math.random() - 0.5) * 0.03,
        lat: baseLat + (Math.random() - 0.5) * 0.03
      }))
    }
  } catch (error) {
    console.error('加载家政服务人员失败:', error)
    ElMessage.error('加载家政服务人员失败')
  }
}

// 选中的家政人员
const selectedWorker = ref(null)

// 显示家政人员列表
const showWorkerList = ref(false)

// 是否已经进行过筛选
const hasFiltered = ref(false)

// 计算属性
const avgDistance = computed(() => {
  if (nearbyWorkers.value.length === 0) return 0
  const sum = nearbyWorkers.value.reduce((acc, w) => acc + w.distance, 0)
  return Math.round(sum / nearbyWorkers.value.length * 10) / 10
})

const avgPrice = computed(() => {
  if (nearbyWorkers.value.length === 0) return 0
  const sum = nearbyWorkers.value.reduce((acc, w) => acc + w.price, 0)
  return Math.round(sum / nearbyWorkers.value.length)
})

// 过滤后的工人
const filteredWorkers = computed(() => {
  return nearbyWorkers.value.filter(worker => {
    if (worker.price < filterForm.value.priceRange[0] || worker.price > filterForm.value.priceRange[1]) return false
    if (worker.rating < filterForm.value.minRating) return false
    if (worker.distance > filterForm.value.radius) return false
    return true
  })
})

// 围栏内人数
const workersInFence = computed(() => {
  if (!fenceCenter.value || !circle || !window.BMapLib) return 0
  return filteredWorkers.value.filter(worker => {
    try {
      const point = new window.BMap.Point(worker.lng, worker.lat)
      return window.BMapLib.GeoUtils.isPointInCircle(point, circle)
    } catch (e) {
      return false
    }
  }).length
})

// 获取工人颜色
const getWorkerColor = (id) => {
  const colors = ['#FF6B6B', '#4ECDC4', '#95E1D3', '#F38181', '#AA96DA', '#FCBAD3', '#A8E6CF', '#FFD3B6', '#FFAAA5']
  return colors[(id - 1) % colors.length]
}

// 判断工人是否在围栏内
const isWorkerInFence = (worker) => {
  if (!fenceCenter.value || !circle || !window.BMapLib) return false
  try {
    const point = new window.BMap.Point(worker.lng, worker.lat)
    return window.BMapLib.GeoUtils.isPointInCircle(point, circle)
  } catch (e) {
    return false
  }
}

// 应用筛选
const applyFilter = async () => {
  hasFiltered.value = true
  showWorkerList.value = true
  
  // 从数据库加载家政服务人员
  await loadWorkersFromDatabase()
  
  ElMessage.success(`筛选完成，找到 ${nearbyWorkers.value.length} 位家政人员`)
  if (map) {
    updateMarkers()
  }
}

// 更新标记
const updateMarkers = () => {
  if (!map || !window.BMap) return
  
  // 清除现有标记
  markers.forEach(marker => map.removeOverlay(marker))
  markers = []
  
  // 添加标记
  filteredWorkers.value.forEach(worker => {
    try {
      const point = new window.BMap.Point(worker.lng, worker.lat)
      const marker = new window.BMap.Marker(point)
      
      // 创建信息窗口
      const infoWindow = new window.BMap.InfoWindow(`
        <div style="padding: 10px; max-width: 200px;">
          <h4 style="margin:0 0 5px 0; color: #333;">${worker.name}</h4>
          <p style="margin:3px 0; font-size: 12px;">服务类型: ${worker.serviceType}</p>
          <p style="margin:3px 0; font-size: 12px;">价格: ¥${worker.price}/小时</p>
          <p style="margin:3px 0; font-size: 12px;">距离: ${worker.distance}km</p>
          <p style="margin:3px 0; font-size: 12px;">评分: ${worker.rating}分</p>
          <p style="margin:3px 0; font-size: 12px;">经验: ${worker.experience}年</p>
        </div>
      `)
      
      // 添加点击事件
      marker.addEventListener('click', () => {
        marker.openInfoWindow(infoWindow)
        selectedWorker.value = worker
      })
      
      map.addOverlay(marker)
      markers.push(marker)
    } catch (e) {
      console.error('添加标记失败:', e)
    }
  })
  
  // 自动调整视图
  if (filteredWorkers.value.length > 0) {
    try {
      const points = filteredWorkers.value.map(w => new window.BMap.Point(w.lng, w.lat))
      const view = map.getViewport(points)
      map.centerAndZoom(view.center, view.zoom)
    } catch (e) {
      console.error('调整视图失败:', e)
    }
  }
}

// 初始化地图
const initMap = () => {
  console.log('开始初始化地图')
  
  if (!window.BMap || typeof window.BMap.Map === 'undefined') {
    console.warn('BMap 对象不存在或无效，使用降级方案')
    showMapFallback()
    return
  }

  try {
    const mapContainer = document.getElementById('allmap')
    if (!mapContainer) {
      console.error('地图容器不存在')
      return
    }

    // 创建地图实例
    map = new window.BMap.Map('allmap')
    
    // 设置地图中心点（衡阳地区）
    const point = new window.BMap.Point(112.595384, 26.904631)
    map.centerAndZoom(point, 13)
    
    // 启用控件
    map.enableScrollWheelZoom(true)
    map.addControl(new window.BMap.NavigationControl())
    map.addControl(new window.BMap.ScaleControl())
    map.addControl(new window.BMap.MapTypeControl())
    
    console.log('地图初始化成功')
    ElMessage.success('地图加载成功')
    
    // 设置当前城市（可选）
    map.setCurrentCity('衡阳')
    
    // 添加标记
    updateMarkers()
    
    // 添加地图点击事件（用于绘制围栏）
    map.addEventListener('click', (e) => {
      if (isDrawing.value && window.BMapLib) {
        createFence(e.point)
        isDrawing.value = false
      }
    })
    
  } catch (error) {
    console.error('地图初始化失败:', error)
    showMapFallback()
  }
}

// 显示地图降级内容
const showMapFallback = () => {
  console.log('显示地图降级内容')
  // 使用setTimeout确保DOM已经渲染
  setTimeout(() => {
    const mapContainer = document.getElementById('allmap')
    if (mapContainer) {
      mapContainer.innerHTML = `
        <div style="width: 100%; height: 100%; min-height: 500px; display: flex; flex-direction: column; align-items: center; justify-content: center; background: #f5f7fa;">
          <div style="font-size: 48px; margin-bottom: 20px; color: #409EFF;">🗺️</div>
          <h3 style="margin: 0 0 10px 0; color: #333;">地图服务暂时不可用</h3>
          <p style="margin: 0 0 30px 0; color: #666; text-align: center; max-width: 400px;">百度地图API加载失败，您仍然可以查看附近的家政人员列表</p>
          <button style="padding: 10px 20px; background: #409EFF; color: white; border: none; border-radius: 4px; cursor: pointer;" onclick="location.reload()">
            重试加载
          </button>
        </div>
      `
      console.log('降级内容已插入到DOM')
    } else {
      console.error('地图容器不存在')
    }
  }, 100)
  ElMessage.info('地图服务暂时不可用，您仍然可以查看附近的家政人员列表')
}

// 地图加载状态
const mapLoaded = ref(false)
const mapError = ref(false)

// 加载百度地图API
const loadBaiduMapAPI = () => {
  return new Promise((resolve, reject) => {
    // 如果已经加载，直接返回
    if (window.BMap && typeof window.BMap.Map !== 'undefined') {
      console.log('百度地图API已存在')
      mapLoaded.value = true
      resolve(window.BMap)
      return
    }

    // 创建script标签
    const script = document.createElement('script')
    script.type = 'text/javascript'
    script.src = `https://api.map.baidu.com/api?v=3.0&ak=${BAIDU_MAP_AK}&callback=baiduMapInitCallback`
    
    // 设置全局回调
    window.baiduMapInitCallback = () => {
      console.log('百度地图API初始化成功')
      mapLoaded.value = true
      // 加载GeoUtils
      loadGeoUtils().then(() => {
        resolve(window.BMap)
      }).catch(err => {
        console.warn('GeoUtils加载失败，但不影响基础地图功能')
        resolve(window.BMap)
      })
      delete window.baiduMapInitCallback
    }
    
    script.onerror = (error) => {
      console.error('百度地图API脚本加载失败:', error)
      mapError.value = true
      reject(new Error('百度地图API脚本加载失败'))
    }
    
    // 设置超时
    const timeoutId = setTimeout(() => {
      reject(new Error('百度地图API加载超时'))
    }, 10000)
    
    script.onload = () => {
      clearTimeout(timeoutId)
      console.log('百度地图API脚本加载成功')
    }
    
    document.head.appendChild(script)
  })
}

// 加载GeoUtils工具库
const loadGeoUtils = () => {
  return new Promise((resolve, reject) => {
    if (window.BMapLib) {
      console.log('GeoUtils已存在')
      resolve(window.BMapLib)
      return
    }
    
    const script = document.createElement('script')
    script.type = 'text/javascript'
    script.src = 'https://api.map.baidu.com/library/GeoUtils/1.2/src/GeoUtils_min.js'
    
    script.onload = () => {
      console.log('GeoUtils加载成功')
      resolve(window.BMapLib)
    }
    
    script.onerror = (error) => {
      console.error('GeoUtils加载失败:', error)
      reject(error)
    }
    
    document.head.appendChild(script)
  })
}

// 定位到当前位置
const locateMe = () => {
  if (!map) return
  
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        try {
          const point = new window.BMap.Point(position.coords.longitude, position.coords.latitude)
          map.panTo(point)
          map.setZoom(15)
          
          // 添加当前位置标记
          const myIcon = new window.BMap.Icon(
            'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40" fill="none"%3E%3Crect width="40" height="40" rx="20" fill="%23409EFF"/%3E%3Ctext x="20" y="26" font-size="16" font-weight="bold" text-anchor="middle" fill="white"%3E我%3C/text%3E%3C/svg%3E',
            new window.BMap.Size(40, 40)
          )
          const myMarker = new window.BMap.Marker(point, { icon: myIcon })
          map.addOverlay(myMarker)
          
          ElMessage.success('定位成功')
        } catch (e) {
          console.error('定位失败:', e)
          ElMessage.warning('定位失败')
        }
      },
      (error) => {
        console.error('定位失败:', error)
        ElMessage.warning('定位失败，请检查权限设置')
      }
    )
  } else {
    ElMessage.warning('浏览器不支持定位功能')
  }
}

// 搜索位置并定位
const searchLocation = () => {
  if (!map) {
    ElMessage.warning('地图尚未加载完成')
    return
  }

  const keyword = searchKeyword.value.trim()
  if (!keyword) {
    ElMessage.warning('请输入要搜索的位置')
    return
  }

  try {
    const local = new window.BMap.LocalSearch(map, {
      onSearchComplete: (results) => {
        try {
          if (!results || results.getStatus && results.getStatus() !== window.BMAP_STATUS_SUCCESS) {
            ElMessage.warning('未找到相关位置，请尝试输入更准确的名称')
            return
          }

          const poi = results.getPoi(0)
          if (!poi || !poi.point) {
            ElMessage.warning('未找到相关位置，请尝试输入更准确的名称')
            return
          }

          // 清除上一次搜索标记
          if (searchMarker) {
            map.removeOverlay(searchMarker)
          }

          // 添加新的搜索结果标记
          searchMarker = new window.BMap.Marker(poi.point)
          map.addOverlay(searchMarker)

          map.centerAndZoom(poi.point, 15)
          map.panTo(poi.point)

          ElMessage.success(`已定位到：${poi.title}`)
        } catch (e) {
          console.error('处理搜索结果失败:', e)
          ElMessage.error('处理搜索结果失败')
        }
      }
    })

    local.search(keyword)
  } catch (e) {
    console.error('位置搜索失败:', e)
    ElMessage.error('位置搜索失败，请稍后重试')
  }
}

// 缩放控制
const zoomIn = () => {
  map?.zoomIn()
}

const zoomOut = () => {
  map?.zoomOut()
}

const resetView = () => {
  if (map && markers.length > 0) {
    try {
      const points = markers.map(m => m.getPosition())
      const view = map.getViewport(points)
      map.centerAndZoom(view.center, view.zoom)
    } catch (e) {
      console.error('重置视图失败:', e)
    }
  }
}

// 选择家政人员
const selectWorker = (worker) => {
  selectedWorker.value = worker
  if (map) {
    try {
      const point = new window.BMap.Point(worker.lng, worker.lat)
      map.panTo(point)
      map.setZoom(16)
      
      // 打开信息窗口
      const marker = markers.find(m => {
        const pos = m.getPosition()
        return pos.lng === worker.lng && pos.lat === worker.lat
      })
      if (marker) {
        const infoWindow = new window.BMap.InfoWindow(`
          <div style="padding: 10px;">
            <h4 style="margin:0 0 5px 0;">${worker.name}</h4>
            <p style="margin:3px 0;">服务类型: ${worker.serviceType}</p>
            <p style="margin:3px 0;">价格: ¥${worker.price}/小时</p>
          </div>
        `)
        marker.openInfoWindow(infoWindow)
      }
    } catch (e) {
      console.error('定位到工人失败:', e)
    }
  }
}

// 联系家政人员
const contactWorker = (worker) => {
  ElMessage.success(`正在联系 ${worker.name}...`)
}

// 预约服务
const bookWorker = (worker) => {
  ElMessage.success(`正在预约 ${worker.name} 的服务...`)
}

// 切换围栏显示
const toggleFence = () => {
  if (!circle) {
    ElMessage.warning('请先绘制围栏')
    return
  }
  
  showFence.value = !showFence.value
  if (showFence.value) {
    map.addOverlay(circle)
  } else {
    map.removeOverlay(circle)
  }
}

// 开始绘制围栏
const drawFence = () => {
  if (!window.BMapLib) {
    ElMessage.warning('围栏功能初始化中，请稍后再试')
    return
  }
  
  isDrawing.value = true
  ElMessage.info('请在地图上点击选择围栏中心点')
}

// 创建围栏
const createFence = (point) => {
  if (!map) return
  
  try {
    // 移除现有围栏
    if (circle) {
      map.removeOverlay(circle)
    }
    
    // 创建新围栏
    circle = new window.BMap.Circle(point, fenceRadius.value, {
      fillColor: "#409EFF",
      strokeWeight: 2,
      fillOpacity: 0.2,
      strokeOpacity: 0.8,
      strokeColor: "#409EFF"
    })
    
    map.addOverlay(circle)
    fenceCenter.value = {
      lng: point.lng,
      lat: point.lat
    }
    showFence.value = true
    
    ElMessage.success('围栏创建成功')
  } catch (e) {
    console.error('创建围栏失败:', e)
    ElMessage.error('创建围栏失败')
  }
}



onMounted(async () => {
  try {
    // 加载百度地图API
    await loadBaiduMapAPI()
    // 初始化地图
    nextTick(() => {
      initMap()
    })
    // 从数据库加载家政服务人员
    await loadWorkersFromDatabase()
  } catch (error) {
    console.error('百度地图API加载失败:', error)
  }
})

onUnmounted(() => {
  // 清理地图实例
  if (map) {
    map = null
  }
})
</script>

<style scoped>
.service-map-page {
  max-width: 1600px;
  margin: 0 auto;
  padding: 40px 20px;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-header h1 {
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 10px;
  color: #333;
}

.page-header p {
  font-size: 16px;
  color: #666;
  margin: 0;
}

.map-container {
  display: flex;
  gap: 20px;
  margin-bottom: 40px;
  height: 600px;
}

.filter-panel {
  width: 300px;
  background: white;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  overflow-y: auto;
}

.filter-panel h2 {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 20px;
  color: #333;
}

.price-labels {
  display: flex;
  justify-content: space-between;
  margin-top: 10px;
  font-size: 12px;
  color: #666;
}

.fence-control {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #ebeef5;
}

.fence-control h3 {
  font-size: 16px;
  margin-bottom: 15px;
  color: #333;
}

.fence-actions {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
}

.fence-info {
  background: #f5f7fa;
  padding: 10px;
  border-radius: 8px;
  font-size: 13px;
}

.fence-info p {
  margin: 5px 0;
  color: #666;
}

.stats-section {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #ebeef5;
}

.stats-section h3 {
  font-size: 16px;
  margin-bottom: 15px;
  color: #333;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  font-size: 14px;
}

.stat-label {
  color: #666;
}

.stat-value {
  font-weight: bold;
  color: #409EFF;
}

.map-wrapper {
  flex: 1;
  position: relative;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.baidu-map {
  width: 100%;
  height: 100%;
  min-height: 500px;
}

.map-controls {
  position: absolute;
  top: 20px;
  right: 20px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  z-index: 100;
}

.search-location-icon {
  cursor: pointer;
}

.draw-hint {
  position: absolute;
  top: 20px;
  left: 50%;
  transform: translateX(-50%);
  width: 300px;
  z-index: 100;
}

.worker-list-float {
  position: fixed;
  left: 340px;
  top: 180px;
  width: 300px;
  max-height: 500px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.float-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #ebeef5;
}

.float-header h3 {
  font-size: 16px;
  margin: 0;
  color: #333;
}

.float-content {
  overflow-y: auto;
  max-height: 440px;
}

.worker-list-item {
  display: flex;
  gap: 12px;
  padding: 12px 20px;
  cursor: pointer;
  transition: all 0.3s;
  border-bottom: 1px solid #f0f0f0;
}

.worker-list-item:hover {
  background: #f5f7fa;
}

.worker-list-item.active {
  background: #ecf5ff;
}

.worker-list-item.inFence {
  border-left: 3px solid #67C23A;
}

.worker-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 20px;
  font-weight: bold;
  flex-shrink: 0;
}

.worker-info {
  flex: 1;
  min-width: 0;
}

.worker-info h4 {
  font-size: 15px;
  margin: 0 0 5px 0;
  color: #333;
}

.worker-tags {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 5px;
}

.distance {
  font-size: 12px;
  color: #67C23A;
  font-weight: 600;
}

.worker-meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.price {
  font-size: 13px;
  color: #f56c6c;
  font-weight: 600;
}

.show-list-btn {
  position: fixed;
  left: 340px;
  bottom: 20px;
  z-index: 999;
}

.worker-detail-card {
  position: fixed;
  right: 20px;
  bottom: 20px;
  width: 320px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  overflow: hidden;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  color: white;
}

.header-info h3 {
  font-size: 18px;
  margin: 0 0 8px 0;
}

.card-body {
  padding: 20px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
}

.info-row:last-child {
  border-bottom: none;
}

.info-row .label {
  color: #666;
  font-size: 14px;
}

.info-row .value {
  color: #333;
  font-weight: 600;
}

.info-row .value.highlight {
  color: #67C23A;
  font-size: 16px;
}

.info-row .value.price {
  color: #f56c6c;
}

.card-footer {
  display: flex;
  gap: 10px;
  padding: 16px 20px;
  background: #f5f7fa;
}

.card-footer .el-button {
  flex: 1;
}

@media (max-width: 1200px) {
  .map-container {
    flex-direction: column;
    height: auto;
  }
  
  .filter-panel {
    width: 100%;
  }
  
  .map-wrapper {
    height: 500px;
  }
  
  .worker-list-float {
    left: 20px;
    top: auto;
    bottom: 100px;
    width: calc(100% - 40px);
  }
}

@media (max-width: 768px) {
  .worker-detail-card {
    width: calc(100% - 40px);
    left: 20px;
    right: 20px;
  }
}
</style>
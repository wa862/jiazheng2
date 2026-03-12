<template>
  <admin-layout>
    <div class="user-behavior-page">
      <div class="page-header">
        <h1>用户行为分析</h1>
        <p>深入了解用户行为和偏好</p>
      </div>

      <!-- 行为指标卡片 -->
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in behaviorStats" :key="stat.key">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" :style="{ background: stat.gradient }">
                <el-icon :size="32" color="white">
                  <component :is="stat.icon" />
                </el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">{{ stat.label }}</p>
                <p class="stat-value">{{ stat.value }}</p>
                <p class="stat-trend" :class="stat.trend > 0 ? 'up' : 'down'">
                  <el-icon><TrendCharts /></el-icon>
                  {{ stat.trend > 0 ? '+' : '' }}{{ stat.trend }}%
                </p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 用户活跃度趋势和访问来源 -->
      <el-row :gutter="20" style="margin-top: 20px;">
        <el-col :span="16">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>用户活跃度趋势</h3>
                <el-radio-group v-model="activityPeriod" size="small">
                  <el-radio-button label="week">本周</el-radio-button>
                  <el-radio-button label="month">本月</el-radio-button>
                  <el-radio-button label="year">本年</el-radio-button>
                </el-radio-group>
              </div>
            </template>
            <div ref="activityChartRef" class="chart-container"></div>
          </el-card>
        </el-col>

        <el-col :span="8">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>访问来源分布</h3>
              </div>
            </template>
            <div ref="sourceChartRef" class="chart-container"></div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 用户留存率和行为路径 -->
      <el-row :gutter="20" style="margin-top: 20px;">
        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>用户留存率</h3>
              </div>
            </template>
            <div ref="retentionChartRef" class="chart-container"></div>
          </el-card>
        </el-col>

        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>用户行为路径</h3>
              </div>
            </template>
            <div ref="funnelChartRef" class="chart-container"></div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 热门搜索词和点击热力图 -->
      <el-row :gutter="20" style="margin-top: 20px;">
        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>热门搜索词 TOP10</h3>
              </div>
            </template>
            <div ref="searchChartRef" class="chart-container"></div>
          </el-card>
        </el-col>

        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>页面点击热力</h3>
              </div>
            </template>
            <div ref="heatmapChartRef" class="chart-container"></div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 用户分群表格 -->
      <el-card class="table-card" style="margin-top: 20px;">
        <template #header>
          <div class="table-header">
            <h3>用户分群分析</h3>
          </div>
        </template>

        <el-table :data="userSegments" style="width: 100%" v-loading="loading">
          <el-table-column prop="segmentName" label="用户群体" min-width="150">
            <template #default="{ row }">
              <div class="segment-info">
                <el-tag :type="row.tagType" size="small">{{ row.segmentName }}</el-tag>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="userCount" label="用户数" width="120">
            <template #default="{ row }">
              <span class="count">{{ row.userCount.toLocaleString() }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="percentage" label="占比" width="150">
            <template #default="{ row }">
              <el-progress :percentage="row.percentage" :color="row.progressColor" />
            </template>
          </el-table-column>
          <el-table-column prop="avgOrders" label="平均订单数" width="120" />
          <el-table-column prop="avgSpending" label="平均消费" width="120">
            <template #default="{ row }">
              ¥{{ row.avgSpending }}
            </template>
          </el-table-column>
          <el-table-column prop="retentionRate" label="留存率" width="120">
            <template #default="{ row }">
              {{ row.retentionRate }}%
            </template>
          </el-table-column>
          <el-table-column prop="characteristics" label="特征描述" min-width="200">
            <template #default="{ row }">
              <span class="characteristics">{{ row.characteristics }}</span>
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import AdminLayout from '@/components/AdminLayout.vue'
import {
  User,
  View,
  Mouse,
  Timer,
  TrendCharts
} from '@element-plus/icons-vue'

// 行为统计数据
const behaviorStats = ref([
  {
    key: 'dau',
    label: '日活跃用户',
    value: '12,458',
    trend: 8.5,
    icon: User,
    gradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
  },
  {
    key: 'pv',
    label: '页面浏览量',
    value: '89,234',
    trend: 12.3,
    icon: View,
    gradient: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)'
  },
  {
    key: 'ctr',
    label: '平均点击率',
    value: '23.8%',
    trend: -2.1,
    icon: Mouse,
    gradient: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)'
  },
  {
    key: 'avgTime',
    label: '平均停留时长',
    value: '8分32秒',
    trend: 5.7,
    icon: Timer,
    gradient: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)'
  }
])

// 图表相关
const activityPeriod = ref('week')
const activityChartRef = ref(null)
const sourceChartRef = ref(null)
const retentionChartRef = ref(null)
const funnelChartRef = ref(null)
const searchChartRef = ref(null)
const heatmapChartRef = ref(null)

let activityChart = null
let sourceChart = null
let retentionChart = null
let funnelChart = null
let searchChart = null
let heatmapChart = null

// 表格相关
const loading = ref(false)

// 用户分群数据
const userSegments = ref([
  {
    segmentName: '高价值用户',
    tagType: 'danger',
    userCount: 2456,
    percentage: 12.5,
    progressColor: '#f56c6c',
    avgOrders: 15.8,
    avgSpending: 3850,
    retentionRate: 85.2,
    characteristics: '高频消费，偏好高端服务，对价格不敏感'
  },
  {
    segmentName: '活跃用户',
    tagType: 'success',
    userCount: 5890,
    percentage: 30.2,
    progressColor: '#67c23a',
    avgOrders: 8.5,
    avgSpending: 1680,
    retentionRate: 72.8,
    characteristics: '定期使用平台，对服务品质有要求'
  },
  {
    segmentName: '潜力用户',
    tagType: 'warning',
    userCount: 4234,
    percentage: 21.7,
    progressColor: '#e6a23c',
    avgOrders: 3.2,
    avgSpending: 650,
    retentionRate: 45.6,
    characteristics: '注册时间较短，消费频次在提升中'
  },
  {
    segmentName: '沉睡用户',
    tagType: 'info',
    userCount: 3456,
    percentage: 17.7,
    progressColor: '#909399',
    avgOrders: 1.8,
    avgSpending: 320,
    retentionRate: 15.2,
    characteristics: '超过30天未登录，需要唤醒策略'
  },
  {
    segmentName: '新用户',
    tagType: 'primary',
    userCount: 3456,
    percentage: 17.7,
    progressColor: '#409eff',
    avgOrders: 1.2,
    avgSpending: 280,
    retentionRate: 35.8,
    characteristics: '注册7天内，处于体验期'
  }
])

// 按周期获取用户活跃度数据
const getActivityChartData = (period) => {
  if (period === 'week') {
    return {
      x: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
      active: [12000, 13200, 10100, 13400, 9000, 23000, 21000],
      newUser: [2200, 1820, 1910, 2340, 2900, 3300, 3100],
      returnUser: [9800, 11380, 8190, 11060, 6100, 19700, 17900]
    }
  }
  if (period === 'month') {
    const x = [], active = [], newUser = [], returnUser = []
    for (let i = 1; i <= 30; i++) {
      x.push(i + '日')
      active.push(10000 + Math.floor(Math.random() * 14000))
      newUser.push(1800 + Math.floor(Math.random() * 1600))
      returnUser.push(6000 + Math.floor(Math.random() * 14000))
    }
    return { x, active, newUser, returnUser }
  }
  return {
    x: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
    active: [120000, 132000, 101000, 134000, 125000, 142000, 138000, 145000, 152000, 148000, 155000, 160000],
    newUser: [22000, 18200, 19100, 23400, 29000, 33000, 31000, 32800, 35200, 34100, 36800, 38500],
    returnUser: [98000, 113800, 81900, 110600, 96000, 109000, 107000, 112200, 116800, 113900, 118200, 121500]
  }
}

const updateActivityChart = () => {
  if (!activityChart) return
  const { x, active, newUser, returnUser } = getActivityChartData(activityPeriod.value)
  activityChart.setOption({
    xAxis: { data: x },
    series: [
      { data: active },
      { data: newUser },
      { data: returnUser }
    ]
  })
}

// 初始化用户活跃度图表
const initActivityChart = () => {
  if (!activityChartRef.value) return
  
  activityChart = echarts.init(activityChartRef.value)
  const data = getActivityChartData(activityPeriod.value)
  const option = {
    tooltip: { trigger: 'axis' },
    legend: { data: ['活跃用户', '新增用户', '回访用户'], bottom: 0 },
    grid: { left: '3%', right: '4%', bottom: '15%', top: '10%', containLabel: true },
    xAxis: {
      type: 'category',
      data: data.x,
      axisLine: { lineStyle: { color: '#E0E6F1' } },
      axisLabel: { color: '#666' }
    },
    yAxis: {
      type: 'value',
      axisLine: { show: false },
      axisTick: { show: false },
      splitLine: { lineStyle: { color: '#E0E6F1', type: 'dashed' } },
      axisLabel: { color: '#666' }
    },
    series: [
      {
        name: '活跃用户',
        type: 'line',
        smooth: true,
        data: data.active,
        itemStyle: { color: '#409EFF' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(64, 158, 255, 0.3)' },
            { offset: 1, color: 'rgba(64, 158, 255, 0.05)' }
          ])
        }
      },
      {
        name: '新增用户',
        type: 'line',
        smooth: true,
        data: data.newUser,
        itemStyle: { color: '#67C23A' }
      },
      {
        name: '回访用户',
        type: 'line',
        smooth: true,
        data: data.returnUser,
        itemStyle: { color: '#E6A23C' }
      }
    ]
  }
  activityChart.setOption(option)
}

watch(activityPeriod, () => {
  updateActivityChart()
})

// 初始化访问来源图表
const initSourceChart = () => {
  if (!sourceChartRef.value) return
  
  sourceChart = echarts.init(sourceChartRef.value)
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      right: '5%',
      top: 'center'
    },
    series: [
      {
        type: 'pie',
        radius: ['40%', '70%'],
        center: ['35%', '50%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: false
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 14,
            fontWeight: 'bold'
          }
        },
        data: [
          { value: 4500, name: '直接访问', itemStyle: { color: '#409EFF' } },
          { value: 3200, name: '搜索引擎', itemStyle: { color: '#67C23A' } },
          { value: 2800, name: '社交媒体', itemStyle: { color: '#E6A23C' } },
          { value: 1800, name: '外部链接', itemStyle: { color: '#F56C6C' } },
          { value: 1200, name: '邮件营销', itemStyle: { color: '#909399' } }
        ]
      }
    ]
  }
  sourceChart.setOption(option)
}

// 初始化用户留存率图表
const initRetentionChart = () => {
  if (!retentionChartRef.value) return
  
  retentionChart = echarts.init(retentionChartRef.value)
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      top: '10%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: ['次日', '3日', '7日', '14日', '30日', '60日', '90日']
    },
    yAxis: {
      type: 'value',
      axisLabel: {
        formatter: '{value}%'
      }
    },
    series: [
      {
        type: 'bar',
        data: [
          { value: 65, itemStyle: { color: '#409EFF' } },
          { value: 52, itemStyle: { color: '#67C23A' } },
          { value: 45, itemStyle: { color: '#E6A23C' } },
          { value: 38, itemStyle: { color: '#F56C6C' } },
          { value: 32, itemStyle: { color: '#909399' } },
          { value: 28, itemStyle: { color: '#8B5CF6' } },
          { value: 25, itemStyle: { color: '#14B8A6' } }
        ],
        barWidth: '50%',
        itemStyle: {
          borderRadius: [8, 8, 0, 0]
        }
      }
    ]
  }
  retentionChart.setOption(option)
}

// 初始化用户行为路径图表
const initFunnelChart = () => {
  if (!funnelChartRef.value) return
  
  funnelChart = echarts.init(funnelChartRef.value)
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)'
    },
    series: [
      {
        type: 'funnel',
        left: '10%',
        top: 20,
        bottom: 20,
        width: '80%',
        min: 0,
        max: 100,
        minSize: '0%',
        maxSize: '100%',
        sort: 'descending',
        gap: 2,
        label: {
          show: true,
          position: 'inside'
        },
        labelLine: {
          length: 10,
          lineStyle: {
            width: 1,
            type: 'solid'
          }
        },
        itemStyle: {
          borderColor: '#fff',
          borderWidth: 1
        },
        emphasis: {
          label: {
            fontSize: 20
          }
        },
        data: [
          { value: 100, name: '访问首页', itemStyle: { color: '#409EFF' } },
          { value: 80, name: '浏览服务', itemStyle: { color: '#67C23A' } },
          { value: 60, name: '查看详情', itemStyle: { color: '#E6A23C' } },
          { value: 40, name: '发起预约', itemStyle: { color: '#F56C6C' } },
          { value: 25, name: '完成支付', itemStyle: { color: '#909399' } }
        ]
      }
    ]
  }
  funnelChart.setOption(option)
}

// 初始化热门搜索词图表
const initSearchChart = () => {
  if (!searchChartRef.value) return
  
  searchChart = echarts.init(searchChartRef.value)
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      top: '5%',
      containLabel: true
    },
    xAxis: {
      type: 'value',
      axisLabel: {
        formatter: '{value}次'
      }
    },
    yAxis: {
      type: 'category',
      data: ['深度保洁', '月嫂', '钟点工', '育儿嫂', '老人护理', '家电清洗', '搬家', '管道疏通', '开锁', '保姆'],
      axisLabel: {
        fontSize: 12
      }
    },
    series: [
      {
        type: 'bar',
        data: [3200, 2800, 2500, 2200, 1800, 1500, 1200, 900, 700, 500],
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
            { offset: 0, color: '#409EFF' },
            { offset: 1, color: '#64B5F6' }
          ]),
          borderRadius: [0, 8, 8, 0]
        },
        barWidth: '60%'
      }
    ]
  }
  searchChart.setOption(option)
}

// 初始化页面点击热力图
const initHeatmapChart = () => {
  if (!heatmapChartRef.value) return
  
  heatmapChart = echarts.init(heatmapChartRef.value)
  
  // 生成模拟热力图数据
  const hours = ['首页', '服务', '详情', '预约', '支付', '订单', '个人中心', '搜索']
  const days = ['按钮A', '按钮B', '按钮C', '按钮D', '按钮E', '按钮F', '按钮G', '按钮H']
  
  const data = []
  for (let i = 0; i < hours.length; i++) {
    for (let j = 0; j < days.length; j++) {
      data.push([i, j, Math.floor(Math.random() * 100)])
    }
  }
  
  const option = {
    tooltip: {
      position: 'top'
    },
    grid: {
      height: '70%',
      top: '10%'
    },
    xAxis: {
      type: 'category',
      data: hours,
      splitArea: {
        show: true
      }
    },
    yAxis: {
      type: 'category',
      data: days,
      splitArea: {
        show: true
      }
    },
    visualMap: {
      min: 0,
      max: 100,
      calculable: true,
      orient: 'horizontal',
      left: 'center',
      bottom: '5%',
      inRange: {
        color: ['#E3F2FD', '#1976D2']
      }
    },
    series: [{
      type: 'heatmap',
      data: data,
      label: {
        show: true
      },
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      }
    }]
  }
  heatmapChart.setOption(option)
}

// 窗口大小改变时重新渲染图表
const handleResize = () => {
  activityChart?.resize()
  sourceChart?.resize()
  retentionChart?.resize()
  funnelChart?.resize()
  searchChart?.resize()
  heatmapChart?.resize()
}

onMounted(() => {
  nextTick(() => {
    initActivityChart()
    initSourceChart()
    initRetentionChart()
    initFunnelChart()
    initSearchChart()
    initHeatmapChart()
  })
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  activityChart?.dispose()
  sourceChart?.dispose()
  retentionChart?.dispose()
  funnelChart?.dispose()
  searchChart?.dispose()
  heatmapChart?.dispose()
})
</script>

<style scoped lang="scss">
.user-behavior-page {
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

.stat-card {
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  }

  .stat-content {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .stat-icon {
    width: 64px;
    height: 64px;
    border-radius: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .stat-info {
    flex: 1;

    .stat-label {
      font-size: 14px;
      color: #6b7280;
      margin: 0 0 8px 0;
    }

    .stat-value {
      font-size: 24px;
      font-weight: 700;
      color: #1f2937;
      margin: 0 0 8px 0;
    }

    .stat-trend {
      font-size: 13px;
      margin: 0;
      display: flex;
      align-items: center;
      gap: 4px;

      &.up {
        color: #67c23a;
      }

      &.down {
        color: #f56c6c;
      }
    }
  }
}

.chart-card {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;

    h3 {
      font-size: 16px;
      font-weight: 600;
      color: #1f2937;
      margin: 0;
    }
  }

  .chart-container {
    height: 350px;
  }
}

.table-card {
  .table-header {
    display: flex;
    justify-content: space-between;
    align-items: center;

    h3 {
      font-size: 16px;
      font-weight: 600;
      color: #1f2937;
      margin: 0;
    }
  }

  .segment-info {
    display: flex;
    align-items: center;
  }

  .count {
    font-weight: 600;
    color: #1f2937;
  }

  .characteristics {
    color: #6b7280;
    font-size: 13px;
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

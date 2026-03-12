<template>
  <admin-layout>
    <div class="dashboard-page">
      <div class="page-header">
        <h1>数据看板</h1>
        <p>实时监控平台运营数据</p>
      </div>

      <div class="statistics-cards">
        <el-card class="stat-card" v-for="stat in statisticsList" :key="stat.key">
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
      </div>

      <div class="charts-row">
        <el-card class="chart-card large">
          <template #header>
            <div class="card-header">
              <h3>订单趋势</h3>
              <div class="header-actions">
                <el-radio-group v-model="trendPeriod" size="small">
                  <el-radio-button label="week">本周</el-radio-button>
                  <el-radio-button label="month">本月</el-radio-button>
                  <el-radio-button label="year">本年</el-radio-button>
                </el-radio-group>
              </div>
            </div>
          </template>
          <div ref="trendChartRef" class="chart-container"></div>
        </el-card>

        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <h3>服务分类占比</h3>
            </div>
          </template>
          <div ref="pieChartRef" class="chart-container"></div>
        </el-card>
      </div>

      <div class="charts-row">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <h3>用户增长趋势</h3>
            </div>
          </template>
          <div ref="userTrendChartRef" class="chart-container"></div>
        </el-card>

        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <h3>家政人员评分分布</h3>
            </div>
          </template>
          <div ref="ratingChartRef" class="chart-container"></div>
        </el-card>

        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <h3>收入构成</h3>
            </div>
          </template>
          <div ref="revenueChartRef" class="chart-container"></div>
        </el-card>
      </div>

      <div class="bottom-section">
        <el-card class="recent-orders">
          <template #header>
            <div class="card-header">
              <h3>最新订单</h3>
              <el-button text type="primary" @click="$router.push('/admin/orders')">
                查看全部
              </el-button>
            </div>
          </template>
          <el-table :data="recentOrders" style="width: 100%">
            <el-table-column prop="orderNo" label="订单号" width="180" />
            <el-table-column prop="userName" label="用户" />
            <el-table-column prop="workerName" label="家政人员" />
            <el-table-column prop="serviceType" label="服务类型" />
            <el-table-column prop="amount" label="金额">
              <template #default="{ row }">
                ¥{{ row.amount }}
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态">
              <template #default="{ row }">
                <el-tag :type="getStatusType(row.status)">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createTime" label="下单时间" width="180" />
          </el-table>
        </el-card>
      </div>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import AdminLayout from '@components/AdminLayout.vue'
import {
  Document, User, UserFilled, Money, TrendCharts
} from '@element-plus/icons-vue'

const router = useRouter()

// 统计数据
const statisticsList = ref([
  {
    key: 'orders',
    label: '今日订单',
    value: '156',
    trend: 12.5,
    gradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    icon: 'Document'
  },
  {
    key: 'users',
    label: '总用户数',
    value: '2,845',
    trend: 8.3,
    gradient: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    icon: 'User'
  },
  {
    key: 'workers',
    label: '家政人员',
    value: '128',
    trend: 5.2,
    gradient: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    icon: 'UserFilled'
  },
  {
    key: 'revenue',
    label: '平台收入',
    value: '¥45,680',
    trend: 15.8,
    gradient: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
    icon: 'Money'
  }
])

// 图表周期
const trendPeriod = ref('week')

// 图表引用
const trendChartRef = ref(null)
const pieChartRef = ref(null)
const userTrendChartRef = ref(null)
const ratingChartRef = ref(null)
const revenueChartRef = ref(null)

let charts = {}

// 最新订单
const recentOrders = ref([
  { orderNo: 'ORD20240227001', userName: '张三', workerName: '王阿姨', serviceType: '保洁服务', amount: 120, status: '已完成', createTime: '2024-02-27 14:30' },
  { orderNo: 'ORD20240227002', userName: '李四', workerName: '李师傅', serviceType: '月嫂服务', amount: 800, status: '进行中', createTime: '2024-02-27 13:15' },
  { orderNo: 'ORD20240227003', userName: '王五', workerName: '张阿姨', serviceType: '护理服务', amount: 200, status: '待接单', createTime: '2024-02-27 12:00' },
  { orderNo: 'ORD20240227004', userName: '赵六', workerName: '陈师傅', serviceType: '钟点工', amount: 80, status: '已完成', createTime: '2024-02-27 10:45' },
  { orderNo: 'ORD20240227005', userName: '钱七', workerName: '刘阿姨', serviceType: '育儿嫂', amount: 350, status: '进行中', createTime: '2024-02-27 09:30' }
])

const getStatusType = (status) => {
  const types = {
    '已完成': 'success',
    '进行中': 'primary',
    '待接单': 'warning',
    '已取消': 'danger'
  }
  return types[status] || 'info'
}

// 按周期获取订单趋势图数据（用于图表与导出）
const getTrendDataByPeriod = (period) => {
  if (period === 'week') {
    return {
      xAxis: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
      orderData: [120, 132, 101, 134, 90, 230, 210],
      revenueData: [2200, 1820, 1910, 2340, 2900, 3300, 3100]
    }
  }
  if (period === 'month') {
    const days = []
    const orderData = []
    const revenueData = []
    for (let i = 1; i <= 30; i++) {
      days.push(i + '日')
      orderData.push(80 + Math.floor(Math.random() * 120))
      revenueData.push(1500 + Math.floor(Math.random() * 2500))
    }
    return { xAxis: days, orderData, revenueData }
  }
  // year: 12个月
  return {
    xAxis: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
    orderData: [3200, 3100, 3350, 3480, 3620, 3780, 3920, 3850, 4100, 4280, 4350, 4520],
    revenueData: [82000, 93200, 90100, 93400, 129000, 133000, 132000, 145000, 152000, 148000, 155000, 160000]
  }
}

const updateTrendChart = () => {
  if (!charts.trend || !trendChartRef.value) return
  const { xAxis, orderData, revenueData } = getTrendDataByPeriod(trendPeriod.value)
  charts.trend.setOption({
    xAxis: { type: 'category', data: xAxis },
    series: [
      { data: orderData },
      { data: revenueData }
    ]
  })
}

watch(trendPeriod, () => {
  updateTrendChart()
})

// 初始化图表
const initCharts = () => {
  // 订单趋势图
  charts.trend = echarts.init(trendChartRef.value)
  charts.trend.setOption({
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(255, 255, 255, 0.95)',
      borderColor: '#eee',
      borderWidth: 1
    },
    legend: { data: ['订单数', '收入'] },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: {
      type: 'category',
      data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    },
    yAxis: [
      { type: 'value', name: '订单数' },
      { type: 'value', name: '收入' }
    ],
    series: [
      {
        name: '订单数',
        type: 'line',
        smooth: true,
        data: [120, 132, 101, 134, 90, 230, 210],
        itemStyle: { color: '#409EFF' },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(64, 158, 255, 0.3)' },
              { offset: 1, color: 'rgba(64, 158, 255, 0.05)' }
            ]
          }
        }
      },
      {
        name: '收入',
        type: 'line',
        smooth: true,
        yAxisIndex: 1,
        data: [2200, 1820, 1910, 2340, 2900, 3300, 3100],
        itemStyle: { color: '#67C23A' },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(103, 194, 58, 0.3)' },
              { offset: 1, color: 'rgba(103, 194, 58, 0.05)' }
            ]
          }
        }
      }
    ]
  })

  // 服务分类饼图
  charts.pie = echarts.init(pieChartRef.value)
  charts.pie.setOption({
    tooltip: { trigger: 'item', formatter: '{a} <br/>{b}: {c} ({d}%)' },
    legend: { orient: 'vertical', left: 'left' },
    series: [{
      name: '服务分类',
      type: 'pie',
      radius: ['40%', '70%'],
      avoidLabelOverlap: false,
      itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
      label: { show: false, position: 'center' },
      emphasis: {
        label: { show: true, fontSize: 20, fontWeight: 'bold' }
      },
      data: [
        { value: 335, name: '保洁服务', itemStyle: { color: '#409EFF' } },
        { value: 210, name: '月嫂服务', itemStyle: { color: '#67C23A' } },
        { value: 148, name: '护理服务', itemStyle: { color: '#E6A23C' } },
        { value: 128, name: '钟点工', itemStyle: { color: '#F56C6C' } },
        { value: 96, name: '育儿嫂', itemStyle: { color: '#909399' } }
      ]
    }]
  })

  // 用户增长趋势
  charts.userTrend = echarts.init(userTrendChartRef.value)
  charts.userTrend.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: {
      type: 'category',
      data: ['1月', '2月', '3月', '4月', '5月', '6月']
    },
    yAxis: { type: 'value' },
    series: [{
      data: [820, 932, 1101, 1234, 1390, 1550],
      type: 'bar',
      itemStyle: {
        color: {
          type: 'linear',
          x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [
            { offset: 0, color: '#83bff6' },
            { offset: 0.5, color: '#188df0' },
            { offset: 1, color: '#188df0' }
          ]
        }
      }
    }]
  })

  // 评分分布
  charts.rating = echarts.init(ratingChartRef.value)
  charts.rating.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    xAxis: { type: 'category', data: ['5分', '4分', '3分', '2分', '1分'] },
    yAxis: { type: 'value' },
    series: [{
      data: [120, 80, 30, 10, 5],
      type: 'bar',
      itemStyle: {
        color: (params) => {
          const colors = ['#67C23A', '#95D475', '#E6A23C', '#F89898', '#F56C6C']
          return colors[params.dataIndex]
        }
      }
    }]
  })

  // 收入构成
  charts.revenue = echarts.init(revenueChartRef.value)
  charts.revenue.setOption({
    tooltip: { trigger: 'item' },
    series: [{
      name: '收入构成',
      type: 'pie',
      radius: '70%',
      data: [
        { value: 4500, name: '保洁服务' },
        { value: 3200, name: '月嫂服务' },
        { value: 2800, name: '护理服务' },
        { value: 2100, name: '钟点工' },
        { value: 1800, name: '育儿嫂' }
      ],
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      }
    }]
  })
}

onMounted(() => {
  initCharts()
  updateTrendChart()
  window.addEventListener('resize', () => {
    Object.values(charts).forEach(chart => chart && chart.resize())
  })
})

onBeforeUnmount(() => {
  Object.values(charts).forEach(chart => chart && chart.dispose())
})
</script>

<style scoped>
.dashboard-page {
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

.statistics-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 24px;
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
  width: 64px;
  height: 64px;
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
  font-size: 28px;
  font-weight: 700;
  color: #303133;
  margin-bottom: 8px;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
}

.stat-trend.up {
  color: #67C23A;
}

.stat-trend.down {
  color: #F56C6C;
}

.charts-row {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}

.charts-row:last-of-type {
  grid-template-columns: repeat(3, 1fr);
}

.chart-card {
  background: white;
}

.chart-card.large {
  grid-row: span 1;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h3 {
  font-size: 16px;
  color: #303133;
  margin: 0;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.chart-container {
  height: 350px;
}

.bottom-section {
  margin-top: 20px;
}

@media (max-width: 1200px) {
  .statistics-cards {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .charts-row,
  .charts-row:last-of-type {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .statistics-cards {
    grid-template-columns: 1fr;
  }
}
</style>

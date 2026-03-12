<template>
  <admin-layout>
    <div class="statistics-page">
      <div class="page-header">
        <h1>运营数据</h1>
        <p>详细的数据分析和统计报表</p>
      </div>

      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in statisticsList" :key="stat.key">
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
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="20" style="margin-top: 20px;">
        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>订单趋势分析</h3>
                <el-radio-group v-model="orderTrendPeriod" size="small">
                  <el-radio-button label="week">本周</el-radio-button>
                  <el-radio-button label="month">本月</el-radio-button>
                  <el-radio-button label="year">本年</el-radio-button>
                </el-radio-group>
              </div>
            </template>
            <div ref="orderTrendChartRef" class="chart-container"></div>
          </el-card>
        </el-col>

        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>收入趋势分析</h3>
                <el-radio-group v-model="revenueTrendPeriod" size="small">
                  <el-radio-button label="week">本周</el-radio-button>
                  <el-radio-button label="month">本月</el-radio-button>
                  <el-radio-button label="year">本年</el-radio-button>
                </el-radio-group>
              </div>
            </template>
            <div ref="revenueTrendChartRef" class="chart-container"></div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="20" style="margin-top: 20px;">
        <el-col :span="8">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>用户来源分布</h3>
              </div>
            </template>
            <div ref="userSourceChartRef" class="chart-container"></div>
          </el-card>
        </el-col>

        <el-col :span="8">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>服务类型占比</h3>
              </div>
            </template>
            <div ref="serviceTypeChartRef" class="chart-container"></div>
          </el-card>
        </el-col>

        <el-col :span="8">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>订单状态分布</h3>
              </div>
            </template>
            <div ref="orderStatusChartRef" class="chart-container"></div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="20" style="margin-top: 20px;">
        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>用户增长趋势</h3>
              </div>
            </template>
            <div ref="userGrowthChartRef" class="chart-container"></div>
          </el-card>
        </el-col>

        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>活跃时间段分布</h3>
              </div>
            </template>
            <div ref="activeTimeChartRef" class="chart-container"></div>
          </el-card>
        </el-col>
      </el-row>

      <el-card class="data-table-card" style="margin-top: 20px;">
        <template #header>
          <div class="card-header">
            <h3>数据明细</h3>
            <el-button type="primary" size="small" @click="handleExport">
              <el-icon><Download /></el-icon>
              导出数据
            </el-button>
          </div>
        </template>
        <el-table :data="tableData" style="width: 100%">
          <el-table-column prop="date" label="日期" width="120" />
          <el-table-column prop="orders" label="订单数" />
          <el-table-column prop="revenue" label="收入">
            <template #default="{ row }">
              ¥{{ row.revenue }}
            </template>
          </el-table-column>
          <el-table-column prop="newUsers" label="新增用户" />
          <el-table-column prop="activeUsers" label="活跃用户" />
          <el-table-column prop="conversionRate" label="转化率">
            <template #default="{ row }">
              {{ row.conversionRate }}%
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import * as XLSX from 'xlsx'
import { Document, Money, User, TrendCharts, Download } from '@element-plus/icons-vue'
import AdminLayout from '@components/AdminLayout.vue'

const orderTrendPeriod = ref('week')
const revenueTrendPeriod = ref('week')

const statisticsList = ref([
  {
    key: 'orders',
    label: '总订单数',
    value: '12,580',
    gradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    icon: 'Document'
  },
  {
    key: 'revenue',
    label: '总收入',
    value: '¥1,256,800',
    gradient: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    icon: 'Money'
  },
  {
    key: 'users',
    label: '总用户数',
    value: '8,520',
    gradient: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    icon: 'User'
  },
  {
    key: 'growth',
    label: '月增长率',
    value: '+18.5%',
    gradient: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
    icon: 'TrendCharts'
  }
])

const tableData = ref([
  { date: '2024-02-27', orders: 156, revenue: 45680, newUsers: 45, activeUsers: 892, conversionRate: 12.5 },
  { date: '2024-02-26', orders: 142, revenue: 42300, newUsers: 38, activeUsers: 856, conversionRate: 11.8 },
  { date: '2024-02-25', orders: 168, revenue: 51200, newUsers: 52, activeUsers: 923, conversionRate: 13.2 },
  { date: '2024-02-24', orders: 134, revenue: 38900, newUsers: 41, activeUsers: 834, conversionRate: 11.2 },
  { date: '2024-02-23', orders: 178, revenue: 53400, newUsers: 48, activeUsers: 945, conversionRate: 13.8 }
])

const orderTrendChartRef = ref(null)
const revenueTrendChartRef = ref(null)
const userSourceChartRef = ref(null)
const serviceTypeChartRef = ref(null)
const orderStatusChartRef = ref(null)
const userGrowthChartRef = ref(null)
const activeTimeChartRef = ref(null)

let charts = {}

// 按周期获取订单/收入趋势数据
const getOrderTrendData = (period) => {
  if (period === 'week') return { x: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'], y: [120, 132, 101, 134, 90, 230, 210] }
  if (period === 'month') {
    const x = [], y = []
    for (let i = 1; i <= 30; i++) { x.push(i + '日'); y.push(80 + Math.floor(Math.random() * 120)) }
    return { x, y }
  }
  return { x: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'], y: [3200, 3100, 3350, 3480, 3620, 3780, 3920, 3850, 4100, 4280, 4350, 4520] }
}
const getRevenueTrendData = (period) => {
  if (period === 'week') return { x: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'], y: [2200, 1820, 1910, 2340, 2900, 3300, 3100] }
  if (period === 'month') {
    const x = [], y = []
    for (let i = 1; i <= 30; i++) { x.push(i + '日'); y.push(1500 + Math.floor(Math.random() * 2500)) }
    return { x, y }
  }
  return { x: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'], y: [82000, 93200, 90100, 93400, 129000, 133000, 132000, 145000, 152000, 148000, 155000, 160000] }
}

const updateOrderTrendChart = () => {
  if (!charts.orderTrend || !orderTrendChartRef.value) return
  const { x, y } = getOrderTrendData(orderTrendPeriod.value)
  charts.orderTrend.setOption({ xAxis: { data: x }, series: [{ data: y }] })
}
const updateRevenueTrendChart = () => {
  if (!charts.revenueTrend || !revenueTrendChartRef.value) return
  const { x, y } = getRevenueTrendData(revenueTrendPeriod.value)
  charts.revenueTrend.setOption({ xAxis: { data: x }, series: [{ data: y }] })
}

watch(orderTrendPeriod, updateOrderTrendChart)
watch(revenueTrendPeriod, updateRevenueTrendChart)

const initCharts = () => {
  // 订单趋势图
  charts.orderTrend = echarts.init(orderTrendChartRef.value)
  const orderData = getOrderTrendData('week')
  charts.orderTrend.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: orderData.x },
    yAxis: { type: 'value' },
    series: [{
      data: orderData.y,
      type: 'line',
      smooth: true,
      itemStyle: { color: '#409EFF' },
      areaStyle: {
        color: {
          type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [
            { offset: 0, color: 'rgba(64, 158, 255, 0.3)' },
            { offset: 1, color: 'rgba(64, 158, 255, 0.05)' }
          ]
        }
      }
    }]
  })

  // 收入趋势图
  charts.revenueTrend = echarts.init(revenueTrendChartRef.value)
  const revenueData = getRevenueTrendData('week')
  charts.revenueTrend.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: revenueData.x },
    yAxis: { type: 'value' },
    series: [{
      data: revenueData.y,
      type: 'bar',
      itemStyle: {
        color: {
          type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [
            { offset: 0, color: '#67C23A' },
            { offset: 1, color: '#95D475' }
          ]
        }
      }
    }]
  })

  // 用户来源分布
  charts.userSource = echarts.init(userSourceChartRef.value)
  charts.userSource.setOption({
    tooltip: { trigger: 'item' },
    series: [{
      type: 'pie',
      radius: '70%',
      data: [
        { value: 335, name: '搜索引擎', itemStyle: { color: '#409EFF' } },
        { value: 210, name: '直接访问', itemStyle: { color: '#67C23A' } },
        { value: 148, name: '社交媒体', itemStyle: { color: '#E6A23C' } },
        { value: 128, name: '推荐', itemStyle: { color: '#F56C6C' } }
      ]
    }]
  })

  // 服务类型占比
  charts.serviceType = echarts.init(serviceTypeChartRef.value)
  charts.serviceType.setOption({
    tooltip: { trigger: 'item' },
    series: [{
      type: 'pie',
      radius: ['40%', '70%'],
      data: [
        { value: 335, name: '保洁服务', itemStyle: { color: '#409EFF' } },
        { value: 210, name: '月嫂服务', itemStyle: { color: '#67C23A' } },
        { value: 148, name: '护理服务', itemStyle: { color: '#E6A23C' } },
        { value: 128, name: '钟点工', itemStyle: { color: '#F56C6C' } },
        { value: 96, name: '育儿嫂', itemStyle: { color: '#909399' } }
      ]
    }]
  })

  // 订单状态分布
  charts.orderStatus = echarts.init(orderStatusChartRef.value)
  charts.orderStatus.setOption({
    tooltip: { trigger: 'item' },
    series: [{
      type: 'pie',
      radius: '70%',
      data: [
        { value: 450, name: '已完成', itemStyle: { color: '#67C23A' } },
        { value: 180, name: '进行中', itemStyle: { color: '#409EFF' } },
        { value: 120, name: '待接单', itemStyle: { color: '#E6A23C' } },
        { value: 80, name: '已取消', itemStyle: { color: '#F56C6C' } }
      ]
    }]
  })

  // 用户增长趋势
  charts.userGrowth = echarts.init(userGrowthChartRef.value)
  charts.userGrowth.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: ['1月', '2月', '3月', '4月', '5月', '6月'] },
    yAxis: { type: 'value' },
    series: [{
      data: [820, 932, 1101, 1234, 1390, 1550],
      type: 'line',
      smooth: true,
      itemStyle: { color: '#409EFF' }
    }]
  })

  // 活跃时间段分布
  charts.activeTime = echarts.init(activeTimeChartRef.value)
  charts.activeTime.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: ['0-4时', '4-8时', '8-12时', '12-16时', '16-20时', '20-24时'] },
    yAxis: { type: 'value' },
    series: [{
      data: [120, 80, 450, 380, 520, 680],
      type: 'bar',
      itemStyle: {
        color: {
          type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [
            { offset: 0, color: '#E6A23C' },
            { offset: 1, color: '#F5D48F' }
          ]
        }
      }
    }]
  })
}

const handleExport = () => {
  try {
    const lib = XLSX?.default || XLSX
    if (!lib?.utils) {
      ElMessage.error('导出库未就绪，请刷新页面重试')
      return
    }
    const data = (tableData.value || []).map(row => ({
      日期: row.date,
      订单数: row.orders,
      收入: row.revenue,
      新增用户: row.newUsers,
      活跃用户: row.activeUsers,
      '转化率(%)': row.conversionRate
    }))
    if (data.length === 0) {
      ElMessage.warning('暂无数据可导出')
      return
    }
    const ws = lib.utils.json_to_sheet(data)
    const wb = lib.utils.book_new()
    lib.utils.book_append_sheet(wb, ws, '运营数据')
    const fileName = `运营数据_${new Date().toISOString().slice(0, 10).replace(/-/g, '')}.xlsx`
    lib.writeFile(wb, fileName)
    ElMessage.success('数据已导出')
  } catch (e) {
    console.error('导出失败', e)
    ElMessage.error(e?.message || '导出失败，请重试')
  }
}

onMounted(() => {
  initCharts()
  window.addEventListener('resize', () => {
    Object.values(charts).forEach(chart => chart && chart.resize())
  })
})

onBeforeUnmount(() => {
  Object.values(charts).forEach(chart => chart && chart.dispose())
})
</script>

<style scoped>
.statistics-page {
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

.stat-card :deep(.el-card__body) {
  padding: 20px;
}

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
  font-size: 24px;
  font-weight: 700;
  color: #303133;
}

.chart-card {
  background: white;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h3 {
  margin: 0;
  font-size: 16px;
  color: #303133;
}

.chart-container {
  height: 300px;
}

.data-table-card {
  background: white;
}
</style>

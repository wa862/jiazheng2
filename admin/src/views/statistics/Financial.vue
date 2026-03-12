<template>
  <admin-layout>
    <div class="financial-page">
      <div class="page-header">
        <h1>财务统计</h1>
        <p>详细的财务数据分析和报表</p>
      </div>

      <!-- 财务概览卡片 -->
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in financeStats" :key="stat.key">
          <el-card class="stat-card" :class="stat.type">
            <div class="stat-content">
              <div class="stat-icon" :style="{ background: stat.gradient }">
                <el-icon :size="32" color="white">
                  <component :is="stat.icon" />
                </el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">{{ stat.label }}</p>
                <p class="stat-value">{{ stat.value }}</p>
                <p class="stat-change" :class="stat.change > 0 ? 'up' : 'down'">
                  <el-icon><TrendCharts /></el-icon>
                  {{ stat.change > 0 ? '+' : '' }}{{ stat.change }}%
                  <span class="period">较上月</span>
                </p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 收入趋势和支出分析 -->
      <el-row :gutter="20" style="margin-top: 20px;">
        <el-col :span="16">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>收支趋势分析</h3>
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
        </el-col>

        <el-col :span="8">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>支出构成</h3>
              </div>
            </template>
            <div ref="expenseChartRef" class="chart-container"></div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 收入构成和平台抽成 -->
      <el-row :gutter="20" style="margin-top: 20px;">
        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>收入构成分析</h3>
              </div>
            </template>
            <div ref="revenueChartRef" class="chart-container"></div>
          </el-card>
        </el-col>

        <el-col :span="12">
          <el-card class="chart-card">
            <template #header>
              <div class="card-header">
                <h3>平台抽成分析</h3>
              </div>
            </template>
            <div ref="commissionChartRef" class="chart-container"></div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 交易明细表格 -->
      <el-card class="table-card" style="margin-top: 20px;">
        <template #header>
          <div class="table-header">
            <h3>交易明细</h3>
            <div class="filter-section">
              <el-date-picker
                v-model="dateRange"
                type="daterange"
                range-separator="至"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                value-format="YYYY-MM-DD"
                style="width: 240px"
              />
              <el-select v-model="transactionType" placeholder="交易类型" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="收入" value="income" />
                <el-option label="支出" value="expense" />
                <el-option label="退款" value="refund" />
              </el-select>
              <el-button type="primary" @click="handleSearch">
                <el-icon><Search /></el-icon>
                搜索
              </el-button>
            </div>
          </div>
        </template>

        <el-table
          :data="transactions"
          style="width: 100%"
          v-loading="loading"
        >
          <el-table-column prop="transactionNo" label="交易单号" width="180" />
          <el-table-column prop="type" label="类型" width="100">
            <template #default="{ row }">
              <el-tag :type="getTransactionType(row.type)">
                {{ getTransactionText(row.type) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="amount" label="金额" width="120">
            <template #default="{ row }">
              <span :class="row.type === 'income' ? 'amount-income' : 'amount-expense'">
                {{ row.type === 'income' ? '+' : '-' }}¥{{ row.amount }}
              </span>
            </template>
          </el-table-column>
          <el-table-column prop="description" label="描述" min-width="200" />
          <el-table-column prop="orderNo" label="关联订单" width="180" />
          <el-table-column prop="createTime" label="交易时间" width="180" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="row.status === 'completed' ? 'success' : 'warning'" size="small">
                {{ row.status === 'completed' ? '已完成' : '处理中' }}
              </el-tag>
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
  </admin-layout>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import AdminLayout from '@/components/AdminLayout.vue'
import {
  Money,
  TrendCharts,
  Wallet,
  Coin,
  Search
} from '@element-plus/icons-vue'

// 财务统计数据
const financeStats = ref([
  {
    key: 'totalRevenue',
    label: '总收入',
    value: '¥1,234,567',
    change: 15.3,
    icon: Money,
    gradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    type: 'income'
  },
  {
    key: 'totalExpense',
    label: '总支出',
    value: '¥456,789',
    change: -8.2,
    icon: Wallet,
    gradient: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    type: 'expense'
  },
  {
    key: 'netProfit',
    label: '净利润',
    value: '¥777,778',
    change: 23.5,
    icon: Coin,
    gradient: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    type: 'profit'
  },
  {
    key: 'commission',
    label: '平台抽成',
    value: '¥123,456',
    change: 12.1,
    icon: TrendCharts,
    gradient: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
    type: 'commission'
  }
])

// 图表相关
const trendPeriod = ref('month')
const trendChartRef = ref(null)
const expenseChartRef = ref(null)
const revenueChartRef = ref(null)
const commissionChartRef = ref(null)
let trendChart = null
let expenseChart = null
let revenueChart = null
let commissionChart = null

// 表格相关
const loading = ref(false)
const dateRange = ref([])
const transactionType = ref('')
const pagination = ref({
  page: 1,
  pageSize: 10
})
const total = ref(0)

// 全部交易原始数据（含多日期、多类型，便于按条件筛选）
const allTransactionsList = [
  { transactionNo: 'TRX202601010001', type: 'income', amount: 299, description: '订单收入 - 保洁服务', orderNo: 'ORD202601010001', createTime: '2026-01-01 10:30:00', status: 'completed' },
  { transactionNo: 'TRX202601010002', type: 'expense', amount: 150, description: '家政人员结算', orderNo: 'ORD202601010001', createTime: '2026-01-01 11:00:00', status: 'completed' },
  { transactionNo: 'TRX202601010003', type: 'income', amount: 599, description: '订单收入 - 月嫂服务', orderNo: 'ORD202601010002', createTime: '2026-01-01 14:20:00', status: 'completed' },
  { transactionNo: 'TRX202601010004', type: 'refund', amount: 299, description: '订单退款', orderNo: 'ORD202601010003', createTime: '2026-01-01 16:45:00', status: 'completed' },
  { transactionNo: 'TRX202601010005', type: 'income', amount: 199, description: '订单收入 - 钟点工', orderNo: 'ORD202601010004', createTime: '2026-01-01 18:30:00', status: 'completed' },
  { transactionNo: 'TRX202603040001', type: 'income', amount: 320, description: '订单收入 - 保洁服务', orderNo: 'ORD202603040001', createTime: '2026-03-04 09:00:00', status: 'completed' },
  { transactionNo: 'TRX202603050002', type: 'income', amount: 450, description: '订单收入 - 月嫂服务', orderNo: 'ORD202603050002', createTime: '2026-03-05 14:20:00', status: 'completed' },
  { transactionNo: 'TRX202603060003', type: 'expense', amount: 200, description: '家政人员结算', orderNo: 'ORD202603050002', createTime: '2026-03-06 10:00:00', status: 'completed' },
  { transactionNo: 'TRX202603080004', type: 'income', amount: 180, description: '订单收入 - 钟点工', orderNo: 'ORD202603080004', createTime: '2026-03-08 16:30:00', status: 'completed' },
  { transactionNo: 'TRX202603100005', type: 'refund', amount: 320, description: '订单退款', orderNo: 'ORD202603040001', createTime: '2026-03-10 11:00:00', status: 'completed' },
  { transactionNo: 'TRX202603120006', type: 'income', amount: 520, description: '订单收入 - 育儿嫂', orderNo: 'ORD202603120006', createTime: '2026-03-12 08:45:00', status: 'completed' }
]

// 当前展示的交易数据（筛选 + 分页后的结果）
const transactions = ref([])

// 获取交易类型标签样式
const getTransactionType = (type) => {
  const types = {
    income: 'success',
    expense: 'danger',
    refund: 'warning'
  }
  return types[type] || 'info'
}

// 获取交易类型文本
const getTransactionText = (type) => {
  const texts = {
    income: '收入',
    expense: '支出',
    refund: '退款'
  }
  return texts[type] || type
}

// 按周期获取收支趋势数据
const getTrendChartData = (period) => {
  if (period === 'week') {
    return {
      x: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
      income: [8200, 9320, 9010, 9340, 12900, 13300, 13200],
      expense: [3200, 3320, 3010, 3340, 3900, 4300, 4200],
      profit: [5000, 6000, 6000, 6000, 9000, 9000, 9000]
    }
  }
  if (period === 'month') {
    const x = [], income = [], expense = [], profit = []
    for (let i = 1; i <= 30; i++) {
      x.push(i + '日')
      income.push(8000 + Math.floor(Math.random() * 8000))
      expense.push(3000 + Math.floor(Math.random() * 2000))
      profit.push(4000 + Math.floor(Math.random() * 5000))
    }
    return { x, income, expense, profit }
  }
  return {
    x: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
    income: [82000, 93200, 90100, 93400, 129000, 133000, 132000, 145000, 152000, 148000, 155000, 160000],
    expense: [32000, 33200, 30100, 33400, 39000, 43000, 42000, 45000, 48000, 46000, 49000, 50000],
    profit: [50000, 60000, 60000, 60000, 90000, 90000, 90000, 100000, 104000, 102000, 106000, 110000]
  }
}

const updateTrendChart = () => {
  if (!trendChart) return
  const { x, income, expense, profit } = getTrendChartData(trendPeriod.value)
  trendChart.setOption({
    xAxis: { data: x },
    series: [
      { data: income },
      { data: expense },
      { data: profit }
    ]
  })
}

// 初始化收支趋势图表
const initTrendChart = () => {
  if (!trendChartRef.value) return
  
  trendChart = echarts.init(trendChartRef.value)
  const data = getTrendChartData(trendPeriod.value)
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'cross' }
    },
    legend: { data: ['收入', '支出', '净利润'], bottom: 0 },
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
      axisLabel: { color: '#666', formatter: '¥{value}' }
    },
    series: [
      {
        name: '收入',
        type: 'line',
        smooth: true,
        data: data.income,
        itemStyle: { color: '#67C23A' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(103, 194, 58, 0.3)' },
            { offset: 1, color: 'rgba(103, 194, 58, 0.05)' }
          ])
        }
      },
      {
        name: '支出',
        type: 'line',
        smooth: true,
        data: data.expense,
        itemStyle: { color: '#F56C6C' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(245, 108, 108, 0.3)' },
            { offset: 1, color: 'rgba(245, 108, 108, 0.05)' }
          ])
        }
      },
      {
        name: '净利润',
        type: 'bar',
        data: data.profit,
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: '#409EFF' },
            { offset: 1, color: '#64B5F6' }
          ])
        }
      }
    ]
  }
  trendChart.setOption(option)
}

watch(trendPeriod, () => {
  updateTrendChart()
})

// 初始化支出构成图表
const initExpenseChart = () => {
  if (!expenseChartRef.value) return
  
  expenseChart = echarts.init(expenseChartRef.value)
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: ¥{c} ({d}%)'
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
          { value: 180000, name: '家政人员结算', itemStyle: { color: '#409EFF' } },
          { value: 120000, name: '平台运营', itemStyle: { color: '#67C23A' } },
          { value: 80000, name: '市场推广', itemStyle: { color: '#E6A23C' } },
          { value: 50000, name: '技术开发', itemStyle: { color: '#F56C6C' } },
          { value: 26789, name: '其他支出', itemStyle: { color: '#909399' } }
        ]
      }
    ]
  }
  expenseChart.setOption(option)
}

// 初始化收入构成图表
const initRevenueChart = () => {
  if (!revenueChartRef.value) return
  
  revenueChart = echarts.init(revenueChartRef.value)
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
      data: ['保洁服务', '月嫂服务', '护工服务', '钟点工', '育儿嫂', '家电清洗'],
      axisLabel: {
        interval: 0,
        rotate: 30
      }
    },
    yAxis: {
      type: 'value',
      axisLabel: {
        formatter: '¥{value}'
      }
    },
    series: [
      {
        type: 'bar',
        data: [
          { value: 450000, itemStyle: { color: '#409EFF' } },
          { value: 380000, itemStyle: { color: '#67C23A' } },
          { value: 280000, itemStyle: { color: '#E6A23C' } },
          { value: 220000, itemStyle: { color: '#F56C6C' } },
          { value: 180000, itemStyle: { color: '#909399' } },
          { value: 120000, itemStyle: { color: '#8B5CF6' } }
        ],
        barWidth: '50%',
        itemStyle: {
          borderRadius: [8, 8, 0, 0]
        }
      }
    ]
  }
  revenueChart.setOption(option)
}

// 初始化平台抽成图表
const initCommissionChart = () => {
  if (!commissionChartRef.value) return
  
  commissionChart = echarts.init(commissionChartRef.value)
  const option = {
    tooltip: {
      trigger: 'axis'
    },
    legend: {
      data: ['抽成金额', '抽成率'],
      bottom: 0
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '15%',
      top: '10%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: ['1月', '2月', '3月', '4月', '5月', '6月']
    },
    yAxis: [
      {
        type: 'value',
        name: '金额',
        axisLabel: {
          formatter: '¥{value}'
        }
      },
      {
        type: 'value',
        name: '比率',
        axisLabel: {
          formatter: '{value}%'
        }
      }
    ],
    series: [
      {
        name: '抽成金额',
        type: 'bar',
        data: [8200, 9320, 9010, 9340, 12900, 13300],
        itemStyle: { color: '#409EFF' }
      },
      {
        name: '抽成率',
        type: 'line',
        yAxisIndex: 1,
        data: [10, 10, 10, 10, 10, 10],
        itemStyle: { color: '#67C23A' },
        lineStyle: {
          type: 'dashed'
        }
      }
    ]
  }
  commissionChart.setOption(option)
}

// 搜索：按时间范围、交易类型筛选并分页
const handleSearch = () => {
  loading.value = true
  pagination.value.page = 1
  applyFilterAndPage()
  loading.value = false
}

const applyFilterAndPage = () => {
  const range = dateRange.value
  const typeFilter = transactionType.value ? String(transactionType.value).trim() : ''
  const startDate = range && range[0] ? range[0] : ''
  const endDate = range && range[1] ? range[1] : ''

  let list = allTransactionsList.filter((row) => {
    const rowDate = (row.createTime || '').slice(0, 10)
    if (startDate && rowDate < startDate) return false
    if (endDate && rowDate > endDate) return false
    if (typeFilter && row.type !== typeFilter) return false
    return true
  })

  list = list.sort((a, b) => (b.createTime || '').localeCompare(a.createTime || ''))

  total.value = list.length
  const page = pagination.value.page
  const pageSize = pagination.value.pageSize
  const start = (page - 1) * pageSize
  transactions.value = list.slice(start, start + pageSize)
}

// 分页
const handleSizeChange = (val) => {
  pagination.value.pageSize = val
  pagination.value.page = 1
  applyFilterAndPage()
}

const handleCurrentChange = (val) => {
  pagination.value.page = val
  applyFilterAndPage()
}

// 窗口大小改变时重新渲染图表
const handleResize = () => {
  trendChart?.resize()
  expenseChart?.resize()
  revenueChart?.resize()
  commissionChart?.resize()
}

onMounted(() => {
  handleSearch()
  nextTick(() => {
    initTrendChart()
    initExpenseChart()
    initRevenueChart()
    initCommissionChart()
  })
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  trendChart?.dispose()
  expenseChart?.dispose()
  revenueChart?.dispose()
  commissionChart?.dispose()
})
</script>

<style scoped lang="scss">
.financial-page {
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

    .stat-change {
      font-size: 13px;
      margin: 0;
      display: flex;
      align-items: center;
      gap: 4px;

      .period {
        color: #9ca3af;
        margin-left: 4px;
      }

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

    .header-actions {
      display: flex;
      gap: 12px;
      align-items: center;
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

    .filter-section {
      display: flex;
      gap: 12px;
      align-items: center;
    }
  }

  .amount-income {
    color: #67c23a;
    font-weight: 600;
  }

  .amount-expense {
    color: #f56c6c;
    font-weight: 600;
  }

  .pagination {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
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

<template>
  <admin-layout>
    <div class="logs-page">
      <div class="page-header">
        <h1>操作日志</h1>
        <p>查看系统操作记录和审计日志</p>
      </div>

      <!-- 统计卡片 -->
      <el-row :gutter="20" class="stats-row">
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #409EFF 0%, #64B5F6 100%);">
                <el-icon :size="28" color="white"><Document /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">今日日志</p>
                <p class="stat-value">{{ stats.today }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #67C23A 0%, #85CE61 100%);">
                <el-icon :size="28" color="white"><CircleCheck /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">正常操作</p>
                <p class="stat-value">{{ stats.success }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #E6A23C 0%, #EBB563 100%);">
                <el-icon :size="28" color="white"><Warning /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">警告日志</p>
                <p class="stat-value">{{ stats.warning }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #F56C6C 0%, #F78989 100%);">
                <el-icon :size="28" color="white"><CircleClose /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">错误日志</p>
                <p class="stat-value">{{ stats.error }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 日志列表 -->
      <el-card class="table-card" style="margin-top: 20px;">
        <template #header>
          <div class="table-header">
            <div class="filter-section">
              <el-date-picker
                v-model="dateRange"
                type="datetimerange"
                range-separator="至"
                start-placeholder="开始时间"
                end-placeholder="结束时间"
                style="width: 320px"
              />
              <el-select v-model="filterModule" placeholder="操作模块" clearable style="width: 140px">
                <el-option label="全部" value="" />
                <el-option label="用户管理" value="user" />
                <el-option label="家政人员" value="worker" />
                <el-option label="订单管理" value="order" />
                <el-option label="系统设置" value="system" />
                <el-option label="登录认证" value="auth" />
              </el-select>
              <el-select v-model="filterLevel" placeholder="日志级别" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="信息" value="info" />
                <el-option label="警告" value="warning" />
                <el-option label="错误" value="error" />
              </el-select>
              <el-input 
                v-model="searchKeyword" 
                placeholder="搜索操作人/内容..." 
                class="search-input"
                clearable
                @keyup.enter="handleSearch"
                style="width: 200px"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-button type="primary" @click="handleSearch">
                <el-icon><Search /></el-icon>
                搜索
              </el-button>
            </div>
            <div class="action-section">
              <el-button type="success" @click="handleExport">
                <el-icon><Download /></el-icon>
                导出日志
              </el-button>
              <el-button type="danger" @click="handleClear">
                <el-icon><Delete /></el-icon>
                清空日志
              </el-button>
            </div>
          </div>
        </template>

        <el-table
          :data="logs"
          style="width: 100%"
          v-loading="loading"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="level" label="级别" width="90">
            <template #default="{ row }">
              <el-tag :type="getLevelType(row.level)" size="small" effect="dark">
                <el-icon v-if="row.level === 'info'"><InfoFilled /></el-icon>
                <el-icon v-else-if="row.level === 'warning'"><Warning /></el-icon>
                <el-icon v-else><CircleClose /></el-icon>
                {{ getLevelText(row.level) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="module" label="操作模块" width="120">
            <template #default="{ row }">
              <el-tag :type="getModuleType(row.module)" size="small">
                {{ getModuleText(row.module) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="action" label="操作类型" width="120" />
          <el-table-column prop="content" label="操作内容" min-width="250">
            <template #default="{ row }">
              <el-tooltip :content="row.content" placement="top" :show-after="500">
                <span class="content-text">{{ row.content }}</span>
              </el-tooltip>
            </template>
          </el-table-column>
          <el-table-column prop="operator" label="操作人" width="120">
            <template #default="{ row }">
              <div class="operator-info">
                <el-avatar :size="24" :src="row.avatar">
                  <el-icon><UserFilled /></el-icon>
                </el-avatar>
                <span>{{ row.operator }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="ip" label="IP地址" width="140" />
          <el-table-column prop="duration" label="耗时" width="100">
            <template #default="{ row }">
              <span :class="getDurationClass(row.duration)">{{ row.duration }}ms</span>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="操作时间" width="180" />
          <el-table-column label="操作" fixed="right" width="120">
            <template #default="{ row }">
              <el-button type="primary" size="small" @click="handleView(row)">
                <el-icon><View /></el-icon>
                详情
              </el-button>
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

      <!-- 日志详情对话框 -->
      <el-dialog
        v-model="detailDialogVisible"
        title="日志详情"
        width="700px"
        destroy-on-close
      >
        <div class="log-detail" v-if="currentLog">
          <el-descriptions :column="2" border>
            <el-descriptions-item label="日志ID">{{ currentLog.id }}</el-descriptions-item>
            <el-descriptions-item label="日志级别">
              <el-tag :type="getLevelType(currentLog.level)" size="small" effect="dark">
                {{ getLevelText(currentLog.level) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="操作模块">
              <el-tag :type="getModuleType(currentLog.module)" size="small">
                {{ getModuleText(currentLog.module) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="操作类型">{{ currentLog.action }}</el-descriptions-item>
            <el-descriptions-item label="操作人">{{ currentLog.operator }}</el-descriptions-item>
            <el-descriptions-item label="操作时间">{{ currentLog.createTime }}</el-descriptions-item>
            <el-descriptions-item label="IP地址">{{ currentLog.ip }}</el-descriptions-item>
            <el-descriptions-item label="请求方式">{{ currentLog.method }}</el-descriptions-item>
            <el-descriptions-item label="请求URL" :span="2">{{ currentLog.url }}</el-descriptions-item>
            <el-descriptions-item label="执行耗时">
              <span :class="getDurationClass(currentLog.duration)">{{ currentLog.duration }}ms</span>
            </el-descriptions-item>
            <el-descriptions-item label="状态码">
              <el-tag :type="currentLog.statusCode === 200 ? 'success' : 'danger'" size="small">
                {{ currentLog.statusCode }}
              </el-tag>
            </el-descriptions-item>
          </el-descriptions>

          <div class="detail-section">
            <h4>操作内容</h4>
            <div class="content-box">{{ currentLog.content }}</div>
          </div>

          <div class="detail-section" v-if="currentLog.params">
            <h4>请求参数</h4>
            <pre class="code-box">{{ formatJson(currentLog.params) }}</pre>
          </div>

          <div class="detail-section" v-if="currentLog.result">
            <h4>响应结果</h4>
            <pre class="code-box">{{ formatJson(currentLog.result) }}</pre>
          </div>

          <div class="detail-section" v-if="currentLog.error">
            <h4>错误信息</h4>
            <pre class="code-box error">{{ currentLog.error }}</pre>
          </div>
        </div>
      </el-dialog>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import AdminLayout from '@/components/AdminLayout.vue'
import {
  Document,
  CircleCheck,
  Warning,
  CircleClose,
  Search,
  Download,
  Delete,
  View,
  InfoFilled,
  UserFilled
} from '@element-plus/icons-vue'

// 统计数据
const stats = reactive({
  today: 1234,
  success: 1156,
  warning: 56,
  error: 22
})

// 搜索和筛选
const dateRange = ref([])
const filterModule = ref('')
const filterLevel = ref('')
const searchKeyword = ref('')

// 表格相关
const loading = ref(false)
const pagination = reactive({
  page: 1,
  pageSize: 10
})
const total = ref(2345)
const selectedLogs = ref([])

// 日志数据
const logs = ref([
  {
    id: 1,
    level: 'info',
    module: 'user',
    action: '用户登录',
    content: '管理员 admin 登录系统',
    operator: 'admin',
    avatar: '',
    ip: '192.168.1.100',
    duration: 156,
    createTime: '2026-01-15 14:32:18',
    method: 'POST',
    url: '/api/auth/login',
    statusCode: 200,
    params: { username: 'admin' },
    result: { token: 'eyJhbGciOiJIUzI1NiIs...', expiresIn: 7200 }
  },
  {
    id: 2,
    level: 'info',
    module: 'order',
    action: '订单状态更新',
    content: '将订单 ORD202601150001 状态更新为"已完成"',
    operator: 'admin',
    avatar: '',
    ip: '192.168.1.100',
    duration: 89,
    createTime: '2026-01-15 14:30:45',
    method: 'PUT',
    url: '/api/orders/ORD202601150001/status',
    statusCode: 200,
    params: { status: 'completed' },
    result: { success: true }
  },
  {
    id: 3,
    level: 'warning',
    module: 'auth',
    action: '登录失败',
    content: '用户 test 登录失败，密码错误',
    operator: 'test',
    avatar: '',
    ip: '192.168.1.105',
    duration: 45,
    createTime: '2026-01-15 14:28:12',
    method: 'POST',
    url: '/api/auth/login',
    statusCode: 401,
    params: { username: 'test' },
    result: null,
    error: 'Invalid credentials'
  },
  {
    id: 4,
    level: 'error',
    module: 'system',
    action: '数据库连接失败',
    content: '无法连接到数据库服务器',
    operator: 'system',
    avatar: '',
    ip: '127.0.0.1',
    duration: 5000,
    createTime: '2026-01-15 14:25:33',
    method: 'GET',
    url: '/api/health',
    statusCode: 500,
    params: {},
    result: null,
    error: 'Connection timeout after 5000ms'
  },
  {
    id: 5,
    level: 'info',
    module: 'worker',
    action: '家政人员审核',
    content: '通过家政人员 张阿姨 的入驻申请',
    operator: 'admin',
    avatar: '',
    ip: '192.168.1.100',
    duration: 234,
    createTime: '2026-01-15 14:20:18',
    method: 'PUT',
    url: '/api/workers/123/approve',
    statusCode: 200,
    params: { status: 'approved' },
    result: { success: true }
  }
])

// 详情对话框
const detailDialogVisible = ref(false)
const currentLog = ref(null)

// 获取级别标签样式
const getLevelType = (level) => {
  const types = {
    info: 'info',
    warning: 'warning',
    error: 'danger'
  }
  return types[level] || 'info'
}

// 获取级别文本
const getLevelText = (level) => {
  const texts = {
    info: '信息',
    warning: '警告',
    error: '错误'
  }
  return texts[level] || level
}

// 获取模块标签样式
const getModuleType = (module) => {
  const types = {
    user: 'primary',
    worker: 'success',
    order: 'warning',
    system: 'danger',
    auth: 'info'
  }
  return types[module] || ''
}

// 获取模块文本
const getModuleText = (module) => {
  const texts = {
    user: '用户管理',
    worker: '家政人员',
    order: '订单管理',
    system: '系统设置',
    auth: '登录认证'
  }
  return texts[module] || module
}

// 获取耗时样式
const getDurationClass = (duration) => {
  if (duration < 200) return 'duration-fast'
  if (duration < 1000) return 'duration-normal'
  return 'duration-slow'
}

// 格式化JSON
const formatJson = (obj) => {
  return JSON.stringify(obj, null, 2)
}

// 搜索
const handleSearch = () => {
  loading.value = true
  setTimeout(() => {
    loading.value = false
    ElMessage.success('搜索完成')
  }, 500)
}

// 选择变化
const handleSelectionChange = (selection) => {
  selectedLogs.value = selection
}

// 查看详情
const handleView = (row) => {
  currentLog.value = row
  detailDialogVisible.value = true
}

// 导出日志
const handleExport = () => {
  ElMessage.success('日志导出成功')
}

// 清空日志
const handleClear = () => {
  ElMessageBox.confirm(
    '确定要清空所有日志吗？此操作不可恢复！',
    '警告',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    logs.value = []
    total.value = 0
    stats.today = 0
    stats.success = 0
    stats.warning = 0
    stats.error = 0
    ElMessage.success('日志已清空')
  }).catch(() => {})
}

// 分页
const handleSizeChange = (val) => {
  pagination.pageSize = val
  handleSearch()
}

const handleCurrentChange = (val) => {
  pagination.page = val
  handleSearch()
}
</script>

<style scoped lang="scss">
.logs-page {
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

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
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
    flex-shrink: 0;
  }

  .stat-info {
    .stat-label {
      font-size: 14px;
      color: #6b7280;
      margin: 0 0 4px 0;
    }

    .stat-value {
      font-size: 24px;
      font-weight: 700;
      color: #1f2937;
      margin: 0;
    }
  }
}

.table-card {
  .table-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;

    .filter-section {
      display: flex;
      gap: 12px;
      align-items: center;
      flex-wrap: wrap;
    }

    .action-section {
      display: flex;
      gap: 12px;
    }
  }

  .content-text {
    display: inline-block;
    max-width: 300px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .operator-info {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .duration-fast {
    color: #67c23a;
  }

  .duration-normal {
    color: #e6a23c;
  }

  .duration-slow {
    color: #f56c6c;
    font-weight: 600;
  }

  .pagination {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
  }
}

.log-detail {
  .detail-section {
    margin-top: 20px;

    h4 {
      font-size: 14px;
      font-weight: 600;
      color: #1f2937;
      margin: 0 0 12px 0;
    }

    .content-box {
      padding: 12px;
      background: #f5f7fa;
      border-radius: 4px;
      font-size: 13px;
      color: #606266;
      line-height: 1.6;
    }

    .code-box {
      padding: 12px;
      background: #f5f7fa;
      border-radius: 4px;
      font-size: 12px;
      color: #606266;
      line-height: 1.6;
      overflow-x: auto;
      margin: 0;

      &.error {
        background: #fef0f0;
        color: #f56c6c;
      }
    }
  }
}

:deep(.el-card__header) {
  border-bottom: 1px solid #e5e7eb;
  padding: 16px 20px;
}

:deep(.el-card__body) {
  padding: 20px;
}

:deep(.el-descriptions__label) {
  width: 120px;
}
</style>

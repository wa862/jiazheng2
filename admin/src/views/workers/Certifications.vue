<template>
  <admin-layout>
    <div class="certifications-page">
      <div class="page-header">
        <h1>资质认证</h1>
        <p>管理家政人员的资质认证信息</p>
      </div>

      <!-- 统计卡片 -->
      <el-row :gutter="20" class="stats-row">
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #409EFF 0%, #64B5F6 100%);">
                <el-icon :size="28" color="white"><DocumentChecked /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">总认证数</p>
                <p class="stat-value">{{ stats.total }}</p>
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
                <p class="stat-label">已认证</p>
                <p class="stat-value">{{ stats.verified }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #E6A23C 0%, #EBB563 100%);">
                <el-icon :size="28" color="white"><Timer /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">待审核</p>
                <p class="stat-value">{{ stats.pending }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <div class="stat-content">
              <div class="stat-icon" style="background: linear-gradient(135deg, #F56C6C 0%, #F78989 100%);">
                <el-icon :size="28" color="white"><Warning /></el-icon>
              </div>
              <div class="stat-info">
                <p class="stat-label">即将过期</p>
                <p class="stat-value">{{ stats.expiring }}</p>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 认证列表 -->
      <el-card class="table-card" style="margin-top: 20px;">
        <template #header>
          <div class="table-header">
            <div class="filter-section">
              <el-input 
                v-model="searchKeyword" 
                placeholder="搜索姓名/证书编号..." 
                class="search-input"
                clearable
                @keyup.enter="handleSearch"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-select v-model="filterType" placeholder="证书类型" clearable style="width: 140px">
                <el-option label="全部" value="" />
                <el-option label="健康证" value="health" />
                <el-option label="月嫂证" value="maternity" />
                <el-option label="育婴师证" value="childcare" />
                <el-option label="护理证" value="nursing" />
              </el-select>
              <el-select v-model="filterStatus" placeholder="认证状态" clearable style="width: 120px">
                <el-option label="全部" value="" />
                <el-option label="已认证" value="verified" />
                <el-option label="待审核" value="pending" />
                <el-option label="已过期" value="expired" />
              </el-select>
              <el-button type="primary" @click="handleSearch">
                <el-icon><Search /></el-icon>
                搜索
              </el-button>
            </div>
          </div>
        </template>

        <el-table
          :data="certifications"
          style="width: 100%"
          v-loading="loading"
        >
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column label="家政人员" min-width="150">
            <template #default="{ row }">
              <div class="worker-info">
                <el-avatar :size="40" :src="row.avatar">
                  <el-icon><UserFilled /></el-icon>
                </el-avatar>
                <div class="worker-detail">
                  <p class="name">{{ row.workerName }}</p>
                  <p class="phone">{{ row.phone }}</p>
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="certType" label="证书类型" width="120">
            <template #default="{ row }">
              <el-tag :type="getCertTypeType(row.certType)" size="small">
                {{ getCertTypeText(row.certType) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="certNo" label="证书编号" width="160" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getStatusType(row.status)" size="small">
                {{ getStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="verifyTime" label="审核时间" width="180" />
          <el-table-column label="操作" fixed="right" width="150">
            <template #default="{ row }">
              <el-button type="primary" size="small" @click="handleView(row)">
                <el-icon><View /></el-icon>
                查看
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref, reactive } from 'vue'
import AdminLayout from '@/components/AdminLayout.vue'
import {
  DocumentChecked,
  CircleCheck,
  Timer,
  Warning,
  Search,
  View,
  UserFilled
} from '@element-plus/icons-vue'

const stats = reactive({
  total: 328,
  verified: 285,
  pending: 32,
  expiring: 11
})

const searchKeyword = ref('')
const filterType = ref('')
const filterStatus = ref('')
const loading = ref(false)

const certifications = ref([
  {
    id: 1,
    workerName: '张阿姨',
    phone: '13800138001',
    avatar: '',
    certType: 'health',
    certNo: 'HW2026001234',
    status: 'verified',
    verifyTime: '2025-01-16 10:30:00'
  }
])

const getCertTypeType = (type) => {
  const types = { health: 'success', maternity: 'warning', childcare: 'primary', nursing: 'danger' }
  return types[type] || 'info'
}

const getCertTypeText = (type) => {
  const texts = { health: '健康证', maternity: '月嫂证', childcare: '育婴师证', nursing: '护理证' }
  return texts[type] || type
}

const getStatusType = (status) => {
  const types = { verified: 'success', pending: 'warning', expired: 'danger' }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = { verified: '已认证', pending: '待审核', expired: '已过期' }
  return texts[status] || status
}

const handleSearch = () => {
  loading.value = true
  setTimeout(() => { loading.value = false }, 500)
}

const handleView = (row) => {
  console.log('查看', row)
}
</script>

<style scoped lang="scss">
.certifications-page {
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
.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.worker-info {
  display: flex;
  align-items: center;
  gap: 12px;
  .worker-detail {
    .name {
      font-weight: 500;
      color: #1f2937;
      margin: 0 0 4px 0;
    }
    .phone {
      font-size: 12px;
      color: #6b7280;
      margin: 0;
    }
  }
}
</style>

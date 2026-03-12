<template>
  <admin-layout>
    <div class="disputes-page">
      <div class="page-header">
        <h1>纠纷处理</h1>
        <p>处理订单纠纷和投诉</p>
      </div>

      <el-card class="table-card">
        <template #header>
          <div class="table-header">
            <h3>纠纷列表</h3>
            <el-button type="primary" size="small">处理选中</el-button>
          </div>
        </template>
        <el-table :data="disputes" style="width: 100%">
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="orderNo" label="订单号" width="180" />
          <el-table-column prop="type" label="纠纷类型" width="120" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="row.status === 'pending' ? 'warning' : 'success'">{{ row.status === 'pending' ? '待处理' : '已解决' }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="创建时间" width="180" />
          <el-table-column label="操作" width="150">
            <template #default="{ row }">
              <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref } from 'vue'
import AdminLayout from '@/components/AdminLayout.vue'

const disputes = ref([
  { id: 1, orderNo: 'ORD202601010001', type: '服务质量', status: 'pending', createTime: '2026-01-15 10:00:00' },
  { id: 2, orderNo: 'ORD202601010002', type: '价格争议', status: 'resolved', createTime: '2026-01-14 14:30:00' }
])

const handleView = (row) => {
  console.log('查看纠纷', row)
}
</script>

<style scoped lang="scss">
.disputes-page {
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
.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  h3 {
    margin: 0;
  }
}
</style>

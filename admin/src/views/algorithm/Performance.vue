<template>
  <admin-layout>
    <div class="performance-page">
      <div class="page-header">
        <h1>性能监控</h1>
        <p>监控算法性能指标</p>
      </div>
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card>
            <h4>响应时间</h4>
            <p class="metric">45ms</p>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card>
            <h4>准确率</h4>
            <p class="metric">92.5%</p>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card>
            <h4>召回率</h4>
            <p class="metric">88.3%</p>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card>
            <h4>F1分数</h4>
            <p class="metric">90.3%</p>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </admin-layout>
</template>

<script setup>
import AdminLayout from '@/components/AdminLayout.vue'
</script>

<style scoped lang="scss">
.performance-page {
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
.metric {
  font-size: 32px;
  font-weight: 700;
  color: #409EFF;
  margin: 16px 0 0 0;
}
</style>

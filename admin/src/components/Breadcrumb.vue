<template>
  <el-breadcrumb separator="/">
    <el-breadcrumb-item :to="{ path: '/admin/dashboard' }">首页</el-breadcrumb-item>
    <el-breadcrumb-item v-for="(item, index) in breadcrumbs" :key="index">
      {{ item }}
    </el-breadcrumb-item>
  </el-breadcrumb>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

const breadcrumbs = computed(() => {
  const matched = route.matched
  const titles = []
  
  matched.forEach(item => {
    if (item.meta && item.meta.title) {
      titles.push(item.meta.title)
    }
  })
  
  return titles
})
</script>

<style scoped>
.el-breadcrumb {
  font-size: 14px;
}
</style>

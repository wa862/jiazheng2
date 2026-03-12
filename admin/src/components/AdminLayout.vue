<template>
  <div class="admin-layout">
    <!-- 侧边栏 -->
    <el-aside :width="isCollapse ? '64px' : '260px'" class="sidebar" :class="{ 'sidebar-collapsed': isCollapse }">
      <div class="logo" @click="$router.push('/admin/dashboard')">
        <el-icon :size="32" color="#409EFF"><Setting /></el-icon>
        <span v-if="!isCollapse">家政服务管理</span>
      </div>
      
      <el-menu
        v-show="!isCollapse"
        :default-active="activeMenu"
        class="admin-menu"
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
        :collapse="false"
        :collapse-transition="false"
        router
      >
        <el-menu-item index="/admin/dashboard">
          <el-icon><DataBoard /></el-icon>
          <template #title>数据看板</template>
        </el-menu-item>
        
        <el-sub-menu index="user-management">
          <template #title>
            <el-icon><User /></el-icon>
            <span>用户管理</span>
          </template>
          <el-menu-item index="/admin/users">用户列表</el-menu-item>
          <el-menu-item index="/admin/user-feedback">用户反馈</el-menu-item>
        </el-sub-menu>
        
        <el-sub-menu index="worker-management">
          <template #title>
            <el-icon><UserFilled /></el-icon>
            <span>家政人员</span>
          </template>
          <el-menu-item index="/admin/workers">人员列表</el-menu-item>
          <el-menu-item index="/admin/worker-applications">入驻申请</el-menu-item>
        </el-sub-menu>
        
        <el-sub-menu index="order-management">
          <template #title>
            <el-icon><Document /></el-icon>
            <span>订单管理</span>
          </template>
          <el-menu-item index="/admin/orders">全部订单</el-menu-item>
        </el-sub-menu>
        
        <el-sub-menu index="algorithm-management">
          <template #title>
            <el-icon><Cpu /></el-icon>
            <span>智能算法</span>
          </template>
          <el-menu-item index="/admin/algorithm">算法配置</el-menu-item>
          <el-menu-item index="/admin/algorithm-performance">性能监控</el-menu-item>
        </el-sub-menu>
        
        <el-sub-menu index="statistics">
          <template #title>
            <el-icon><TrendCharts /></el-icon>
            <span>数据统计</span>
          </template>
          <el-menu-item index="/admin/statistics">运营数据</el-menu-item>
          <el-menu-item index="/admin/financial-stats">财务统计</el-menu-item>
          <el-menu-item index="/admin/user-behavior">用户行为</el-menu-item>
        </el-sub-menu>
        
        <el-menu-item index="/admin/banners">
          <el-icon><Picture /></el-icon>
          <template #title>轮播图管理</template>
        </el-menu-item>
        
        <el-sub-menu index="system">
          <template #title>
            <el-icon><Tools /></el-icon>
            <span>系统设置</span>
          </template>
          <el-menu-item index="/admin/notice-management">公告管理</el-menu-item>
          <el-menu-item index="/admin/operation-logs">操作日志</el-menu-item>
        </el-sub-menu>
      </el-menu>
      
      <div class="sidebar-footer">
        <el-button text @click="toggleCollapse">
          <el-icon v-if="isCollapse"><Expand /></el-icon>
          <el-icon v-else><Fold /></el-icon>
          <span v-if="!isCollapse">收起菜单</span>
        </el-button>
      </div>
    </el-aside>
    
    <!-- 主内容区 -->
    <el-container class="main-container">
      <!-- 顶部导航 -->
      <el-header class="header">
        <div class="header-left">
          <breadcrumb />
        </div>
        <div class="header-right">
          <!-- 全屏按钮 -->
          <el-tooltip content="全屏" placement="bottom">
            <el-button text circle @click="toggleFullScreen">
              <el-icon><FullScreen /></el-icon>
            </el-button>
          </el-tooltip>
          
          <!-- 通知 -->
          <el-popover placement="bottom" :width="320" trigger="click" @show="loadNotices">
            <template #reference>
              <el-badge :value="unreadCount || ''" :hidden="unreadCount === 0" class="notice-badge">
                <el-button text circle>
                  <el-icon><Bell /></el-icon>
                </el-button>
              </el-badge>
            </template>
            <div class="notice-list">
              <div class="notice-header">
                <span>通知消息</span>
                <el-button text type="primary" size="small" @click="markAllNoticesRead">全部已读</el-button>
              </div>
              <div class="notice-items">
                <div v-for="notice in notices" :key="notice.id" class="notice-item" @click="handleNoticeClick(notice)">
                  <div class="notice-dot" :class="{ unread: !notice.read }"></div>
                  <div class="notice-content">
                    <p class="notice-title">{{ notice.title }}</p>
                    <p class="notice-time">{{ notice.time }}</p>
                  </div>
                </div>
              </div>
            </div>
          </el-popover>
          
          <!-- 管理员信息 -->
          <el-dropdown trigger="click">
            <div class="user-info">
              <el-avatar :size="36" :src="adminAvatar">
                <el-icon><UserFilled /></el-icon>
              </el-avatar>
              <span class="username">{{ adminName }}</span>
              <el-icon><ArrowDown /></el-icon>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="goTo('/admin/profile')">
                  <el-icon><User /></el-icon>
                  个人中心
                </el-dropdown-item>
                <el-dropdown-item @click="goTo('/admin/settings')">
                  <el-icon><Setting /></el-icon>
                  账号设置
                </el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">
                  <el-icon><SwitchButton /></el-icon>
                  退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      
      <!-- 页面内容 -->
      <el-main class="main-content">
        <slot></slot>
      </el-main>
      
      <!-- 页脚 -->
      <el-footer class="footer" height="40px">
        <p>© 2026 家政服务管理系统 - 基于智能算法的家政服务平台</p>
      </el-footer>
    </el-container>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import Breadcrumb from './Breadcrumb.vue'
import { getNotices, markNoticeRead as apiMarkNoticeRead, markAllNoticesRead as apiMarkAllNoticesRead } from '@api'

const route = useRoute()
const router = useRouter()

// 菜单折叠状态
const isCollapse = ref(false)
const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}

// 当前激活的菜单
const activeMenu = computed(() => route.path)

// 管理员信息
const adminName = ref(localStorage.getItem('adminUsername') || '管理员')
const adminAvatar = ref('')

// 通知（动态从接口拉取，已读状态持久化到后端）
const notices = ref([])
const unreadCount = computed(() => notices.value.filter(n => !n.read).length)

const loadNotices = async () => {
  try {
    const res = await getNotices()
    if (res && res.code === 200 && Array.isArray(res.data)) {
      notices.value = res.data
    } else {
      notices.value = []
    }
  } catch (e) {
    notices.value = []
  }
}

// 全屏切换
const toggleFullScreen = () => {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen()
  } else {
    document.exitFullscreen()
  }
}

const goTo = (path) => {
  router.push(path)
}

const handleNoticeClick = async (notice) => {
  if (notice.read) return
  try {
    await apiMarkNoticeRead(notice.id)
    await loadNotices()
  } catch (e) {
    ElMessage.error('标为已读失败')
  }
}

const markAllNoticesRead = async () => {
  try {
    await apiMarkAllNoticesRead()
    await loadNotices()
    ElMessage.success('已全部标为已读')
  } catch (e) {
    ElMessage.error('操作失败')
  }
}

let noticeTimer = null
onMounted(() => {
  loadNotices()
  noticeTimer = setInterval(loadNotices, 60000)
})
onUnmounted(() => {
  if (noticeTimer) clearInterval(noticeTimer)
})

// 退出登录
const handleLogout = () => {
  ElMessageBox.confirm('确定要退出登录吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    localStorage.removeItem('adminToken')
    localStorage.removeItem('adminUsername')
    ElMessage.success('退出成功')
    router.push('/admin/login')
  })
}
</script>

<style scoped>
.admin-layout {
  display: flex;
  height: 100vh;
  overflow: hidden;
}

.sidebar {
  background-color: #304156;
  display: flex;
  flex-direction: column;
  transition: width 0.3s;
}

.sidebar-collapsed {
  overflow: hidden;
}

.logo {
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  color: #fff;
  font-size: 18px;
  font-weight: 600;
  cursor: pointer;
  border-bottom: 1px solid #1f2d3d;
}

.admin-menu {
  flex: 1;
  border-right: none;
}

.admin-menu :deep(.el-menu-item),
.admin-menu :deep(.el-sub-menu__title) {
  height: 50px;
  line-height: 50px;
}

.admin-menu :deep(.el-menu-item:hover),
.admin-menu :deep(.el-sub-menu__title:hover) {
  background-color: #263445 !important;
}

.sidebar-footer {
  padding: 12px;
  border-top: 1px solid #1f2d3d;
}

.sidebar-footer .el-button {
  color: #bfcbd9;
  width: 100%;
  justify-content: center;
}

.main-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  background-color: #f0f2f5;
  overflow: hidden;
}

.header {
  height: 64px;
  background-color: #fff;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.notice-badge :deep(.el-badge__content) {
  top: 8px;
  right: 8px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.user-info:hover {
  background-color: #f5f7fa;
}

.username {
  font-size: 14px;
  color: #606266;
}

.main-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}

.footer {
  background-color: #fff;
  border-top: 1px solid #e8e8e8;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #999;
  font-size: 12px;
}

/* 通知列表样式 */
.notice-list {
  max-height: 300px;
  overflow-y: auto;
}

.notice-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 12px;
  border-bottom: 1px solid #ebeef5;
  margin-bottom: 8px;
}

.notice-items {
  display: flex;
  flex-direction: column;
}

.notice-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
}

.notice-item:last-child {
  border-bottom: none;
}

.notice-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #c0c4cc;
  margin-top: 6px;
  flex-shrink: 0;
}

.notice-dot.unread {
  background-color: #f56c6c;
}

.notice-content {
  flex: 1;
}

.notice-title {
  font-size: 14px;
  color: #303133;
  margin-bottom: 4px;
}

.notice-time {
  font-size: 12px;
  color: #909399;
}
</style>

<template>
  <div class="app-container">
    <!-- 头部导航栏 -->
    <header class="header">
      <div class="header-content">
        <!-- Logo -->
        <div class="logo" @click="$router.push('/')">
          <el-icon :size="32" color="#409EFF"><House /></el-icon>
          <span>家政服务</span>
        </div>
        
        <!-- 导航菜单 -->
        <nav class="nav-menu">
          <el-menu :default-active="activeMenu" mode="horizontal" class="menu" @select="handleMenuSelect">
            <el-menu-item index="/">
              <el-icon><House /></el-icon>
              <span>首页</span>
            </el-menu-item>
            <el-menu-item index="/services">
              <el-icon><Grid /></el-icon>
              <span>服务分类</span>
            </el-menu-item>
            <el-menu-item index="/orders">
              <el-icon><Document /></el-icon>
              <span>我的订单</span>
            </el-menu-item>
            <el-menu-item index="/ai-recommendation">
              <span>智能问答</span>
            </el-menu-item>
          </el-menu>
        </nav>
        
        <!-- 登录/注册 或 用户菜单 -->
        <div class="user-actions">
          <template v-if="!isLoggedIn">
            <el-button type="primary" size="large" @click="handleLogin">登录</el-button>
            <el-button type="default" size="large" @click="handleRegister">注册</el-button>
          </template>
          <template v-else>
            <el-dropdown @command="handleUserCommand" class="user-dropdown">
              <div class="user-info">
                <el-avatar :size="36" :src="userInfo.avatar" :icon="User" />
                <span class="username">{{ userInfo.username }}</span>
                <el-icon><ArrowDown /></el-icon>
              </div>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="profile">
                    <el-icon><User /></el-icon>个人中心
                  </el-dropdown-item>
                  <el-dropdown-item command="orders">
                    <el-icon><Document /></el-icon>我的订单
                  </el-dropdown-item>
                  <el-dropdown-item command="favorites">
                    <el-icon><Star /></el-icon>我的收藏
                  </el-dropdown-item>
                  <el-dropdown-item divided command="logout">
                    <el-icon><SwitchButton /></el-icon>退出登录
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </div>
      </div>
    </header>
    
    <!-- 主内容区 -->
    <main class="main-content">
      <router-view></router-view>
    </main>
    
    <!-- 底部 -->
    <footer class="footer">
      <div class="footer-content">
        <div class="footer-section">
          <h3>家政服务平台</h3>
          <p>专业的家政服务管理系统</p>
        </div>
        <div class="footer-section">
          <h4>快速链接</h4>
          <ul>
            <li><a href="/">首页</a></li>
            <li><a href="/services">服务分类</a></li>
            <li><a href="/orders">我的订单</a></li>
            <li><a href="/profile">个人中心</a></li>
          </ul>
        </div>
        <div class="footer-section">
          <h4>联系我们</h4>
          <p>电话：400-123-4567</p>
          <p>邮箱：service@jiazheng.com</p>
        </div>
        <div class="footer-section">
          <h4>关于我们</h4>
          <p>致力于提供优质的家政服务</p>
        </div>
      </div>
      <div class="footer-bottom">
        <p>&copy; 2026 家政服务平台 版权所有</p>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { House, Grid, Document, User, TrendCharts, ArrowDown, Star, SwitchButton } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const isLoggedIn = ref(false)
const userInfo = ref({
  username: '',
  avatar: ''
})

const activeMenu = computed(() => {
  return route.path
})

// 检查登录状态
const checkLoginStatus = () => {
  const token = localStorage.getItem('token')
  const user = localStorage.getItem('user')
  if (token && user) {
    isLoggedIn.value = true
    userInfo.value = JSON.parse(user)
  } else {
    isLoggedIn.value = false
    userInfo.value = { username: '', avatar: '' }
  }
}

const handleMenuSelect = (index) => {
  router.push(index)
}

const handleLogin = () => {
  router.push('/login')
}

const handleRegister = () => {
  router.push('/register')
}

const handleUserCommand = (command) => {
  switch (command) {
    case 'profile':
      router.push('/profile')
      break
    case 'orders':
      router.push('/orders')
      break
    case 'favorites':
      router.push('/profile?tab=favorites')
      break
    case 'logout':
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      isLoggedIn.value = false
      userInfo.value = { username: '', avatar: '' }
      ElMessage.success('退出登录成功')
      router.push('/')
      break
  }
}

onMounted(() => {
  checkLoginStatus()
  // 监听登录事件
  window.addEventListener('storage', checkLoginStatus)
  // 监听路由变化时检查登录状态
  router.afterEach(() => {
    checkLoginStatus()
  })
})
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', Arial, sans-serif;
}

#app {
  min-height: 100vh;
}

.app-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* 头部导航栏 */
.header {
  background: white;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  width: 100%;
}

.header-content {
  max-width: 100%;
  margin: 0;
  padding: 0 40px;
  height: 60px;
  display: flex;
  align-items: center;
  gap: 40px;
  width: 100%;
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 20px;
  font-weight: bold;
  color: #333;
  cursor: pointer;
  transition: all 0.3s;
}

.logo:hover {
  color: #409EFF;
}

.search-section {
  flex: 1;
  max-width: 500px;
}

.search-input {
  width: 100%;
}

.nav-menu {
  flex: 1;
}

.menu {
  border: none;
  background: transparent;
}

.menu .el-menu-item {
  font-size: 16px;
  height: 60px;
  line-height: 60px;
  padding: 0 20px;
  color: #606266;
  transition: all 0.3s;
  border: none;
  background: transparent;
}

.menu .el-menu-item:hover {
  color: #409EFF;
  background: transparent;
}

.menu .el-menu-item.is-active {
  color: #409EFF;
  background: transparent;
  border-bottom: 2px solid #409EFF;
}

.user-actions {
  display: flex;
  gap: 16px;
  align-items: center;
}

.user-dropdown {
  cursor: pointer;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 8px;
  border-radius: 20px;
  transition: all 0.3s;
}

.user-info:hover {
  background: #f5f7fa;
}

.user-info .username {
  font-size: 14px;
  color: #606266;
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* 主内容区 */
.main-content {
  flex: 1;
  background: #f0f2f5;
  padding: 80px 40px 40px;
}

/* 底部 */
.footer {
  background: #1a1a1a;
  color: white;
  padding: 40px 0;
  margin-top: auto;
}

.footer-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 40px;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 40px;
}

.footer-section h3 {
  font-size: 20px;
  margin-bottom: 16px;
  color: #409EFF;
}

.footer-section h4 {
  font-size: 16px;
  margin-bottom: 16px;
  color: #bfcbd9;
}

.footer-section p {
  color: #909399;
  line-height: 1.6;
}

.footer-section ul {
  list-style: none;
}

.footer-section ul li {
  margin-bottom: 8px;
}

.footer-section ul li a {
  color: #909399;
  text-decoration: none;
  transition: color 0.3s;
}

.footer-section ul li a:hover {
  color: #409EFF;
}

.footer-bottom {
  text-align: center;
  padding-top: 24px;
  margin-top: 24px;
  border-top: 1px solid #303133;
  color: #606266;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .header-content {
    padding: 0 20px;
    gap: 20px;
  }
  
  .main-content {
    padding: 20px;
  }
}

@media (max-width: 768px) {
  .header-content {
    flex-wrap: wrap;
    height: auto;
    padding: 16px 20px;
  }
  
  .search-section {
    order: 3;
    width: 100%;
    max-width: none;
  }
  
  .nav-menu {
    order: 2;
  }
  
  .user-actions {
    order: 1;
  }
}
</style>
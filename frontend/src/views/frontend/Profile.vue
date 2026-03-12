<template>
  <div class="profile-root">
    <div class="profile-page">
      <div class="main-content">
        <div class="page-header">
          <h1>个人中心</h1>
          <p>管理您的个人信息和设置</p>
        </div>

        <div class="profile-layout">
          <div class="sidebar" style="width: 280px;">
            <div class="user-card">
              <div class="avatar-wrap" @click="openAvatarDialog">
                <el-avatar :size="100" :src="userInfo.avatar">
                  {{ userInfo.username?.charAt(0) }}
                </el-avatar>
                <span class="avatar-edit-tip">点击修改头像</span>
              </div>
              <h3>{{ userInfo.username }}</h3>
              <p>{{ userInfo.phone || userInfo.email || '—' }}</p>
            </div>
          
          <el-menu
            :default-active="activeMenu"
            @select="handleMenuSelect"
            class="profile-menu"
          >
            <el-menu-item index="info">
              <el-icon><User /></el-icon>
              <span>个人信息</span>
            </el-menu-item>
            <el-menu-item index="orders">
              <el-icon><Document /></el-icon>
              <span>历史订单</span>
            </el-menu-item>
            <el-menu-item index="favorites">
              <el-icon><Star /></el-icon>
              <span>收藏的家政人员</span>
            </el-menu-item>
            <el-menu-item index="password">
              <el-icon><Lock /></el-icon>
              <span>修改密码</span>
            </el-menu-item>
          </el-menu>
        </div>

        <div class="content-area">
          <div v-if="activeMenu === 'info'" class="info-section">
            <h2>个人信息</h2>
            <el-form :model="userInfo" label-width="120px" class="profile-form">
              <el-form-item label="用户名">
                <el-input v-model="userInfo.username" disabled />
              </el-form-item>
              <el-form-item label="邮箱">
                <el-input v-model="userInfo.email" />
              </el-form-item>
              <el-form-item label="手机号">
                <el-input v-model="userInfo.phone" />
              </el-form-item>
              <el-form-item label="姓名">
                <el-input v-model="userInfo.name" placeholder="请输入姓名" />
              </el-form-item>
              <el-form-item label="所在地区">
                <div class="region-row">
                  <el-cascader
                    ref="regionCascaderRef"
                    v-model="region"
                    :options="regionOptions"
                    placeholder="请选择省 / 市 / 区"
                    clearable
                    style="flex: 1"
                    @change="handleRegionChange"
                  />
                </div>
              </el-form-item>
              <el-form-item label="详细地址">
                <el-input v-model="detailAddress" placeholder="如街道、小区、楼栋门牌号等" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" size="large" @click="handleUpdateInfo">保存修改</el-button>
              </el-form-item>
            </el-form>
          </div>

          <div v-else-if="activeMenu === 'orders'" class="orders-section">
            <h2>历史订单</h2>
            <div v-if="historyOrders.length === 0" class="empty-container">
              <el-empty description="暂无历史订单">
                <el-button type="primary" @click="$router.push('/services')">去预约服务</el-button>
              </el-empty>
            </div>
            <div v-else class="order-list">
              <div v-for="order in historyOrders" :key="order.id" class="order-item">
                <div class="order-header">
                  <span class="order-no">订单号：{{ order.orderNo || order.id }}</span>
                  <el-tag :type="getStatusType(order.status)">{{ order.status }}</el-tag>
                </div>
                <div class="order-body">
                  <div class="worker-info">
                    <el-avatar :size="60" :src="order.workerAvatar || getAvatar(order.workerName)">
                      {{ order.workerName?.charAt(0) }}
                    </el-avatar>
                    <div class="worker-details">
                      <h4>{{ order.workerName }}</h4>
                      <p>{{ order.serviceName || order.serviceType }}</p>
                      <p class="order-time">{{ order.createTime || order.createdAt }}</p>
                    </div>
                  </div>
                  <div class="order-amount">¥{{ order.amount || order.totalAmount }}</div>
                </div>
                <div class="order-footer">
                  <div class="order-actions">
                    <el-button 
                      v-if="order.status === '已完成' && !order.reviewed" 
                      type="primary" 
                      size="small" 
                      @click="handleReview(order)"
                    >
                      评价
                    </el-button>
                    <el-button 
                      v-if="order.status === '已完成' && order.reviewed" 
                      type="success" 
                      size="small" 
                      disabled
                    >
                      已评价
                    </el-button>
                    <el-button size="small" @click="$router.push(`/worker/${order.workerId}`)">再次预约</el-button>
                    <el-button type="danger" size="small" plain @click="handleDeleteOrder(order)">删除</el-button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div v-else-if="activeMenu === 'favorites'" class="favorites-section">
            <h2>收藏的家政人员</h2>
            <div v-if="favoriteWorkers.length === 0" class="empty-container">
              <el-empty description="暂无收藏的家政人员">
                <el-button type="primary" @click="$router.push('/services')">去发现</el-button>
              </el-empty>
            </div>
            <div v-else class="worker-grid">
              <div v-for="worker in favoriteWorkers" :key="worker.id" class="worker-card" @click="showWorkerDetail(worker)">
                <el-image :src="worker.avatar" :alt="worker.name" class="worker-avatar" fit="cover">
                  <template #error>
                    <div class="image-error"><el-icon :size="40"><User /></el-icon></div>
                  </template>
                </el-image>
                <div class="worker-info">
                  <h4>{{ worker.name }}</h4>
                  <p>从业{{ worker.experience }}年</p>
                  <el-rate v-model="worker.rating" disabled show-score text-color="#ff9900" score-template="{value}分"></el-rate>
                  <p class="worker-price">¥{{ worker.price }}/小时</p>
                  <el-button type="danger" size="small" @click.stop="handleRemoveFavorite(worker.id)">取消收藏</el-button>
                </div>
              </div>
            </div>
          </div>

          <div v-else-if="activeMenu === 'password'" class="password-section">
            <h2>修改密码</h2>
            <el-form :model="passwordForm" :rules="passwordRules" ref="passwordFormRef" label-width="120px" class="password-form">
              <el-form-item label="原密码" prop="oldPassword">
                <el-input v-model="passwordForm.oldPassword" type="password" show-password placeholder="请输入原密码" />
              </el-form-item>
              <el-form-item label="新密码" prop="newPassword">
                <el-input v-model="passwordForm.newPassword" type="password" show-password placeholder="请输入新密码" />
              </el-form-item>
              <el-form-item label="确认密码" prop="confirmPassword">
                <el-input v-model="passwordForm.confirmPassword" type="password" show-password placeholder="请再次输入新密码" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" size="large" @click="handleUpdatePassword">确认修改</el-button>
                <el-button size="large" @click="resetPasswordForm">重置</el-button>
              </el-form-item>
            </el-form>
          </div>
        </div>
      </div>

        <!-- 修改头像弹窗（el-upload：before-upload 校验，http-request 自定义上传，on-success 更新头像） -->
        <el-dialog v-model="showAvatarDialog" title="修改头像" width="400px" @closed="onAvatarDialogClosed">
        <el-upload
          class="avatar-uploader"
          action="#"
          :show-file-list="false"
          :before-upload="beforeAvatarUpload"
          :http-request="customAvatarUpload"
          :on-success="handleAvatarSuccess"
          :on-error="handleAvatarError"
          accept="image/jpeg,image/png,image/webp,image/gif"
        >
          <img v-if="avatarForm" :src="avatarForm" class="avatar-uploader-img" />
          <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
        </el-upload>
        <div class="avatar-upload-hint">支持 JPG/PNG/WebP，大小不超过 2MB</div>

        <el-input v-model="avatarFormUrl" placeholder="或输入头像图片链接（URL）" clearable class="avatar-url-input" />
        <template #footer>
          <el-button @click="showAvatarDialog = false">取消</el-button>
          <el-button type="primary" @click="handleSaveAvatarUrl" :loading="avatarSaving">使用上面链接</el-button>
        </template>
        </el-dialog>
      </div>
    </div>

    <!-- 评价对话框 -->
    <el-dialog v-model="showReviewDialog" title="评价家政人员" width="500px">
    <div class="review-dialog-content">
      <div class="rating-section">
        <span class="rating-label">总体评分</span>
        <el-rate v-model="reviewForm.rating" :max="5" show-score />
      </div>
      <div class="tags-section">
        <span class="tags-label">服务标签（可多选）</span>
        <div class="tags-list">
          <el-check-tag 
            v-for="tag in reviewTags" 
            :key="tag"
            :checked="reviewForm.tags.includes(tag)"
            @change="(checked) => {
              if (checked) {
                reviewForm.tags.push(tag)
              } else {
                reviewForm.tags = reviewForm.tags.filter(t => t !== tag)
              }
            }"
          >
            {{ tag }}
          </el-check-tag>
        </div>
      </div>
      <div class="content-section">
        <span class="content-label">评价内容</span>
        <el-input
          v-model="reviewForm.content"
          type="textarea"
          :rows="4"
          placeholder="请分享您的服务体验，帮助其他用户更好地了解这位家政人员..."
          maxlength="200"
          show-word-limit
        />
      </div>
    </div>
    <template #footer>
      <el-button @click="showReviewDialog = false">取消</el-button>
      <el-button type="primary" @click="submitReview">提交评价</el-button>
    </template>
    </el-dialog>

    <!-- 家政人员详情对话框 -->
    <el-dialog 
      v-model="detailDialogVisible" 
      :title="currentWorker?.name" 
      width="700px" 
      class="worker-detail-dialog"
      :close-on-click-modal="false"
      :destroy-on-close="true"
    >
      <div v-if="currentWorker" class="detail-content">
      <div class="detail-header">
        <img :src="getAvatar(currentWorker)" :alt="currentWorker.name" class="detail-avatar">
        <div class="detail-info">
          <h3>{{ currentWorker.name }}</h3>
          <div class="detail-meta">
            <el-tag :type="currentWorker.status === 'available' ? 'success' : 'info'">
              {{ currentWorker.status === 'available' ? '可预约' : '休息中' }}
            </el-tag>
            <span class="experience">从业{{ currentWorker.experience }}年</span>
            <span class="age">{{ currentWorker.age }}岁</span>
          </div>
        </div>
      </div>

      <el-divider />

      <div class="detail-body">
        <div class="detail-section">
          <h4>基本信息</h4>
          <div class="info-grid">
            <div class="info-item">
              <span class="label">年龄</span>
              <span class="value">{{ currentWorker.age }}岁</span>
            </div>
            <div class="info-item">
              <span class="label">联系电话</span>
              <span class="value">{{ currentWorker.phone }}</span>
            </div>
            <div class="info-item">
              <span class="label">从业经验</span>
              <span class="value">{{ currentWorker.experience }}年</span>
            </div>
            <div class="info-item">
              <span class="label">服务价格</span>
              <span class="value price">¥{{ currentWorker.price }}/小时</span>
            </div>
          </div>
        </div>

        <div class="detail-section">
          <h4>服务评价</h4>
          <div class="rating-display">
            <el-rate v-model="currentWorker.rating" disabled show-score text-color="#ff9900" score-template="{value}分" />
            <span class="order-count">已服务 {{ Math.floor(Math.random() * 100) + 1 }} 单</span>
          </div>
        </div>

        <div class="detail-section">
          <h4>个人简介</h4>
          <p class="description">{{ currentWorker.description || getWorkerDescription(currentWorker) }}</p>
        </div>

        <div class="detail-section">
          <h4>服务标签</h4>
          <div class="tags-container">
            <el-tag v-if="currentWorker.categoryId === 1" type="success">保洁服务</el-tag>
            <el-tag v-else-if="currentWorker.categoryId === 2" type="success">月嫂服务</el-tag>
            <el-tag v-else-if="currentWorker.categoryId === 3" type="success">护理服务</el-tag>
            <el-tag v-else-if="currentWorker.categoryId === 4" type="success">钟点工</el-tag>
            <el-tag type="primary">经验丰富</el-tag>
            <el-tag type="warning">专业服务</el-tag>
            <el-tag type="info">态度亲切</el-tag>
          </div>
        </div>
      </div>
    </div>
    <template #footer>
      <el-button @click="detailDialogVisible = false">关闭</el-button>
      <el-button type="primary" @click="goToDetailPage">查看完整详情</el-button>
      <el-button type="success" @click="goToBooking(currentWorker.id)">立即预约</el-button>
    </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { User, Document, Star, Lock, Plus } from '@element-plus/icons-vue'
import { getUserInfo, getOrders, createReview, getUserFavorites, removeFavorite, changePassword, updateUserInfo, deleteOrder, uploadImage } from '../../api'
import { regionData } from 'element-china-area-data'

const router = useRouter()
const activeMenu = ref('info')
const userInfo = ref({
  userId: null,
  username: '',
  name: '',
  phone: '',
  email: '',
  address: '',
  avatar: ''
})

// 省 / 市 / 区 级联选择（全国数据）
const region = ref([])
const detailAddress = ref('')
// element-china-area-data 的 regionData 已经包含全国省市区，直接作为 options 使用
const regionOptions = ref(regionData)
const regionCascaderRef = ref(null)

const historyOrders = ref([])
const favoriteWorkers = ref([])
const showAvatarDialog = ref(false)
const avatarForm = ref('')
const avatarFormUrl = ref('')
const avatarSaving = ref(false)

const passwordForm = ref({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const passwordFormRef = ref(null)

const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入原密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== passwordForm.value.newPassword) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

const locatingRegion = ref(false)

const loadUserInfo = async () => {
  try {
    const res = await getUserInfo()
    const info = (res && res.data != null) ? res.data : (res && typeof res === 'object' ? res : null)
    if (info && typeof info === 'object') {
      const empty = (v) => (v == null || v === undefined ? '' : String(v))
      userInfo.value = {
        userId: info.userId ?? info.id ?? userInfo.value.userId,
        username: empty(info.username),
        name: empty(info.name),
        phone: empty(info.phone),
        email: empty(info.email),
        address: empty(info.address),
        avatar: empty(info.avatar)
      }
      // 先把整串地址放到详细地址，后续如果用户点击定位再用百度结果覆盖
      detailAddress.value = userInfo.value.address || ''
      region.value = []
    }
  } catch (error) {
    console.error('加载用户信息失败:', error)
  }
}

// 当选择省 / 市 / 区时，把节点的中文名称同步到“详细地址”中
const handleRegionChange = () => {
  const cascader = regionCascaderRef.value
  if (!cascader || !cascader.getCheckedNodes) return
  const nodes = cascader.getCheckedNodes()
  if (!nodes || nodes.length === 0) return
  const labels = nodes[0].pathLabels || []
  const regionText = labels.join(' ')

  // 每次选择区域时，直接用最新的区域名称覆盖“详细地址”中的区域部分
  detailAddress.value = regionText
}

const handleMenuSelect = (index) => {
  activeMenu.value = index
}

const openAvatarDialog = () => {
  const current = userInfo.value.avatar || ''
  avatarForm.value = current ? (current.startsWith('http') || current.startsWith('/') ? current : '') : ''
  avatarFormUrl.value = avatarForm.value
  showAvatarDialog.value = true
}

const onAvatarDialogClosed = () => {
  if (avatarForm.value && avatarForm.value.startsWith('blob:')) {
    URL.revokeObjectURL(avatarForm.value)
  }
  avatarForm.value = ''
  avatarFormUrl.value = ''
}

// 将最新的用户信息同步到本地存储，便于 App.vue 头部头像和用户名实时更新
const syncUserToLocalStorage = (patch) => {
  try {
    const raw = localStorage.getItem('user')
    const current = raw ? JSON.parse(raw) : {}
    const updated = { ...current, ...patch }
    localStorage.setItem('user', JSON.stringify(updated))
    // 主动触发 storage 事件，让 App.vue 中的监听逻辑立即生效
    window.dispatchEvent(
      new StorageEvent('storage', { key: 'user', newValue: JSON.stringify(updated) })
    )
  } catch (e) {
    console.error('同步用户信息到本地失败:', e)
  }
}

/** 上传前校验：格式与大小 */
const beforeAvatarUpload = (file) => {
  const isJPG = file.type === 'image/jpeg'
  const isPNG = file.type === 'image/png'
  const isWebP = file.type === 'image/webp'
  const isGIF = file.type === 'image/gif'
  const isImage = isJPG || isPNG || isWebP || isGIF
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('上传头像只能是 JPG/PNG/WebP/GIF 格式!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('上传头像大小不能超过 2MB!')
    return false
  }
  return true
}

/** 自定义上传：走后端 /api/upload/image，成功后由 on-success 更新用户头像 */
const customAvatarUpload = async (options) => {
  try {
    const res = await uploadImage(options.file)
    if (res && res.code === 200 && res.data) {
      options.onSuccess(res)
    } else {
      options.onError(new Error(res?.message || '上传失败'))
    }
  } catch (error) {
    options.onError(error)
  }
}

/** 文件上传成功时的钩子：预览 + 把图片地址保存到用户信息 */
const handleAvatarSuccess = async (res, file) => {
  avatarForm.value = URL.createObjectURL(file.raw)
  const path = res.data
  const avatarUrl = path.startsWith('/') ? path : '/' + path
  avatarSaving.value = true
  try {
    const updateRes = await updateUserInfo({ avatar: avatarUrl })
    if (updateRes && updateRes.code === 200) {
      userInfo.value.avatar = avatarUrl
      if (updateRes.data) userInfo.value = { ...userInfo.value, ...updateRes.data }
      syncUserToLocalStorage({ avatar: userInfo.value.avatar })
      ElMessage.success('头像已更新')
      showAvatarDialog.value = false
    } else {
      ElMessage.error(updateRes?.message || '保存头像地址失败')
    }
  } catch (error) {
    const msg = error?.response?.data?.message || error?.message || '更新头像失败'
    ElMessage.error(msg)
  } finally {
    avatarSaving.value = false
  }
}

const handleAvatarError = () => {
  ElMessage.error('图片上传失败，请重试')
}

/** 使用输入的链接作为头像 */
const handleSaveAvatarUrl = async () => {
  const url = (avatarFormUrl.value || '').trim()
  if (!url) {
    ElMessage.warning('请输入头像链接或先上传本地图片')
    return
  }
  avatarSaving.value = true
  try {
    const res = await updateUserInfo({ avatar: url })
    if (res && res.code === 200) {
      userInfo.value.avatar = url
      if (res.data) userInfo.value = { ...userInfo.value, ...res.data }
      syncUserToLocalStorage({ avatar: userInfo.value.avatar })
      ElMessage.success('头像已更新')
      showAvatarDialog.value = false
    } else {
      ElMessage.error(res?.message || '更新失败')
    }
  } catch (error) {
    const msg = error?.response?.data?.message || error?.message || '更新头像失败'
    ElMessage.error(msg)
  } finally {
    avatarSaving.value = false
  }
}

const handleUpdateInfo = async () => {
  try {
    // 保存时优先使用级联选择的中文名称作为区域前缀
    let regionText = ''
    const cascader = regionCascaderRef.value
    if (cascader && cascader.getCheckedNodes) {
      const nodes = cascader.getCheckedNodes()
      if (nodes && nodes.length > 0) {
        const labels = nodes[0].pathLabels || []
        regionText = labels.join(' ')
      }
    }

    // 详细地址中可能已经包含了区域名称，保存时去重
    let extra = detailAddress.value || ''
    if (regionText && extra && extra.startsWith(regionText)) {
      extra = extra.slice(regionText.length).trim()
    }

    const address = regionText
      ? `${regionText}${extra ? ' ' + extra : ''}`
      : extra

    const res = await updateUserInfo({
      name: userInfo.value.name,
      phone: userInfo.value.phone,
      email: userInfo.value.email,
      address
    })
    if (res && res.code === 200) {
      ElMessage.success(res.message || '保存成功')
      if (res.data) {
        userInfo.value = { ...userInfo.value, ...res.data, address }
      }
      syncUserToLocalStorage({
        username: userInfo.value.username,
        name: userInfo.value.name,
        phone: userInfo.value.phone,
        email: userInfo.value.email,
        avatar: userInfo.value.avatar,
        address
      })
    } else {
      ElMessage.error(res?.message || '保存失败')
    }
  } catch (error) {
    const msg = error?.response?.data?.message || error?.message || '更新个人信息失败'
    ElMessage.error(msg)
  }
}

// 已不再使用定位按钮，这里的 locatingRegion 仅保留占位，后续如需再开定位功能可复用

const handleUpdatePassword = async () => {
  try {
    await passwordFormRef.value.validate()
    const res = await changePassword({
      oldPassword: passwordForm.value.oldPassword,
      newPassword: passwordForm.value.newPassword
    })
    if (res && res.code === 200) {
      ElMessage.success(res.message || '密码修改成功，请重新登录')
      resetPasswordForm()
      localStorage.removeItem('token')
      setTimeout(() => {
        router.push('/login')
      }, 1500)
    } else {
      ElMessage.error(res?.message || '修改失败')
    }
  } catch (error) {
    const status = error?.response?.status
    let msg = error?.response?.data?.message || error?.message || '修改密码失败'
    if (status === 404) {
      msg = '修改密码接口未找到(404)，请确认后端已启动且地址为 http://localhost:8082'
    }
    ElMessage.error(msg)
  }
}

const resetPasswordForm = () => {
  passwordForm.value = {
    oldPassword: '',
    newPassword: '',
    confirmPassword: ''
  }
  passwordFormRef.value?.resetFields()
}

const handleDeleteOrder = async (order) => {
  try {
    await ElMessageBox.confirm('确定要删除该历史订单吗？删除后不可恢复。', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await deleteOrder(order.id)
    historyOrders.value = historyOrders.value.filter(o => o.id !== order.id)
    ElMessage.success('订单已删除')
  } catch (error) {
    if (error === 'cancel') return
    const msg = error?.response?.data?.message || error?.message || '删除失败'
    ElMessage.error(msg)
  }
}

const handleRemoveFavorite = async (workerId) => {
  try {
    await ElMessageBox.confirm('确定要取消收藏吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    // 调用后端API取消收藏
    await removeFavorite(workerId)
    
    // 从列表中移除
    favoriteWorkers.value = favoriteWorkers.value.filter(w => w.id !== workerId)
    
    ElMessage.success('已取消收藏')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('取消收藏失败:', error)
      ElMessage.error('取消收藏失败')
    }
  }
}

// 加载历史订单
const loadHistoryOrders = async () => {
  try {
    const userId = localStorage.getItem('userId')
    if (!userId) return
    
    const result = await getOrders({ userId, page: 1, pageSize: 100 })
    if (result.code === 200 && result.data) {
      historyOrders.value = result.data.list || []
    }
  } catch (error) {
    console.error('加载历史订单失败:', error)
  }
}

// 加载收藏的家政人员
const loadFavoriteWorkers = async () => {
  try {
    const result = await getUserFavorites()
    if (result.code === 200 && result.data) {
      favoriteWorkers.value = result.data.map(worker => ({
        id: worker.id,
        name: worker.name,
        avatar: worker.avatar,
        experience: worker.experience || 5,
        rating: worker.rating || 4.5,
        price: worker.price || 50
      }))
    } else {
      favoriteWorkers.value = []
    }
  } catch (error) {
    console.error('加载收藏的家政人员失败:', error)
    favoriteWorkers.value = []
  }
}

// 头像生成函数
const getAvatar = (name) => {
  if (!name) return ''
  const colors = ['#E3F2FD', '#E8F5E9', '#FFF3E0', '#FFEBEE', '#F3E5F5', '#E0F2F1', '#FFF8E1', '#E1F5FE']
  const textColors = ['#1976D2', '#388E3C', '#F57C00', '#D32F2F', '#7B1FA2', '#00796B', '#FBC02D', '#0288D1']
  const randomIndex = Math.floor(Math.random() * colors.length)
  const bgColor = colors[randomIndex]
  const textColor = textColors[randomIndex]
  const svg = `
    <svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">
      <rect width="100" height="100" fill="${bgColor}" rx="8"/>
      <text x="50" y="55" font-size="28" fill="${textColor}" text-anchor="middle" dominant-baseline="middle" font-family="Arial, sans-serif" font-weight="bold">${name.substring(0, 3)}</text>
    </svg>
  `
  return `data:image/svg+xml;base64,${btoa(unescape(encodeURIComponent(svg)))}`
}

// 评价订单
const showReviewDialog = ref(false)
const currentOrder = ref(null)
const reviewForm = ref({
  rating: 5,
  content: '',
  tags: []
})
const reviewTags = ['服务态度好', '专业技能强', '准时到达', '清洁彻底', '沟通顺畅', '性价比高']

const handleReview = (order) => {
  currentOrder.value = order
  reviewForm.value = {
    rating: 5,
    content: '',
    tags: []
  }
  showReviewDialog.value = true
}

const detailDialogVisible = ref(false)
const currentWorker = ref(null)

const showWorkerDetail = (worker) => {
  console.log('点击家政人员:', worker)
  currentWorker.value = worker
  detailDialogVisible.value = true
  console.log('对话框状态:', detailDialogVisible.value)
}

const goToDetailPage = () => {
  if (currentWorker.value) {
    router.push(`/worker/${currentWorker.value.id}`)
    detailDialogVisible.value = false
  }
}

const goToBooking = (workerId) => {
  router.push(`/booking?workerId=${workerId}`)
}

const getWorkerDescription = (worker) => {
  const gender = worker.gender || '女'
  const title = gender === '男' ? '师傅' : '阿姨'
  const pronoun = gender === '男' ? '他' : '她'
  return `${worker.name}${title}是一位经验丰富的家政服务人员，从业${worker.experience}年，服务过众多家庭，深受客户好评。${pronoun}擅长各类家政服务，工作认真负责，态度亲切。`
}

const submitReview = async () => {
  try {
    if (!reviewForm.value.content.trim()) {
      ElMessage.warning('请输入评价内容')
      return
    }
    
    // 提交评价到后端
    await createReview({
      orderId: currentOrder.value.id,
      workerId: currentOrder.value.workerId,
      rating: reviewForm.value.rating,
      content: reviewForm.value.content,
      tags: reviewForm.value.tags
    })
    
    // 更新订单状态
    const order = historyOrders.value.find(o => o.id === currentOrder.value.id)
    if (order) {
      order.reviewed = true
    }
    
    showReviewDialog.value = false
    ElMessage.success('评价提交成功！')
  } catch (error) {
    console.error('提交评价失败:', error)
    ElMessage.error('评价提交失败')
  }
}

const getStatusType = (status) => {
  const typeMap = {
    '待接单': 'warning',
    '已接单': 'primary',
    '服务中': 'success',
    '已完成': 'info',
    '已取消': 'danger'
  }
  return typeMap[status] || 'info'
}

onMounted(async () => {
  await loadUserInfo()
  await loadHistoryOrders()
  await loadFavoriteWorkers()
})
</script>

<style scoped>
.profile-page {
  min-height: 100%;
}

.main-content {
  padding: 40px;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-header h1 {
  font-size: 48px;
  margin-bottom: 12px;
  color: #333;
}

.page-header p {
  font-size: 20px;
  color: #666;
}

.profile-layout {
  display: flex;
  gap: 40px;
  margin-top: 40px;
}

.sidebar {
  flex-shrink: 0;
}

.user-card {
  background: white;
  padding: 32px;
  border-radius: 16px;
  text-align: center;
  margin-bottom: 24px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}

.user-card h3 {
  margin: 16px 0 8px 0;
  font-size: 24px;
  color: #333;
}

.user-card p {
  margin: 0;
  color: #666;
  font-size: 16px;
}

.avatar-wrap {
  cursor: pointer;
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.avatar-wrap:hover .avatar-edit-tip {
  opacity: 1;
}

.avatar-edit-tip {
  font-size: 12px;
  color: #909399;
  opacity: 0.7;
}

.avatar-uploader {
  width: 100%;
}
.avatar-uploader :deep(.el-upload) {
  border: 1px dashed #d9d9d9;
  border-radius: 8px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  display: block;
  width: 120px;
  height: 120px;
  margin: 0 auto;
}
.avatar-uploader :deep(.el-upload:hover) {
  border-color: #409EFF;
}
.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 120px;
  height: 120px;
  line-height: 120px;
  text-align: center;
  display: block;
  margin: 0 auto;
}
.avatar-uploader-img {
  width: 120px;
  height: 120px;
  display: block;
  object-fit: cover;
  margin: 0 auto;
}
.avatar-upload-hint {
  margin: 8px 0 10px;
  font-size: 12px;
  color: #909399;
  text-align: center;
}
.avatar-url-input {
  margin-top: 12px;
  width: 100%;
}

.profile-menu {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  border: none;
}

.profile-menu .el-menu-item {
  height: 56px;
  line-height: 56px;
  font-size: 18px;
  margin: 0;
  border-radius: 0;
}

.profile-menu .el-menu-item:hover {
  background: #f5f7fa;
}

.profile-menu .el-menu-item.is-active {
  background: #ecf5ff;
  color: #409EFF;
}

.content-area {
  flex: 1;
  background: white;
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}

.content-area h2 {
  font-size: 32px;
  margin-bottom: 32px;
  color: #333;
}

.profile-form,
.password-form {
  max-width: 600px;
}

.profile-form .el-form-item,
.password-form .el-form-item {
  margin-bottom: 32px;
}

.profile-form .el-input,
.password-form .el-input,
.profile-form .el-date-picker,
.password-form .el-date-picker {
  height: 48px;
}

.empty-container {
  padding: 80px 0;
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.order-item {
  border: 2px solid #f0f0f0;
  border-radius: 12px;
  padding: 24px;
  transition: all 0.3s;
}

.order-item:hover {
  border-color: #409EFF;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.15);
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 2px solid #f0f0f0;
}

.order-no {
  font-size: 16px;
  color: #666;
}

.order-body {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.worker-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.worker-details h4 {
  margin: 0 0 8px 0;
  font-size: 20px;
  color: #333;
}

.worker-details p {
  margin: 0;
  color: #666;
  font-size: 16px;
}

.order-amount {
  font-size: 28px;
  color: #ff6600;
  font-weight: bold;
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 16px;
  border-top: 2px solid #f0f0f0;
}

.order-time {
  color: #999;
  font-size: 14px;
}

.worker-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.worker-card {
  border: 2px solid #f0f0f0;
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s;
}

.worker-card:hover {
  border-color: #409EFF;
  box-shadow: 0 8px 24px rgba(64, 158, 255, 0.2);
  transform: translateY(-4px);
}

.worker-avatar {
  width: 100%;
  height: 240px;
}

.image-error {
  width: 100%;
  height: 240px;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ccc;
}

.worker-info {
  padding: 20px;
}

.worker-info h4 {
  margin: 0 0 8px 0;
  font-size: 20px;
  color: #333;
}

.worker-info p {
  margin: 8px 0;
  color: #666;
  font-size: 16px;
}

.worker-price {
  color: #ff6600;
  font-size: 24px;
  font-weight: bold;
  margin: 8px 0 !important;
}

/* 评价对话框样式 */
.review-dialog-content {
  padding: 20px 0;
}

.rating-section {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
}

.rating-label {
  font-weight: 600;
  color: #303133;
}

.tags-section {
  margin-bottom: 24px;
}

.tags-label {
  display: block;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
}

.tags-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.content-section {
  margin-bottom: 16px;
}

.content-label {
  display: block;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
}

.order-actions {
  display: flex;
  gap: 12px;
}
</style>
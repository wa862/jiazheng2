<template>
  <div class="system-settings">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <h3>系统设置</h3>
          <el-button type="primary" @click="handleSave" :loading="saveLoading">
            <el-icon><Check /></el-icon>
            保存设置
          </el-button>
        </div>
      </template>

      <el-form :model="settings" label-width="150px" class="settings-form">
        <!-- 网站基本信息 -->
        <el-divider content-position="left">网站基本信息</el-divider>
        
        <el-form-item label="网站名称">
          <el-input v-model="settings.siteName" placeholder="请输入网站名称" />
        </el-form-item>
        
        <el-form-item label="网站Logo">
          <el-upload
            class="logo-uploader"
            action="/api/upload"
            :show-file-list="false"
            :on-success="handleLogoUploadSuccess"
            :before-upload="beforeLogoUpload"
          >
            <img v-if="settings.siteLogo" :src="settings.siteLogo" class="logo-preview" />
            <div v-else class="upload-placeholder">
              <el-icon :size="32"><Plus /></el-icon>
              <div class="upload-text">点击上传Logo</div>
            </div>
          </el-upload>
          <el-input v-model="settings.siteLogo" placeholder="或输入Logo URL" style="margin-top: 10px;" />
        </el-form-item>
        
        <el-form-item label="网站描述">
          <el-input v-model="settings.siteDescription" type="textarea" :rows="3" placeholder="请输入网站描述" />
        </el-form-item>
        
        <el-form-item label="联系邮箱">
          <el-input v-model="settings.contactEmail" placeholder="请输入联系邮箱" />
        </el-form-item>
        
        <el-form-item label="客服电话">
          <el-input v-model="settings.contactPhone" placeholder="请输入客服电话" />
        </el-form-item>

        <!-- 功能设置 -->
        <el-divider content-position="left">功能设置</el-divider>
        
        <el-form-item label="用户注册">
          <el-switch v-model="settings.enableRegistration" active-text="开启" inactive-text="关闭" />
        </el-form-item>
        
        <el-form-item label="评价功能">
          <el-switch v-model="settings.enableReview" active-text="开启" inactive-text="关闭" />
        </el-form-item>
        
        <el-form-item label="收藏功能">
          <el-switch v-model="settings.enableFavorite" active-text="开启" inactive-text="关闭" />
        </el-form-item>
        
        <el-form-item label="智能推荐">
          <el-switch v-model="settings.enableRecommendation" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <!-- 订单设置 -->
        <el-divider content-position="left">订单设置</el-divider>
        
        <el-form-item label="最小预约时间">
          <el-input-number v-model="settings.minBookingHours" :min="1" :max="24" />
          <span class="form-hint">小时（最少提前多少小时预约）</span>
        </el-form-item>
        
        <el-form-item label="最大预约时间">
          <el-input-number v-model="settings.maxBookingDays" :min="1" :max="90" />
          <span class="form-hint">天（最多提前多少天预约）</span>
        </el-form-item>
        
        <el-form-item label="取消订单时限">
          <el-input-number v-model="settings.cancelOrderHours" :min="0" :max="48" />
          <span class="form-hint">小时（服务开始前多少小时可取消）</span>
        </el-form-item>

        <!-- 支付设置 -->
        <el-divider content-position="left">支付设置</el-divider>
        
        <el-form-item label="在线支付">
          <el-switch v-model="settings.enableOnlinePayment" active-text="开启" inactive-text="关闭" />
        </el-form-item>
        
        <el-form-item label="货到付款">
          <el-switch v-model="settings.enableCashOnDelivery" active-text="开启" inactive-text="关闭" />
        </el-form-item>

        <!-- 显示设置 -->
        <el-divider content-position="left">显示设置</el-divider>
        
        <el-form-item label="每页显示数量">
          <el-input-number v-model="settings.pageSize" :min="5" :max="50" />
          <span class="form-hint">条（列表每页显示的数据条数）</span>
        </el-form-item>
        
        <el-form-item label="首页推荐数量">
          <el-input-number v-model="settings.homeRecommendationCount" :min="3" :max="12" />
          <span class="form-hint">个（首页「智能推荐」显示数量）</span>
        </el-form-item>

        <!-- 热门家政人员（首页「热门家政人员」区块） -->
        <el-divider content-position="left">热门家政人员</el-divider>
        
        <el-form-item label="展示数量">
          <el-input-number v-model="settings.hotWorkersCount" :min="3" :max="12" />
          <span class="form-hint">个（首页热门家政人员卡片数量）</span>
        </el-form-item>
        
        <el-form-item label="区块标题">
          <el-input v-model="settings.hotWorkersTitle" placeholder="如：热门家政人员" />
        </el-form-item>
        
        <el-form-item label="区块副标题">
          <el-input v-model="settings.hotWorkersSubtitle" placeholder="如：评分最高的优质服务" />
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, Check } from '@element-plus/icons-vue'
import { getSettings, updateSettings } from '@api'

const saveLoading = ref(false)

const settings = ref({
  // 网站基本信息
  siteName: '家政服务平台',
  siteLogo: '',
  siteDescription: '专业家政服务，让生活更美好',
  contactEmail: 'service@jiazheng.com',
  contactPhone: '400-123-4567',
  
  // 功能设置
  enableRegistration: true,
  enableReview: true,
  enableFavorite: true,
  enableRecommendation: true,
  
  // 订单设置
  minBookingHours: 2,
  maxBookingDays: 30,
  cancelOrderHours: 24,
  
  // 支付设置
  enableOnlinePayment: true,
  enableCashOnDelivery: true,
  
  // 显示设置
  pageSize: 10,
  homeRecommendationCount: 4,
  hotWorkersCount: 4,
  hotWorkersTitle: '热门家政人员',
  hotWorkersSubtitle: '评分最高的优质服务'
})

const loadSettings = async () => {
  try {
    const res = await getSettings()
    if (res && res.code === 200 && res.data) {
      settings.value = { ...settings.value, ...res.data }
    }
  } catch (error) {
    console.error('加载设置失败:', error)
  }
}

const handleSave = async () => {
  saveLoading.value = true
  try {
    await updateSettings(settings.value)
    ElMessage.success('设置保存成功')
  } catch (error) {
    console.error('保存设置失败:', error)
    ElMessage.error('保存设置失败')
  } finally {
    saveLoading.value = false
  }
}

const handleLogoUploadSuccess = (response) => {
  if (response.data) {
    settings.value.siteLogo = response.data.url
    ElMessage.success('Logo上传成功')
  } else {
    ElMessage.error('Logo上传失败')
  }
}

const beforeLogoUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('Logo大小不能超过2MB')
    return false
  }
  return true
}

onMounted(() => {
  loadSettings()
})
</script>

<style scoped>
.system-settings {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h3 {
  margin: 0;
}

.settings-form {
  max-width: 800px;
}

.logo-uploader {
  border: 1px dashed #d9d9d9;
  border-radius: 8px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  width: 150px;
  height: 150px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-uploader:hover {
  border-color: #409EFF;
}

.logo-preview {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.upload-placeholder {
  text-align: center;
  color: #8c939d;
}

.upload-text {
  margin-top: 8px;
  font-size: 14px;
}

.form-hint {
  margin-left: 10px;
  color: #909399;
  font-size: 12px;
}

:deep(.el-divider__text) {
  font-size: 16px;
  font-weight: bold;
  color: #303133;
}
</style>

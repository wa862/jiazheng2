<template>
  <admin-layout>
    <div class="settings-page">
      <div class="page-header">
        <h1>系统设置</h1>
        <p>配置平台基础参数和功能开关</p>
      </div>

      <el-row :gutter="20">
        <!-- 左侧：设置分类 -->
        <el-col :span="6">
          <el-card class="menu-card">
            <el-menu
              :default-active="activeMenu"
              @select="handleMenuSelect"
              class="settings-menu"
            >
              <el-menu-item index="basic">
                <el-icon><Setting /></el-icon>
                <span>基础设置</span>
              </el-menu-item>
              <el-menu-item index="security">
                <el-icon><Lock /></el-icon>
                <span>安全设置</span>
              </el-menu-item>
              <el-menu-item index="payment">
                <el-icon><Money /></el-icon>
                <span>支付设置</span>
              </el-menu-item>
              <el-menu-item index="notification">
                <el-icon><Bell /></el-icon>
                <span>通知设置</span>
              </el-menu-item>
              <el-menu-item index="algorithm">
                <el-icon><Cpu /></el-icon>
                <span>算法参数</span>
              </el-menu-item>
            </el-menu>
          </el-card>
        </el-col>

        <!-- 右侧：设置内容 -->
        <el-col :span="18">
          <!-- 基础设置 -->
          <el-card v-if="activeMenu === 'basic'" class="settings-card">
            <template #header>
              <div class="card-header">
                <h3>基础设置</h3>
              </div>
            </template>

            <el-form :model="basicForm" label-width="160px" class="settings-form">
              <el-form-item label="平台名称">
                <el-input v-model="basicForm.platformName" placeholder="请输入平台名称" />
              </el-form-item>

              <el-form-item label="平台Logo">
                <el-upload
                  class="avatar-uploader"
                  action="#"
                  :show-file-list="false"
                  :before-upload="beforeLogoUpload"
                >
                  <img v-if="basicForm.logo" :src="basicForm.logo" class="avatar" />
                  <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
                </el-upload>
              </el-form-item>

              <el-form-item label="客服电话">
                <el-input v-model="basicForm.servicePhone" placeholder="请输入客服电话" />
              </el-form-item>

              <el-form-item label="客服邮箱">
                <el-input v-model="basicForm.serviceEmail" placeholder="请输入客服邮箱" />
              </el-form-item>

              <el-form-item label="平台简介">
                <el-input
                  v-model="basicForm.description"
                  type="textarea"
                  :rows="4"
                  placeholder="请输入平台简介"
                />
              </el-form-item>

              <el-form-item label="ICP备案号">
                <el-input v-model="basicForm.icp" placeholder="请输入ICP备案号" />
              </el-form-item>

              <el-form-item label="平台状态">
                <el-switch
                  v-model="basicForm.status"
                  active-text="正常运行"
                  inactive-text="维护中"
                />
              </el-form-item>

              <el-form-item label="维护提示">
                <el-input
                  v-model="basicForm.maintenanceMessage"
                  type="textarea"
                  :rows="2"
                  placeholder="维护时显示的提示信息"
                  :disabled="basicForm.status"
                />
              </el-form-item>
            </el-form>
          </el-card>

          <!-- 安全设置 -->
          <el-card v-if="activeMenu === 'security'" class="settings-card">
            <template #header>
              <div class="card-header">
                <h3>安全设置</h3>
              </div>
            </template>

            <el-form :model="securityForm" label-width="200px" class="settings-form">
              <el-form-item label="登录密码强度">
                <el-select v-model="securityForm.passwordStrength" style="width: 100%">
                  <el-option label="低（6位以上）" value="low" />
                  <el-option label="中（8位以上，含字母数字）" value="medium" />
                  <el-option label="高（10位以上，含大小写字母、数字、特殊字符）" value="high" />
                </el-select>
              </el-form-item>

              <el-form-item label="登录失败锁定">
                <el-switch v-model="securityForm.loginLockEnabled" />
              </el-form-item>

              <el-form-item label="连续失败次数" v-if="securityForm.loginLockEnabled">
                <el-input-number v-model="securityForm.maxLoginAttempts" :min="3" :max="10" />
                <span class="form-tip">次后锁定账号</span>
              </el-form-item>

              <el-form-item label="锁定时间" v-if="securityForm.loginLockEnabled">
                <el-input-number v-model="securityForm.lockDuration" :min="5" :max="60" />
                <span class="form-tip">分钟</span>
              </el-form-item>

              <el-form-item label="验证码有效期">
                <el-input-number v-model="securityForm.captchaExpire" :min="1" :max="10" />
                <span class="form-tip">分钟</span>
              </el-form-item>

              <el-form-item label="Token有效期">
                <el-input-number v-model="securityForm.tokenExpire" :min="1" :max="24" />
                <span class="form-tip">小时</span>
              </el-form-item>

              <el-form-item label="单点登录">
                <el-switch v-model="securityForm.singleLogin" />
                <span class="form-tip">开启后同一账号只能在一个设备登录</span>
              </el-form-item>

              <el-form-item label="IP白名单">
                <el-switch v-model="securityForm.ipWhitelistEnabled" />
              </el-form-item>

              <el-form-item label="白名单IP列表" v-if="securityForm.ipWhitelistEnabled">
                <el-input
                  v-model="securityForm.ipWhitelist"
                  type="textarea"
                  :rows="3"
                  placeholder="每行一个IP地址，支持通配符*"
                />
              </el-form-item>
            </el-form>
          </el-card>

          <!-- 支付设置 -->
          <el-card v-if="activeMenu === 'payment'" class="settings-card">
            <template #header>
              <div class="card-header">
                <h3>支付设置</h3>
              </div>
            </template>

            <el-form :model="paymentForm" label-width="160px" class="settings-form">
              <el-form-item label="平台抽成比例">
                <el-input-number
                  v-model="paymentForm.commissionRate"
                  :min="0"
                  :max="50"
                  :precision="2"
                />
                <span class="form-tip">%</span>
              </el-form-item>

              <el-form-item label="最低提现金额">
                <el-input-number
                  v-model="paymentForm.minWithdrawal"
                  :min="1"
                  :precision="2"
                />
                <span class="form-tip">元</span>
              </el-form-item>

              <el-form-item label="提现手续费">
                <el-input-number
                  v-model="paymentForm.withdrawalFee"
                  :min="0"
                  :max="10"
                  :precision="2"
                />
                <span class="form-tip">%</span>
              </el-form-item>

              <el-form-item label="订单自动确认">
                <el-input-number v-model="paymentForm.autoConfirmDays" :min="1" :max="30" />
                <span class="form-tip">天后自动确认完成</span>
              </el-form-item>

              <el-form-item label="退款有效期">
                <el-input-number v-model="paymentForm.refundDays" :min="1" :max="30" />
                <span class="form-tip">天内可申请退款</span>
              </el-form-item>

              <el-divider>支付方式配置</el-divider>

              <el-form-item label="微信支付">
                <el-switch v-model="paymentForm.wechatPayEnabled" />
              </el-form-item>

              <template v-if="paymentForm.wechatPayEnabled">
                <el-form-item label="微信AppID">
                  <el-input v-model="paymentForm.wechatAppId" placeholder="请输入微信AppID" />
                </el-form-item>
                <el-form-item label="微信商户号">
                  <el-input v-model="paymentForm.wechatMchId" placeholder="请输入微信商户号" />
                </el-form-item>
                <el-form-item label="API密钥">
                  <el-input v-model="paymentForm.wechatApiKey" type="password" placeholder="请输入API密钥" />
                </el-form-item>
              </template>

              <el-form-item label="支付宝">
                <el-switch v-model="paymentForm.alipayEnabled" />
              </el-form-item>

              <template v-if="paymentForm.alipayEnabled">
                <el-form-item label="支付宝AppID">
                  <el-input v-model="paymentForm.alipayAppId" placeholder="请输入支付宝AppID" />
                </el-form-item>
                <el-form-item label="支付宝公钥">
                  <el-input v-model="paymentForm.alipayPublicKey" type="textarea" :rows="3" placeholder="请输入支付宝公钥" />
                </el-form-item>
                <el-form-item label="应用私钥">
                  <el-input v-model="paymentForm.alipayPrivateKey" type="textarea" :rows="3" placeholder="请输入应用私钥" />
                </el-form-item>
              </template>
            </el-form>
          </el-card>

          <!-- 通知设置 -->
          <el-card v-if="activeMenu === 'notification'" class="settings-card">
            <template #header>
              <div class="card-header">
                <h3>通知设置</h3>
              </div>
            </template>

            <el-form :model="notificationForm" label-width="200px" class="settings-form">
              <el-form-item label="短信通知">
                <el-switch v-model="notificationForm.smsEnabled" />
              </el-form-item>

              <template v-if="notificationForm.smsEnabled">
                <el-form-item label="短信服务商">
                  <el-select v-model="notificationForm.smsProvider" style="width: 100%">
                    <el-option label="阿里云短信" value="aliyun" />
                    <el-option label="腾讯云短信" value="tencent" />
                    <el-option label="网易云信" value="netease" />
                  </el-select>
                </el-form-item>
                <el-form-item label="AccessKey ID">
                  <el-input v-model="notificationForm.smsAccessKey" placeholder="请输入AccessKey ID" />
                </el-form-item>
                <el-form-item label="AccessKey Secret">
                  <el-input v-model="notificationForm.smsSecretKey" type="password" placeholder="请输入AccessKey Secret" />
                </el-form-item>
                <el-form-item label="短信签名">
                  <el-input v-model="notificationForm.smsSign" placeholder="请输入短信签名" />
                </el-form-item>
              </template>

              <el-divider />

              <el-form-item label="邮件通知">
                <el-switch v-model="notificationForm.emailEnabled" />
              </el-form-item>

              <template v-if="notificationForm.emailEnabled">
                <el-form-item label="SMTP服务器">
                  <el-input v-model="notificationForm.smtpHost" placeholder="如：smtp.qq.com" />
                </el-form-item>
                <el-form-item label="SMTP端口">
                  <el-input-number v-model="notificationForm.smtpPort" :min="1" :max="65535" />
                </el-form-item>
                <el-form-item label="发件人邮箱">
                  <el-input v-model="notificationForm.smtpEmail" placeholder="请输入发件人邮箱" />
                </el-form-item>
                <el-form-item label="邮箱密码/授权码">
                  <el-input v-model="notificationForm.smtpPassword" type="password" placeholder="请输入邮箱密码或授权码" />
                </el-form-item>
              </template>

              <el-divider />

              <el-form-item label="订单通知">
                <el-checkbox-group v-model="notificationForm.orderNotifications">
                  <el-checkbox label="new">新订单提醒</el-checkbox>
                  <el-checkbox label="paid">支付成功通知</el-checkbox>
                  <el-checkbox label="completed">订单完成通知</el-checkbox>
                  <el-checkbox label="refund">退款申请通知</el-checkbox>
                </el-checkbox-group>
              </el-form-item>
            </el-form>
          </el-card>

          <!-- 算法参数 -->
          <el-card v-if="activeMenu === 'algorithm'" class="settings-card">
            <template #header>
              <div class="card-header">
                <h3>算法参数设置</h3>
              </div>
            </template>

            <el-form :model="algorithmForm" label-width="200px" class="settings-form">
              <el-form-item label="推荐算法权重">
                <div class="weight-slider">
                  <div class="weight-item">
                    <span class="weight-label">协同过滤</span>
                    <el-slider v-model="algorithmForm.cfWeight" :max="100" show-input />
                  </div>
                  <div class="weight-item">
                    <span class="weight-label">内容推荐</span>
                    <el-slider v-model="algorithmForm.contentWeight" :max="100" show-input />
                  </div>
                  <div class="weight-item">
                    <span class="weight-label">热门推荐</span>
                    <el-slider v-model="algorithmForm.hotWeight" :max="100" show-input />
                  </div>
                </div>
              </el-form-item>

              <el-form-item label="匹配算法参数">
                <div class="match-params">
                  <div class="param-item">
                    <span class="param-label">距离权重</span>
                    <el-slider v-model="algorithmForm.distanceWeight" :max="100" show-input />
                  </div>
                  <div class="param-item">
                    <span class="param-label">评分权重</span>
                    <el-slider v-model="algorithmForm.ratingWeight" :max="100" show-input />
                  </div>
                  <div class="param-item">
                    <span class="param-label">价格权重</span>
                    <el-slider v-model="algorithmForm.priceWeight" :max="100" show-input />
                  </div>
                  <div class="param-item">
                    <span class="param-label">经验权重</span>
                    <el-slider v-model="algorithmForm.experienceWeight" :max="100" show-input />
                  </div>
                </div>
              </el-form-item>

              <el-form-item label="相似度阈值">
                <el-slider v-model="algorithmForm.similarityThreshold" :max="100" show-input />
                <span class="form-tip">低于此阈值不推荐</span>
              </el-form-item>

              <el-form-item label="推荐数量">
                <el-input-number v-model="algorithmForm.recommendationCount" :min="1" :max="50" />
                <span class="form-tip">个</span>
              </el-form-item>

              <el-form-item label="冷启动策略">
                <el-radio-group v-model="algorithmForm.coldStartStrategy">
                  <el-radio label="popular">热门推荐</el-radio>
                  <el-radio label="random">随机推荐</el-radio>
                  <el-radio label="hybrid">混合策略</el-radio>
                </el-radio-group>
              </el-form-item>

              <el-form-item label="算法更新周期">
                <el-input-number v-model="algorithmForm.updateInterval" :min="1" :max="24" />
                <span class="form-tip">小时</span>
              </el-form-item>
            </el-form>
          </el-card>

          <!-- 保存按钮 -->
          <div class="action-buttons">
            <el-button type="primary" size="large" @click="handleSave" :loading="saveLoading">
              <el-icon><Check /></el-icon>
              保存设置
            </el-button>
            <el-button size="large" @click="handleReset">
              <el-icon><RefreshLeft /></el-icon>
              重置
            </el-button>
          </div>
        </el-col>
      </el-row>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import AdminLayout from '@/components/AdminLayout.vue'
import {
  Setting,
  Lock,
  Money,
  Bell,
  Cpu,
  Plus,
  Check,
  RefreshLeft
} from '@element-plus/icons-vue'

// 当前菜单
const activeMenu = ref('basic')

// 保存加载状态
const saveLoading = ref(false)

// 基础设置表单
const basicForm = reactive({
  platformName: '家政服务平台',
  logo: '',
  servicePhone: '400-123-4567',
  serviceEmail: 'service@jiazheng.com',
  description: '基于智能算法的家政服务平台，为您提供优质的家政服务',
  icp: '京ICP备12345678号',
  status: true,
  maintenanceMessage: '系统维护中，请稍后再试'
})

// 安全设置表单
const securityForm = reactive({
  passwordStrength: 'medium',
  loginLockEnabled: true,
  maxLoginAttempts: 5,
  lockDuration: 30,
  captchaExpire: 5,
  tokenExpire: 2,
  singleLogin: false,
  ipWhitelistEnabled: false,
  ipWhitelist: ''
})

// 支付设置表单
const paymentForm = reactive({
  commissionRate: 10,
  minWithdrawal: 100,
  withdrawalFee: 1,
  autoConfirmDays: 7,
  refundDays: 7,
  wechatPayEnabled: true,
  wechatAppId: '',
  wechatMchId: '',
  wechatApiKey: '',
  alipayEnabled: true,
  alipayAppId: '',
  alipayPublicKey: '',
  alipayPrivateKey: ''
})

// 通知设置表单
const notificationForm = reactive({
  smsEnabled: true,
  smsProvider: 'aliyun',
  smsAccessKey: '',
  smsSecretKey: '',
  smsSign: '家政服务',
  emailEnabled: true,
  smtpHost: 'smtp.qq.com',
  smtpPort: 587,
  smtpEmail: '',
  smtpPassword: '',
  orderNotifications: ['new', 'paid', 'completed']
})

// 算法参数表单
const algorithmForm = reactive({
  cfWeight: 40,
  contentWeight: 35,
  hotWeight: 25,
  distanceWeight: 30,
  ratingWeight: 25,
  priceWeight: 25,
  experienceWeight: 20,
  similarityThreshold: 60,
  recommendationCount: 10,
  coldStartStrategy: 'popular',
  updateInterval: 6
})

// 菜单选择
const handleMenuSelect = (index) => {
  activeMenu.value = index
}

// Logo上传前处理
const beforeLogoUpload = (file) => {
  const isJPG = file.type === 'image/jpeg'
  const isPNG = file.type === 'image/png'
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isJPG && !isPNG) {
    ElMessage.error('上传Logo图片只能是 JPG 或 PNG 格式!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('上传Logo图片大小不能超过 2MB!')
    return false
  }

  // 模拟上传成功
  const reader = new FileReader()
  reader.readAsDataURL(file)
  reader.onload = () => {
    basicForm.logo = reader.result
  }
  return false
}

// 保存设置
const handleSave = () => {
  saveLoading.value = true
  setTimeout(() => {
    saveLoading.value = false
    ElMessage.success('设置保存成功')
  }, 1000)
}

// 重置设置
const handleReset = () => {
  ElMessage.confirm('确定要重置当前设置吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    ElMessage.success('设置已重置')
  }).catch(() => {})
}
</script>

<style scoped lang="scss">
.settings-page {
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

.menu-card {
  .settings-menu {
    border-right: none;
  }
}

.settings-card {
  .card-header {
    h3 {
      font-size: 18px;
      font-weight: 600;
      color: #1f2937;
      margin: 0;
    }
  }

  .settings-form {
    max-width: 600px;

    .form-tip {
      margin-left: 12px;
      color: #909399;
      font-size: 13px;
    }

    .avatar-uploader {
      :deep(.el-upload) {
        border: 1px dashed #d9d9d9;
        border-radius: 6px;
        cursor: pointer;
        position: relative;
        overflow: hidden;
        transition: border-color 0.3s;

        &:hover {
          border-color: #409eff;
        }
      }

      .avatar-uploader-icon {
        font-size: 28px;
        color: #8c939d;
        width: 120px;
        height: 120px;
        line-height: 120px;
        text-align: center;
      }

      .avatar {
        width: 120px;
        height: 120px;
        display: block;
        object-fit: contain;
      }
    }

    .weight-slider,
    .match-params {
      width: 100%;

      .weight-item,
      .param-item {
        display: flex;
        align-items: center;
        margin-bottom: 16px;

        .weight-label,
        .param-label {
          width: 100px;
          flex-shrink: 0;
          color: #606266;
        }

        .el-slider {
          flex: 1;
        }
      }
    }
  }
}

.action-buttons {
  margin-top: 24px;
  display: flex;
  gap: 12px;
  justify-content: center;
}

:deep(.el-card__header) {
  border-bottom: 1px solid #e5e7eb;
  padding: 16px 20px;
}

:deep(.el-card__body) {
  padding: 24px;
}

:deep(.el-menu-item) {
  height: 50px;
  line-height: 50px;
  font-size: 14px;

  .el-icon {
    margin-right: 12px;
  }
}
</style>

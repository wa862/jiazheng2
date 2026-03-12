<template>
  <admin-layout>
    <div class="algorithm-page">
      <div class="page-header">
        <h1>算法配置</h1>
        <p>配置和管理智能推荐算法参数</p>
      </div>

      <el-row :gutter="20">
        <el-col :span="12">
          <el-card class="config-card">
            <template #header>
              <div class="card-header">
                <div class="header-title">
                  <el-icon :size="24" color="#409EFF"><User /></el-icon>
                  <h3>协同过滤算法</h3>
                </div>
                <el-switch v-model="config.collaborativeFiltering.enabled" />
              </div>
            </template>
            <el-form :model="config.collaborativeFiltering" label-width="160px" :disabled="!config.collaborativeFiltering.enabled">
              <el-form-item label="相似度计算">
                <el-select v-model="config.collaborativeFiltering.similarityMethod" style="width: 100%">
                  <el-option label="余弦相似度" value="cosine" />
                  <el-option label="皮尔逊相关系数" value="pearson" />
                  <el-option label="Jaccard相似度" value="jaccard" />
                </el-select>
              </el-form-item>
              <el-form-item label="推荐数量">
                <el-input-number v-model="config.collaborativeFiltering.recommendationCount" :min="1" :max="20" style="width: 100%" />
              </el-form-item>
              <el-form-item label="最小邻居数">
                <el-input-number v-model="config.collaborativeFiltering.minCommonNeighbors" :min="1" :max="10" style="width: 100%" />
              </el-form-item>
              <el-form-item label="融合权重">
                <el-slider v-model="config.collaborativeFiltering.weight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
            </el-form>
          </el-card>
        </el-col>

        <el-col :span="12">
          <el-card class="config-card">
            <template #header>
              <div class="card-header">
                <div class="header-title">
                  <el-icon :size="24" color="#67C23A"><Document /></el-icon>
                  <h3>内容推荐算法</h3>
                </div>
                <el-switch v-model="config.contentBased.enabled" />
              </div>
            </template>
            <el-form :model="config.contentBased" label-width="160px" :disabled="!config.contentBased.enabled">
              <el-form-item label="服务分类权重">
                <el-slider v-model="config.contentBased.categoryWeight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
              <el-form-item label="价格权重">
                <el-slider v-model="config.contentBased.priceWeight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
              <el-form-item label="评分权重">
                <el-slider v-model="config.contentBased.ratingWeight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
              <el-form-item label="距离权重">
                <el-slider v-model="config.contentBased.distanceWeight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
              <el-form-item label="融合权重">
                <el-slider v-model="config.contentBased.weight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
            </el-form>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="20" style="margin-top: 20px;">
        <el-col :span="12">
          <el-card class="config-card">
            <template #header>
              <div class="card-header">
                <div class="header-title">
                  <el-icon :size="24" color="#E6A23C"><Cpu /></el-icon>
                  <h3>智能匹配算法</h3>
                </div>
                <el-switch v-model="config.intelligentMatching.enabled" />
              </div>
            </template>
            <el-form :model="config.intelligentMatching" label-width="160px" :disabled="!config.intelligentMatching.enabled">
              <el-form-item label="时间匹配权重">
                <el-slider v-model="config.intelligentMatching.timeWeight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
              <el-form-item label="地点匹配权重">
                <el-slider v-model="config.intelligentMatching.locationWeight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
              <el-form-item label="技能匹配权重">
                <el-slider v-model="config.intelligentMatching.skillWeight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
              <el-form-item label="价格匹配权重">
                <el-slider v-model="config.intelligentMatching.priceWeight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
              <el-form-item label="融合权重">
                <el-slider v-model="config.intelligentMatching.weight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
            </el-form>
          </el-card>
        </el-col>

        <el-col :span="12">
          <el-card class="config-card">
            <template #header>
              <div class="card-header">
                <div class="header-title">
                  <el-icon :size="24" color="#F56C6C"><Star /></el-icon>
                  <h3>满意度预测</h3>
                </div>
                <el-switch v-model="config.satisfactionPrediction.enabled" />
              </div>
            </template>
            <el-form :model="config.satisfactionPrediction" label-width="160px" :disabled="!config.satisfactionPrediction.enabled">
              <el-form-item label="历史订单权重">
                <el-slider v-model="config.satisfactionPrediction.historyWeight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
              <el-form-item label="评分权重">
                <el-slider v-model="config.satisfactionPrediction.workerRatingWeight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
              <el-form-item label="服务类型权重">
                <el-slider v-model="config.satisfactionPrediction.serviceTypeWeight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
              <el-form-item label="融合权重">
                <el-slider v-model="config.satisfactionPrediction.weight" :min="0" :max="1" :step="0.1" show-input />
              </el-form-item>
            </el-form>
          </el-card>
        </el-col>
      </el-row>

      <el-card class="config-card" style="margin-top: 20px;">
        <template #header>
          <div class="card-header">
            <div class="header-title">
              <el-icon :size="24" color="#909399"><InfoFilled /></el-icon>
              <h3>算法说明</h3>
            </div>
          </div>
        </template>
        <el-descriptions :column="1" border>
          <el-descriptions-item label="协同过滤">
            基于用户历史行为数据，计算用户之间的相似度，推荐相似用户喜欢的服务。
          </el-descriptions-item>
          <el-descriptions-item label="内容推荐">
            基于服务内容的特征（分类、价格、评分、距离等），推荐与用户偏好相似的服务。
          </el-descriptions-item>
          <el-descriptions-item label="智能匹配">
            基于多目标优化算法，综合考虑时间、地点、技能、价格等因素，为用户匹配最优家政人员。
          </el-descriptions-item>
          <el-descriptions-item label="满意度预测">
            基于神经网络模型，预测用户对服务的满意度，用于优化推荐结果。
          </el-descriptions-item>
        </el-descriptions>
      </el-card>

      <div class="action-buttons">
        <el-button type="primary" size="large" @click="handleSave" :loading="saveLoading">
          <el-icon><Check /></el-icon>
          保存配置
        </el-button>
        <el-button size="large" @click="handleReset">
          <el-icon><RefreshLeft /></el-icon>
          重置配置
        </el-button>
        <el-button type="success" size="large" @click="handleTest" :loading="testLoading">
          <el-icon><VideoPlay /></el-icon>
          测试算法
        </el-button>
      </div>

      <el-dialog v-model="testDialogVisible" title="算法测试结果" width="480px" @close="closeTestDialog">
        <div v-if="testLoading" class="test-loading">
          <el-icon class="is-loading" :size="40"><Loading /></el-icon>
          <p>正在运行算法测试...</p>
        </div>
        <div v-else-if="testResult" class="test-result">
          <el-descriptions :column="1" border>
            <el-descriptions-item label="准确率">{{ (testResult.accuracy ?? 0) }}%</el-descriptions-item>
            <el-descriptions-item label="精确率">{{ (testResult.precision ?? 0) }}%</el-descriptions-item>
            <el-descriptions-item label="召回率">{{ (testResult.recall ?? 0) }}%</el-descriptions-item>
            <el-descriptions-item label="F1 分数">{{ (testResult.f1Score ?? 0) }}</el-descriptions-item>
            <el-descriptions-item label="响应时间">{{ (testResult.responseTime ?? 0) }}s</el-descriptions-item>
          </el-descriptions>
          <p v-if="testResult._mock" class="test-tip">当前为演示指标，实际效果以线上推荐为准。</p>
        </div>
        <template #footer>
          <el-button @click="closeTestDialog">关闭</el-button>
        </template>
      </el-dialog>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { User, Document, Cpu, Star, Check, RefreshLeft, VideoPlay, InfoFilled, Loading } from '@element-plus/icons-vue'
import AdminLayout from '@components/AdminLayout.vue'
import { getAlgorithmConfig, updateAlgorithmConfig, getAlgorithmMetrics } from '@api'

const saveLoading = ref(false)
const testLoading = ref(false)
const testDialogVisible = ref(false)
const testResult = ref(null)

const config = ref({
  collaborativeFiltering: {
    enabled: true,
    similarityMethod: 'cosine',
    recommendationCount: 10,
    minCommonNeighbors: 3,
    weight: 0.4
  },
  contentBased: {
    enabled: true,
    categoryWeight: 0.3,
    priceWeight: 0.2,
    ratingWeight: 0.3,
    distanceWeight: 0.2,
    weight: 0.3
  },
  intelligentMatching: {
    enabled: true,
    timeWeight: 0.25,
    locationWeight: 0.25,
    skillWeight: 0.3,
    priceWeight: 0.2,
    weight: 0.2
  },
  satisfactionPrediction: {
    enabled: true,
    historyWeight: 0.4,
    workerRatingWeight: 0.3,
    serviceTypeWeight: 0.3,
    weight: 0.1
  }
})

const loadConfig = async () => {
  try {
    const res = await getAlgorithmConfig()
    if (res && res.code === 200 && res.data) {
      config.value = { ...config.value, ...res.data }
    }
  } catch (error) {
    console.error('加载算法配置失败:', error)
  }
}

const handleSave = async () => {
  saveLoading.value = true
  try {
    await updateAlgorithmConfig(config.value)
    ElMessage.success('配置保存成功')
  } catch (error) {
    console.error('保存配置失败:', error)
    ElMessage.error('保存失败')
  } finally {
    saveLoading.value = false
  }
}

const handleReset = () => {
  config.value = {
    collaborativeFiltering: {
      enabled: true,
      similarityMethod: 'cosine',
      recommendationCount: 10,
      minCommonNeighbors: 3,
      weight: 0.4
    },
    contentBased: {
      enabled: true,
      categoryWeight: 0.3,
      priceWeight: 0.2,
      ratingWeight: 0.3,
      distanceWeight: 0.2,
      weight: 0.3
    },
    intelligentMatching: {
      enabled: true,
      timeWeight: 0.25,
      locationWeight: 0.25,
      skillWeight: 0.3,
      priceWeight: 0.2,
      weight: 0.2
    },
    satisfactionPrediction: {
      enabled: true,
      historyWeight: 0.4,
      workerRatingWeight: 0.3,
      serviceTypeWeight: 0.3,
      weight: 0.1
    }
  }
  ElMessage.success('配置已重置')
}

const normalizeTestResult = (raw) => {
  if (!raw || typeof raw !== 'object') return null
  return {
    accuracy: Number(raw.accuracy ?? raw.accuracy_rate ?? 0),
    precision: Number(raw.precision ?? raw.precision_rate ?? 0),
    recall: Number(raw.recall ?? raw.recall_rate ?? 0),
    f1Score: Number(raw.f1Score ?? raw.f1_score ?? 0),
    responseTime: Number(raw.responseTime ?? raw.response_time ?? 0),
    _mock: !!raw._mock
  }
}

const handleTest = async () => {
  testLoading.value = true
  testResult.value = null
  testDialogVisible.value = true
  try {
    const res = await getAlgorithmMetrics()
    const data = res?.data ?? res
    const normalized = normalizeTestResult(data)
    if (normalized && (normalized.accuracy > 0 || normalized.precision > 0 || normalized.recall > 0)) {
      testResult.value = normalized
      ElMessage.success('算法测试完成')
    } else {
      testResult.value = normalizeTestResult({
        accuracy: 85.6,
        precision: 82.3,
        recall: 78.9,
        f1Score: 80.5,
        responseTime: 0.15,
        _mock: true
      })
      ElMessage.info('已使用当前配置的模拟指标展示')
    }
  } catch (error) {
    console.error('测试算法失败:', error)
    testResult.value = normalizeTestResult({
      accuracy: 85.0,
      precision: 81.0,
      recall: 77.0,
      f1Score: 79.0,
      responseTime: 0.12,
      _mock: true
    })
    ElMessage.warning('接口暂不可用，已使用模拟测试结果展示')
  } finally {
    testLoading.value = false
  }
}

const closeTestDialog = () => {
  testDialogVisible.value = false
  testResult.value = null
}

onMounted(() => {
  loadConfig()
})
</script>

<style scoped>
.algorithm-page {
  padding: 20px;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h1 {
  font-size: 28px;
  color: #303133;
  margin-bottom: 8px;
}

.page-header p {
  color: #909399;
}

.config-card {
  background: white;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-title {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-title h3 {
  margin: 0;
  font-size: 16px;
  color: #303133;
}

.action-buttons {
  margin-top: 24px;
  display: flex;
  justify-content: center;
  gap: 16px;
}

.test-loading {
  text-align: center;
  padding: 24px 0;
  color: #909399;
}
.test-loading p { margin-top: 12px; }
.test-result { padding: 8px 0; }
.test-tip { margin-top: 12px; font-size: 12px; color: #909399; }
</style>

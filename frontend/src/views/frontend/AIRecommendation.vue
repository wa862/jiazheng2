<template>
  <div class="ai-recommendation-page">
    <div class="page-header">
      <div class="header-content">
        <div class="ai-badge">
          <el-icon :size="24"><ChatDotRound /></el-icon>
          <span>AI 驱动</span>
        </div>
        <h1>智能家政助手</h1>
        <p>基于深度学习的家政服务推荐与智能问答系统</p>
      </div>
      <div class="header-stats">
        <div class="stat-item">
          <div class="stat-value">{{ recommendationAccuracy }}%</div>
          <div class="stat-label">推荐准确率</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ userSimilarity }}%</div>
          <div class="stat-label">用户相似度</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ totalRecommendations }}</div>
          <div class="stat-label">今日推荐</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ totalQuestions }}</div>
          <div class="stat-label">已回答问题</div>
        </div>
      </div>
    </div>

    <!-- 智能问答系统 -->
    <div class="ai-qa-section">
      <div class="qa-header">
        <div class="qa-title">
          <el-icon :size="28" color="#409EFF"><ChatDotRound /></el-icon>
          <h2>智能家政问答</h2>
        </div>
        <p class="qa-desc">基于智谱AI的家政服务智能问答系统，为您解答家政相关问题</p>
      </div>

      <div class="qa-container">
        <!-- 问题输入区域 -->
        <div class="qa-input-section">
          <el-form ref="questionFormRef" :model="newQuestion" :rules="questionRules" label-width="120px">
            <el-form-item label="问题分类" prop="type">
              <el-select v-model="newQuestion.type" placeholder="请选择问题分类" style="width: 100%">
                <el-option v-for="category in categories" :key="category.value" :label="category.label" :value="category.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="问题标题" prop="title">
              <el-input v-model="newQuestion.title" placeholder="请输入问题标题" />
            </el-form-item>
            <el-form-item label="问题描述" prop="question">
              <el-input v-model="newQuestion.question" type="textarea" rows="4" placeholder="请详细描述您的问题" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="submitQuestion" :disabled="isSubmitting">
                <el-icon><Plus /></el-icon>
                提交问题
              </el-button>
            </el-form-item>
          </el-form>
        </div>

        <!-- 热门标签 -->
        <div class="qa-tags">
          <span class="tags-title">热门问题标签：</span>
          <el-tag 
            v-for="tag in tags" 
            :key="tag"
            :effect="selectedTags.includes(tag) ? 'dark' : 'plain'"
            @click="toggleTag(tag)"
            class="tag-item"
          >
            {{ tag }}
          </el-tag>
        </div>

        <!-- 问答历史 -->
        <div class="qa-history">
          <div class="history-header">
            <h3>问答历史</h3>
            <el-select v-model="selectedStatus" placeholder="筛选状态" style="width: 150px">
              <el-option label="全部" value="all" />
              <el-option label="已回答" value="answered" />
              <el-option label="未回答" value="unanswered" />
            </el-select>
          </div>

          <div class="questions-list">
            <div 
              v-for="question in filteredQuestions" 
              :key="question.id"
              class="question-item"
            >
              <div class="question-header">
                <h4>{{ question.title }}</h4>
                <el-tag :type="question.answer ? 'success' : 'info'" size="small">
                  {{ question.answer ? '已回答' : '未回答' }}
                </el-tag>
              </div>
              <p class="question-content">{{ question.question }}</p>
              <div class="question-meta">
                <span class="questioner">提问者：{{ question.questioner }}</span>
                <span class="question-time">{{ question.time }}</span>
                <span class="question-type">{{ getCategoryLabel(question.type) }}</span>
              </div>
              <div class="question-actions">
                <el-button type="primary" size="small" @click="likeQuestion(question.id)" :icon="question.liked ? StarFilled : Star">
                  {{ question.likes }}
                </el-button>
                <el-button size="small" @click="showQuestionDetail(question)">
                  <el-icon><ChatDotRound /></el-icon>
                  {{ question.comments }} 评论
                </el-button>
              </div>
              <div v-if="question.answer" class="answer-content">
                <div class="answer-header">
                  <el-icon color="#409EFF"><ChatDotRound /></el-icon>
                  <span>AI 回答</span>
                </div>
                <p>{{ question.answer }}</p>
              </div>
              <div v-else-if="question.isProcessing" class="answer-processing">
                <el-icon><ChatDotRound /></el-icon>
                <span>AI 正在生成答案...</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="recommendation-container">
      <!-- 今日推荐 -->
      <section class="recommendation-section today-section">
        <div class="section-header">
          <div class="section-title">
            <el-icon :size="28" color="#409EFF"><StarFilled /></el-icon>
            <h2>今日为您推荐</h2>
          </div>
          <el-button type="primary" text @click="refreshRecommendations">
            <el-icon><Refresh /></el-icon>
            刷新推荐
          </el-button>
        </div>

        <div class="today-cards">
          <div 
            v-for="(item, index) in todayRecommendations" 
            :key="item.id"
            class="recommendation-card"
            :class="{ 'highlight': index === 0 }"
          >
            <div class="card-header">
              <div class="recommendation-index">#{{ index + 1 }}</div>
              <div class="confidence-badge">
                <el-tag :type="getConfidenceType(item.confidence)" effect="dark">
                  置信度 {{ item.confidence }}%
                </el-tag>
              </div>
            </div>

            <div class="worker-profile">
              <el-avatar :size="80" :src="item.worker.avatar || getAvatar(item.worker.name)" />
              <div class="worker-basic">
                <h3>{{ item.worker.name }}</h3>
                <el-rate v-model="item.worker.rating" disabled show-score />
                <p class="experience">从业{{ item.worker.experience }}年 · {{ item.worker.orderCount }}单</p>
              </div>
            </div>

            <div class="recommendation-reason">
              <div class="reason-title">
                <el-icon><InfoFilled /></el-icon>
                <span>推荐理由</span>
              </div>
              <p>{{ item.reason }}</p>
            </div>

            <div class="weight-contribution">
              <h4>权重贡献分析</h4>
              <div class="weight-chart">
                <div 
                  v-for="(weight, key) in item.weights" 
                  :key="key"
                  class="weight-bar-item"
                >
                  <div class="bar-label">{{ weight.label }}</div>
                  <div class="bar-track">
                    <div 
                      class="bar-fill" 
                      :style="{ width: weight.value + '%', background: weight.color }"
                    />
                  </div>
                  <div class="bar-value">{{ weight.value }}%</div>
                </div>
              </div>
            </div>

            <div class="radar-chart-container">
              <h4>推荐指数雷达图</h4>
              <div ref="radarChart" class="radar-chart"></div>
            </div>

            <div class="card-actions">
              <el-button type="primary" size="large" @click="bookWorker(item.worker)">
                立即预约
              </el-button>
              <el-button size="large" @click="viewDetail(item.worker)">
                查看详情
              </el-button>
            </div>

            <div class="feedback-section">
              <span>推荐是否准确？</span>
              <el-button-group>
                <el-button 
                  :type="item.userFeedback === 'like' ? 'success' : 'default'"
                  @click="feedback(item, 'like')"
                >
                  <el-icon><Thumb /></el-icon>
                  准确
                </el-button>
                <el-button 
                  :type="item.userFeedback === 'dislike' ? 'danger' : 'default'"
                  @click="feedback(item, 'dislike')"
                >
                  <el-icon><CircleClose /></el-icon>
                  不感兴趣
                </el-button>
              </el-button-group>
            </div>
          </div>
        </div>
      </section>

      <!-- 相似用户推荐 -->
      <section class="recommendation-section similar-section">
        <div class="section-header">
          <div class="section-title">
            <el-icon :size="28" color="#67C23A"><UserFilled /></el-icon>
            <h2>相似用户还选择了</h2>
          </div>
          <p class="section-desc">基于协同过滤算法，找到与您兴趣相似的用户群体</p>
        </div>

        <div class="similar-users-info">
          <div class="similarity-visualization">
            <div class="user-node current-user">
              <el-avatar :size="60" src="https://via.placeholder.com/60/409EFF/FFFFFF?text=我" />
              <span>您</span>
            </div>
            <div class="connection-lines">
              <div v-for="i in 3" :key="i" class="connection-line" :style="getLineStyle(i)">
                <span class="similarity-score">{{ 85 + i * 5 }}%</span>
              </div>
            </div>
            <div class="similar-users">
              <div v-for="i in 3" :key="i" class="user-node similar-user">
                <el-avatar :size="50" :src="`https://via.placeholder.com/50/${['67C23A', 'E6A23C', 'F56C6C'][i-1]}/FFFFFF?text=U${i}`" />
                <span>用户{{ i }}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="similar-recommendations">
          <div 
            v-for="item in similarUserRecommendations" 
            :key="item.id"
            class="similar-card"
          >
            <el-avatar :size="60" :src="item.worker.avatar || getAvatar(item.worker.name)" />
            <div class="similar-info">
              <h4>{{ item.worker.name }}</h4>
              <p class="similar-reason">{{ item.reason }}</p>
              <div class="similar-stats">
                <span><el-icon><User /></el-icon> {{ item.similarUsers }}位相似用户选择</span>
                <span><el-icon><Star /></el-icon> {{ item.avgRating }}分</span>
              </div>
            </div>
            <el-button type="primary" @click="bookWorker(item.worker)">预约</el-button>
          </div>
        </div>
      </section>

      <!-- 算法说明 -->
      <section class="algorithm-section">
        <div class="section-header">
          <div class="section-title">
            <el-icon :size="28" color="#E6A23C"><Cpu /></el-icon>
            <h2>推荐算法原理</h2>
          </div>
        </div>

        <div class="algorithm-cards">
          <div class="algo-card">
            <div class="algo-icon">
              <el-icon :size="40" color="#409EFF"><Connection /></el-icon>
            </div>
            <h3>协同过滤</h3>
            <p>基于用户相似度计算，找到与您兴趣相似的用户群体，推荐他们喜欢的服务</p>
            <div class="formula">
              <code>sim(u,v) = Σ(r<sub>u,i</sub> × r<sub>v,i</sub>) / √(Σr²<sub>u,i</sub> × Σr²<sub>v,i</sub>)</code>
            </div>
          </div>

          <div class="algo-card">
            <div class="algo-icon">
              <el-icon :size="40" color="#67C23A"><Document /></el-icon>
            </div>
            <h3>内容推荐</h3>
            <p>分析服务特征向量，计算与用户偏好的相似度，推荐最匹配的服务内容</p>
            <div class="formula">
              <code>sim(u,i) = V<sub>u</sub> · V<sub>i</sub> / (||V<sub>u</sub>|| × ||V<sub>i</sub>||)</code>
            </div>
          </div>

          <div class="algo-card">
            <div class="algo-icon">
              <el-icon :size="40" color="#E6A23C"><DataAnalysis /></el-icon>
            </div>
            <h3>混合融合</h3>
            <p>综合多种推荐结果，通过权重融合生成最终推荐列表</p>
            <div class="formula">
              <code>Score = α×CF + β×Content + γ×NN</code>
            </div>
          </div>
        </div>
      </section>

      <!-- 推荐效果反馈统计 -->
      <section class="feedback-stats-section">
        <div class="section-header">
          <div class="section-title">
            <el-icon :size="28" color="#F56C6C"><TrendCharts /></el-icon>
            <h2>推荐效果反馈</h2>
          </div>
        </div>

        <div class="feedback-charts">
          <div class="chart-card">
            <h4>推荐准确率趋势</h4>
            <div ref="accuracyChart" class="chart-container"></div>
          </div>
          <div class="chart-card">
            <h4>用户满意度分布</h4>
            <div ref="satisfactionChart" class="chart-container"></div>
          </div>
        </div>

        <div class="feedback-summary">
          <div class="summary-item">
            <div class="summary-value">{{ feedbackStats.likes }}</div>
            <div class="summary-label">
              <el-icon color="#67C23A"><CircleCheck /></el-icon>
              推荐准确
            </div>
          </div>
          <div class="summary-item">
            <div class="summary-value">{{ feedbackStats.dislikes }}</div>
            <div class="summary-label">
              <el-icon color="#F56C6C"><CircleClose /></el-icon>
              不感兴趣
            </div>
          </div>
          <div class="summary-item">
            <div class="summary-value">{{ feedbackStats.improvement }}%</div>
            <div class="summary-label">
              <el-icon color="#409EFF"><TrendCharts /></el-icon>
              准确率提升
            </div>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElForm, ElFormItem, ElInput, ElSelect, ElOption, ElButton, ElTag } from 'element-plus'
import * as echarts from 'echarts'
import {
  StarFilled, Refresh, InfoFilled, Thumb,
  CircleClose, UserFilled, User, Star, Cpu,
  Connection, Document, DataAnalysis, TrendCharts,
  CircleCheck, ChatDotRound, Plus
} from '@element-plus/icons-vue'

// 问题分类数据

const router = useRouter()

// 统计数据
const recommendationAccuracy = ref(92.5)
const userSimilarity = ref(87.3)
const totalRecommendations = ref(12)
const totalQuestions = ref(42)

// 问题分类
const categories = [
  { label: '家政服务', value: 'home-service' },
  { label: '清洁技巧', value: 'cleaning-tips' },
  { label: '家电维护', value: 'appliance-maintenance' },
  { label: '育儿护理', value: 'childcare' },
  { label: '老人照护', value: 'elderly-care' },
  { label: '宠物护理', value: 'pet-care' },
  { label: '家居布置', value: 'home-decoration' },
  { label: '其他问题', value: 'other' }
]

// 热门标签
const tags = ['家政服务', '清洁技巧', '家电维护', '育儿护理', '老人照护', '宠物护理', '家居布置']

const STORAGE_KEY = 'ai_qa_questions'

// 默认内置的示例问题（用于首次进入或本地没有历史数据时）
const defaultQuestions = [
  {
    id: 1,
    title: '如何选择合适的家政服务？',
    question: '我需要找一位家政人员来定期打扫卫生，应该如何选择合适的服务？',
    type: 'home-service',
    questioner: '用户1',
    time: '2023-10-15 10:30',
    likes: 25,
    comments: 12,
    liked: false,
    answer: '选择合适的家政服务可以从以下几个方面考虑：1. 明确自己的需求，确定需要哪些具体服务；2. 查看服务提供商的资质和口碑；3. 了解服务人员的经验和背景；4. 比较价格和服务内容；5. 查看是否有服务保障和保险；6. 可以先尝试单次服务，满意后再长期合作。'
  },
  {
    id: 2,
    title: '如何去除顽固污渍？',
    question: '家里的沙发上有顽固的污渍，如何有效去除？',
    type: 'cleaning-tips',
    questioner: '用户2',
    time: '2023-10-10 14:15',
    likes: 38,
    comments: 20,
    liked: true,
    answer: '去除顽固污渍的方法：1. 对于油渍，可以使用洗洁精或专用的 upholstery cleaner；2. 对于酒渍，用冷水冲洗后用白醋和水的混合液擦拭；3. 对于血渍，用冷水冲洗后用蛋白酶清洁剂；4. 对于咖啡渍，用温水和洗洁精混合液擦拭；5. 对于墨水渍，用酒精或专用墨水清洁剂；6. 记得在清洁前先在不显眼的地方测试清洁剂。'
  },
  {
    id: 3,
    title: '冰箱如何正确清洁和维护？',
    question: '冰箱使用一段时间后有异味，如何正确清洁和维护？',
    type: 'appliance-maintenance',
    questioner: '用户3',
    time: '2023-10-05 09:45',
    likes: 18,
    comments: 8,
    liked: false
  },
  {
    id: 4,
    title: '如何培养孩子的良好习惯？',
    question: '我的孩子今年5岁，如何培养他的良好生活习惯？',
    type: 'childcare',
    questioner: '用户4',
    time: '2023-09-28 16:20',
    likes: 42,
    comments: 15,
    liked: false,
    answer: '培养孩子良好习惯的方法：1. 设定明确的规则和时间表；2. 家长以身作则，成为榜样；3. 采用正面激励，及时表扬孩子的好行为；4. 培养孩子的责任感，让他们参与家务；5. 保持耐心，理解孩子的成长过程；6. 建立规律的作息时间；7. 鼓励孩子独立完成任务；8. 与孩子保持良好的沟通，了解他们的想法。'
  },
  {
    id: 5,
    title: '老人照护需要注意哪些事项？',
    question: '家中有老人需要照护，应该注意哪些事项？',
    type: 'elderly-care',
    questioner: '用户5',
    time: '2023-09-20 11:10',
    likes: 22,
    comments: 9,
    liked: false
  }
]

// 从 localStorage 读取历史问题；如果不存在则使用默认示例
const loadInitialQuestions = () => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return [...defaultQuestions]
    const parsed = JSON.parse(raw)
    if (Array.isArray(parsed) && parsed.length > 0) {
      return parsed
    }
    return [...defaultQuestions]
  } catch (e) {
    console.error('加载本地问答历史失败:', e)
    return [...defaultQuestions]
  }
}

const questions = ref(loadInitialQuestions())

// 响应式数据
const searchKeyword = ref('')
const selectedCategories = ref([])
const selectedTags = ref([])
const selectedStatus = ref('all')
const newQuestion = ref({
  title: '',
  question: '',
  type: ''
})
const questionFormRef = ref()
const isSubmitting = ref(false)
const questionRules = {
  title: [
    { required: true, message: '请输入问题标题', trigger: 'blur' },
    { min: 5, max: 100, message: '标题长度在 5 到 100 个字符', trigger: 'blur' }
  ],
  type: [
    { required: true, message: '请选择问题分类', trigger: 'change' }
  ],
  question: [
    { required: true, message: '请输入问题描述', trigger: 'blur' },
    { min: 10, max: 1000, message: '问题描述长度在 10 到 1000 个字符', trigger: 'blur' }
  ]
}

// 过滤后的问题列表
const filteredQuestions = computed(() => {
  return questions.value.filter(question => {
    // 搜索关键词过滤
    const matchesSearch = searchKeyword.value === '' ||
      question.title.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
      question.question.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
      (question.answer && question.answer.toLowerCase().includes(searchKeyword.value.toLowerCase()));

    // 分类过滤
    const matchesCategory = selectedCategories.value.length === 0 ||
      selectedCategories.value.includes(question.type);

    // 状态过滤
    const matchesStatus = selectedStatus.value === 'all' ||
      (selectedStatus.value === 'answered' && question.answer) ||
      (selectedStatus.value === 'unanswered' && !question.answer);

    // 标签过滤 - 这里简化处理，实际项目中应该有标签字段
    const matchesTag = selectedTags.value.length === 0 ||
      selectedTags.value.some(tag =>
        question.title.includes(tag) ||
        question.question.includes(tag) ||
        (question.answer && question.answer.includes(tag))
      );

    return matchesSearch && matchesCategory && matchesStatus && matchesTag;
  });
});

// 将问答历史持久化到 localStorage
const saveQuestionsToStorage = () => {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(questions.value))
  } catch (e) {
    console.error('保存本地问答历史失败:', e)
  }
}

// 今日推荐
const todayRecommendations = ref([
  {
    id: 1,
    confidence: 96,
    worker: {
      id: 101,
      name: '王阿姨',
      avatar: '', // 将使用getAvatar生成
      rating: 4.9,
      experience: 10,
      orderCount: 328
    },
    reason: '根据您的历史订单，您偏好经验丰富的家政人员。王阿姨从业10年，评分4.9，与您需求高度匹配。',
    weights: {
      history: { label: '历史偏好', value: 35, color: '#409EFF' },
      rating: { label: '评分权重', value: 28, color: '#67C23A' },
      experience: { label: '经验权重', value: 22, color: '#E6A23C' },
      similarity: { label: '相似度', value: 15, color: '#F56C6C' }
    },
    userFeedback: null
  },
  {
    id: 2,
    confidence: 89,
    worker: {
      id: 102,
      name: '李师傅',
      avatar: '', // 将使用getAvatar生成
      rating: 4.7,
      experience: 6,
      orderCount: 156
    },
    reason: '与您相似的用户群体中，85%选择了李师傅，平均评分4.7分。',
    weights: {
      history: { label: '历史偏好', value: 25, color: '#409EFF' },
      rating: { label: '评分权重', value: 30, color: '#67C23A' },
      experience: { label: '经验权重', value: 20, color: '#E6A23C' },
      similarity: { label: '相似度', value: 25, color: '#F56C6C' }
    },
    userFeedback: null
  },
  {
    id: 3,
    confidence: 84,
    worker: {
      id: 103,
      name: '张阿姨',
      avatar: '', // 将使用getAvatar生成
      rating: 4.8,
      experience: 8,
      orderCount: 245
    },
    reason: '基于您的地理位置和价格偏好，张阿姨是性价比最优选择。',
    weights: {
      history: { label: '历史偏好', value: 20, color: '#409EFF' },
      rating: { label: '评分权重', value: 25, color: '#67C23A' },
      experience: { label: '经验权重', value: 25, color: '#E6A23C' },
      similarity: { label: '相似度', value: 30, color: '#F56C6C' }
    },
    userFeedback: null
  }
])

// 相似用户推荐
const similarUserRecommendations = ref([
  {
    id: 201,
    worker: {
      id: 201,
      name: '陈师傅',
      avatar: '' // 将使用getAvatar生成
    },
    reason: '与您的服务偏好高度相似的用户选择',
    similarUsers: 23,
    avgRating: 4.6
  },
  {
    id: 202,
    worker: {
      id: 202,
      name: '刘阿姨',
      avatar: '' // 将使用getAvatar生成
    },
    reason: '同小区用户的热门选择',
    similarUsers: 18,
    avgRating: 4.8
  },
  {
    id: 203,
    worker: {
      id: 203,
      name: '赵师傅',
      avatar: '' // 将使用getAvatar生成
    },
    reason: '相似年龄段用户推荐',
    similarUsers: 15,
    avgRating: 4.5
  }
])

// 反馈统计
const feedbackStats = ref({
  likes: 156,
  dislikes: 23,
  improvement: 12.5
})

// 切换标签选择
const toggleTag = (tag) => {
  const index = selectedTags.value.indexOf(tag)
  if (index > -1) {
    selectedTags.value.splice(index, 1)
  } else {
    selectedTags.value.push(tag)
  }
}

// 获取分类标签
const getCategoryLabel = (value) => {
  const category = categories.find(c => c.value === value)
  return category ? category.label : value
}

// 生成头像
const getAvatar = (name) => {
  const bgColors = ['#E3F2FD', '#E8F5E9', '#FFF3E0', '#FFEBEE', '#F5F5F5', '#F3E5F5', '#E0F2F1']
  const textColors = ['#409EFF', '#67C23A', '#E6A23C', '#F56C6C', '#909399', '#8E44AD', '#16A085']
  const randomIndex = Math.floor(Math.random() * bgColors.length)
  const bgColor = bgColors[randomIndex]
  const textColor = textColors[randomIndex]
  const svg = `
    <svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">
      <rect width="100" height="100" fill="${bgColor}" rx="8"/>
      <text x="50" y="55" font-size="28" fill="${textColor}" text-anchor="middle" dominant-baseline="middle" font-family="Arial, sans-serif" font-weight="bold">${name.substring(0, 3)}</text>
    </svg>
  `
  return `data:image/svg+xml;base64,${btoa(unescape(encodeURIComponent(svg)))}`
}

// 点赞问题
const likeQuestion = (id) => {
  const question = questions.value.find(q => q.id === id)
  if (question) {
    if (question.liked) {
      question.likes--
    } else {
      question.likes++
    }
    question.liked = !question.liked
    ElMessage.success(question.liked ? '点赞成功' : '取消点赞')
    saveQuestionsToStorage()
  }
}

// 查看问题详情
const showQuestionDetail = (question) => {
  // 实际项目中可以打开详情弹窗或跳转到详情页
  ElMessage.info('查看问题详情')
}

// 调用智谱AI API获取答案
const getAIAnswer = async (question) => {
  // 直接使用内置的API Key
  const apiKey = '030afcb2f1a94e17bb3e2938459bf695.swY4d61X9Q9HeXA9'

  // 设置问题为处理中状态
  question.isProcessing = true

  try {
    // 调用智谱AI的API
    const response = await fetch('https://open.bigmodel.cn/api/paas/v4/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        model: 'glm-4-flash', // 使用GLM-4-Flash模型
        messages: [
          {
            role: 'system',
            content: '你是一个家政服务专家，需要回答用户关于家政服务的各种问题。请用简洁明了的语言回答问题，提供实用的建议和解决方案。'
          },
          {
            role: 'user',
            content: `问题标题：${question.title} 问题描述：${question.question}`
          }
        ],
        temperature: 0.7,
        max_tokens: 1000
      })
    })

    if (!response.ok) {
      throw new Error(`API调用失败: ${response.status}`)
    }

    const data = await response.json()
    // 设置AI回答
    question.answer = data.choices?.[0]?.message?.content || '抱歉，未能生成回答'
  } catch (error) {
    console.error('获取AI回答失败:', error)
    question.answer = '获取AI回答失败，请稍后再试'
    ElMessage.error('获取AI回答失败')
  } finally {
    question.isProcessing = false
    saveQuestionsToStorage()
  }
}

// 提交新问题
const submitQuestion = async () => {
  if (!questionFormRef.value) return

  try {
    await questionFormRef.value.validate()
    isSubmitting.value = true

    // 添加新问题到列表
    const newQ = {
      id: questions.value.length + 1,
      title: newQuestion.value.title,
      question: newQuestion.value.question,
      type: newQuestion.value.type,
      questioner: '当前用户', // 实际项目中应从登录信息获取
      time: new Date().toLocaleString('zh-CN'),
      likes: 0,
      comments: 0,
      liked: false
    }

    questions.value.unshift(newQ)
    saveQuestionsToStorage()

    // 自动获取AI回答
    await getAIAnswer(newQ)

    // 重置表单
    if (questionFormRef.value) {
      questionFormRef.value.resetFields()
    }
    isSubmitting.value = false
    ElMessage.success('问题提交成功')
  } catch (error) {
    console.error('表单验证失败:', error)
    isSubmitting.value = false
  }
}

const getConfidenceType = (confidence) => {
  if (confidence >= 90) return 'success'
  if (confidence >= 80) return 'warning'
  return 'info'
}

const getLineStyle = (index) => {
  const rotations = [-30, 0, 30]
  return {
    transform: `rotate(${rotations[index - 1]}deg)`
  }
}

const feedback = (item, type) => {
  item.userFeedback = type
  if (type === 'like') {
    feedbackStats.value.likes++
    ElMessage.success('感谢您的反馈，我们将继续优化推荐算法')
  } else {
    feedbackStats.value.dislikes++
    ElMessage.info('感谢您的反馈，我们将减少此类推荐')
  }
}

const refreshRecommendations = () => {
  ElMessage.success('正在重新计算推荐...')
  // 模拟刷新
  setTimeout(() => {
    todayRecommendations.value = [...todayRecommendations.value].sort(() => Math.random() - 0.5)
  }, 500)
}

const bookWorker = (worker) => {
  router.push({
    path: '/booking',
    query: { workerId: worker.id }
  })
}

const viewDetail = (worker) => {
  router.push(`/worker/${worker.id}`)
}

// 初始化图表
onMounted(async () => {
  await nextTick()
  initRadarChart()
  initAccuracyChart()
  initSatisfactionChart()
})

const initRadarChart = () => {
  const chartDom = document.querySelector('.radar-chart')
  if (!chartDom) return
  
  const myChart = echarts.init(chartDom)
  const option = {
    radar: {
      indicator: [
        { name: '评分', max: 100 },
        { name: '经验', max: 100 },
        { name: '价格', max: 100 },
        { name: '距离', max: 100 },
        { name: '匹配度', max: 100 }
      ],
      radius: 70
    },
    series: [{
      type: 'radar',
      data: [{
        value: [95, 90, 85, 80, 96],
        name: '推荐指数',
        areaStyle: { color: 'rgba(64, 158, 255, 0.3)' },
        lineStyle: { color: '#409EFF' },
        itemStyle: { color: '#409EFF' }
      }]
    }]
  }
  myChart.setOption(option)
}

const initAccuracyChart = () => {
  const chartDom = document.querySelector('.chart-container')
  if (!chartDom) return
  
  const myChart = echarts.init(chartDom)
  const option = {
    xAxis: {
      type: 'category',
      data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    },
    yAxis: {
      type: 'value',
      min: 80,
      max: 100
    },
    series: [{
      data: [85, 87, 89, 88, 91, 92, 92.5],
      type: 'line',
      smooth: true,
      areaStyle: { color: 'rgba(103, 194, 58, 0.3)' },
      lineStyle: { color: '#67C23A' },
      itemStyle: { color: '#67C23A' }
    }]
  }
  myChart.setOption(option)
}

const initSatisfactionChart = () => {
  const chartDom = document.querySelectorAll('.chart-container')[1]
  if (!chartDom) return
  
  const myChart = echarts.init(chartDom)
  const option = {
    series: [{
      type: 'pie',
      radius: ['40%', '70%'],
      data: [
        { value: 156, name: '非常满意', itemStyle: { color: '#67C23A' } },
        { value: 45, name: '满意', itemStyle: { color: '#409EFF' } },
        { value: 23, name: '一般', itemStyle: { color: '#E6A23C' } },
        { value: 12, name: '不满意', itemStyle: { color: '#F56C6C' } }
      ],
      label: {
        formatter: '{b}: {c} ({d}%)'
      }
    }]
  }
  myChart.setOption(option)
}
</script>

<style scoped>
.ai-recommendation-page {
  max-width: 1400px;
  margin: 0 auto;
  padding: 40px 20px;
}

.page-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  padding: 40px;
  color: white;
  margin-bottom: 40px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-content {
  flex: 1;
}

.ai-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.2);
  padding: 8px 16px;
  border-radius: 20px;
  margin-bottom: 16px;
  font-weight: 600;
}

.page-header h1 {
  font-size: 36px;
  margin-bottom: 12px;
}

.page-header p {
  font-size: 16px;
  opacity: 0.9;
}

.header-stats {
  display: flex;
  gap: 40px;
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  opacity: 0.8;
}

.recommendation-container {
  display: flex;
  flex-direction: column;
  gap: 40px;
}

.recommendation-section {
  background: white;
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 12px;
}

.section-title h2 {
  font-size: 24px;
  color: #303133;
  margin: 0;
}

.section-desc {
  color: #606266;
  margin-top: 8px;
}

.today-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 24px;
}

.recommendation-card {
  background: #f5f7fa;
  border-radius: 12px;
  padding: 24px;
  border: 2px solid transparent;
  transition: all 0.3s;
}

.recommendation-card:hover {
  border-color: #409EFF;
  box-shadow: 0 4px 20px rgba(64, 158, 255, 0.15);
}

.recommendation-card.highlight {
  background: linear-gradient(135deg, #ecf5ff 0%, #f5f7fa 100%);
  border-color: #409EFF;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.recommendation-index {
  font-size: 20px;
  font-weight: 700;
  color: #409EFF;
}

.worker-profile {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 16px;
}

.worker-basic h3 {
  font-size: 20px;
  color: #303133;
  margin-bottom: 8px;
}

.experience {
  color: #606266;
  font-size: 14px;
  margin-top: 4px;
}

.recommendation-reason {
  background: white;
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 16px;
}

.reason-title {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #409EFF;
  font-weight: 600;
  margin-bottom: 8px;
}

.recommendation-reason p {
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
}

.weight-contribution {
  margin-bottom: 16px;
}

.weight-contribution h4 {
  font-size: 14px;
  color: #606266;
  margin-bottom: 12px;
}

.weight-chart {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.weight-bar-item {
  display: grid;
  grid-template-columns: 80px 1fr 50px;
  align-items: center;
  gap: 12px;
}

.bar-label {
  font-size: 12px;
  color: #909399;
}

.bar-track {
  height: 8px;
  background: #e4e7ed;
  border-radius: 4px;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.5s ease;
}

.bar-value {
  font-size: 12px;
  color: #606266;
  text-align: right;
}

.radar-chart-container {
  margin-bottom: 16px;
}

.radar-chart-container h4 {
  font-size: 14px;
  color: #606266;
  margin-bottom: 12px;
}

.radar-chart {
  height: 200px;
}

.card-actions {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.card-actions .el-button {
  flex: 1;
}

.feedback-section {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 16px;
  border-top: 1px solid #ebeef5;
  color: #606266;
  font-size: 14px;
}

.similar-users-info {
  margin-bottom: 24px;
}

.similarity-visualization {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 40px;
  padding: 40px;
  background: #f5f7fa;
  border-radius: 12px;
}

.user-node {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.user-node span {
  font-size: 14px;
  color: #606266;
}

.current-user span {
  font-weight: 600;
  color: #409EFF;
}

.connection-lines {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.connection-line {
  width: 100px;
  height: 2px;
  background: linear-gradient(90deg, #409EFF, #67C23A);
  position: relative;
}

.similarity-score {
  position: absolute;
  top: -20px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 12px;
  color: #67C23A;
  font-weight: 600;
}

.similar-users {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.similar-recommendations {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.similar-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 12px;
  transition: all 0.3s;
}

.similar-card:hover {
  background: #ecf5ff;
}

.similar-info {
  flex: 1;
}

.similar-info h4 {
  font-size: 16px;
  color: #303133;
  margin-bottom: 4px;
}

.similar-reason {
  color: #606266;
  font-size: 14px;
  margin-bottom: 8px;
}

.similar-stats {
  display: flex;
  gap: 16px;
  color: #909399;
  font-size: 13px;
}

.similar-stats span {
  display: flex;
  align-items: center;
  gap: 4px;
}

.algorithm-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
}

.algo-card {
  background: #f5f7fa;
  border-radius: 12px;
  padding: 24px;
  text-align: center;
  transition: all 0.3s;
}

.algo-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}

.algo-icon {
  margin-bottom: 16px;
}

.algo-card h3 {
  font-size: 18px;
  color: #303133;
  margin-bottom: 12px;
}

.algo-card p {
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
  margin-bottom: 16px;
}

.formula {
  background: white;
  padding: 12px;
  border-radius: 8px;
  font-size: 13px;
}

.formula code {
  color: #409EFF;
  font-family: 'Courier New', monospace;
}

.feedback-charts {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 24px;
  margin-bottom: 24px;
}

.chart-card {
  background: #f5f7fa;
  border-radius: 12px;
  padding: 24px;
}

.chart-card h4 {
  font-size: 16px;
  color: #303133;
  margin-bottom: 16px;
}

.chart-container {
  height: 250px;
}

.feedback-summary {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.summary-item {
  background: #f5f7fa;
  border-radius: 12px;
  padding: 24px;
  text-align: center;
}

.summary-value {
  font-size: 32px;
  font-weight: 700;
  color: #303133;
  margin-bottom: 8px;
}

.summary-label {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  color: #606266;
  font-size: 14px;
}

/* 智能问答系统样式 */
.ai-qa-section {
  background: white;
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  margin-bottom: 40px;
}

.qa-header {
  margin-bottom: 24px;
}

.qa-title {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.qa-title h2 {
  font-size: 24px;
  color: #303133;
  margin: 0;
}

.qa-desc {
  color: #606266;
  margin: 0;
}

.qa-input-section {
  background: #f5f7fa;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 24px;
}

.qa-tags {
  margin-bottom: 24px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 12px;
}

.tags-title {
  font-weight: 600;
  color: #606266;
  margin-right: 12px;
}

.tag-item {
  margin-right: 8px;
  margin-bottom: 8px;
  cursor: pointer;
}

.qa-history {
  border-top: 1px solid #ebeef5;
  padding-top: 24px;
}

.history-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.history-header h3 {
  font-size: 18px;
  color: #303133;
  margin: 0;
}

.questions-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.question-item {
  background: #f5f7fa;
  border-radius: 12px;
  padding: 20px;
  transition: all 0.3s;
}

.question-item:hover {
  background: #ecf5ff;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.15);
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.question-header h4 {
  font-size: 16px;
  color: #303133;
  margin: 0;
  flex: 1;
}

.question-content {
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
  margin-bottom: 12px;
}

.question-meta {
  display: flex;
  gap: 16px;
  font-size: 12px;
  color: #909399;
  margin-bottom: 12px;
}

.question-actions {
  display: flex;
  gap: 12px;
  margin-bottom: 12px;
}

.answer-content {
  background: white;
  border-radius: 8px;
  padding: 16px;
  margin-top: 12px;
  border-left: 4px solid #409EFF;
}

.answer-header {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #409EFF;
  font-weight: 600;
  margin-bottom: 8px;
  font-size: 14px;
}

.answer-content p {
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
  margin: 0;
}

.answer-processing {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #606266;
  font-size: 14px;
  margin-top: 12px;
  padding: 16px;
  background: white;
  border-radius: 8px;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    text-align: center;
    gap: 24px;
  }

  .header-stats {
    width: 100%;
    justify-content: space-around;
    flex-wrap: wrap;
  }

  .stat-item {
    margin-bottom: 16px;
  }

  .today-cards {
    grid-template-columns: 1fr;
  }

  .similarity-visualization {
    flex-direction: column;
  }

  .connection-lines {
    flex-direction: row;
  }

  .similar-users {
    flex-direction: row;
  }

  .feedback-summary {
    grid-template-columns: 1fr;
  }

  .qa-input-section {
    padding: 16px;
  }

  .qa-tags {
    padding: 12px;
  }

  .tag-item {
    font-size: 12px;
    padding: 4px 8px;
  }

  .question-item {
    padding: 16px;
  }

  .question-meta {
    flex-direction: column;
    gap: 4px;
    align-items: flex-start;
  }
}

@media (max-width: 576px) {
  .ai-recommendation-page {
    padding: 20px 16px;
  }

  .page-header {
    padding: 24px;
  }

  .page-header h1 {
    font-size: 28px;
  }

  .qa-header h2 {
    font-size: 20px;
  }

  .ai-qa-section {
    padding: 20px;
  }

  .qa-input-section {
    padding: 12px;
  }

  .el-form-item {
    margin-bottom: 12px;
  }

  .el-form-item__label {
    font-size: 14px;
  }

  .el-input__inner {
    font-size: 14px;
  }

  .el-textarea__inner {
    font-size: 14px;
  }
}
</style>

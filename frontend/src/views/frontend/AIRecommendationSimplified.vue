<template>
  <div class="ai-recommendation-page">
    <div class="page-header">
      <div class="header-content">
        <h1>智能家政助手</h1>
        <p>基于深度学习的家政服务推荐与智能问答系统</p>
      </div>
    </div>

    <!-- 智能问答系统 -->
    <div class="ai-qa-section">
      <div class="qa-header">
        <h2>智能家政问答</h2>
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
              <div v-if="question.answer" class="answer-content">
                <div class="answer-header">
                  <span>AI 回答</span>
                </div>
                <p>{{ question.answer }}</p>
              </div>
              <div v-else-if="question.isProcessing" class="answer-processing">
                <span>AI 正在生成答案...</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElForm, ElFormItem, ElInput, ElSelect, ElOption, ElButton, ElTag } from 'element-plus'

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

// 默认示例问题（无本地历史时使用）
const defaultQuestions = () => [
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
  }
]

// 从 localStorage 读取问答历史，失败或无效则返回默认列表
function loadInitialQuestions () {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return defaultQuestions()
    const list = JSON.parse(raw)
    if (!Array.isArray(list) || list.length === 0) return defaultQuestions()
    // 只保留可序列化字段，补全缺失字段
    return list.map((q, i) => ({
      id: q.id != null ? q.id : i + 1,
      title: q.title || '',
      question: q.question || '',
      type: q.type || 'other',
      questioner: q.questioner || '用户',
      time: q.time || '',
      likes: q.likes != null ? q.likes : 0,
      comments: q.comments != null ? q.comments : 0,
      liked: !!q.liked,
      answer: q.answer != null ? q.answer : undefined,
      isProcessing: false
    }))
  } catch (e) {
    console.warn('读取问答历史失败:', e)
    return defaultQuestions()
  }
}

// 将当前问答列表持久化到 localStorage（只存纯数据，不存 isProcessing）
function saveQuestionsToStorage () {
  try {
    const list = questions.value.map(q => ({
      id: q.id,
      title: q.title,
      question: q.question,
      type: q.type,
      questioner: q.questioner,
      time: q.time,
      likes: q.likes,
      comments: q.comments,
      liked: q.liked,
      answer: q.answer
    }))
    localStorage.setItem(STORAGE_KEY, JSON.stringify(list))
  } catch (e) {
    console.warn('保存问答历史失败:', e)
  }
}

// 问题数据：优先从本地存储恢复，否则使用默认示例
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

// 切换标签选择
const toggleTag = (tag) => {
  const index = selectedTags.value.indexOf(tag)
  if (index > -1) {
    selectedTags.value.splice(index, 1)
  } else {
    selectedTags.value.push(tag)
  }
}

// 调用智谱AI API获取答案
const getAIAnswer = async (question) => {
  // 直接使用内置的API Key
  const apiKey = '030afcb2f1a94e17bb3e2938459bf695.swY4d61X9Q9HeXA9'

  // 设置问题为处理中状态
  question.isProcessing = true
  
  // 确保Vue响应式更新
  questions.value = [...questions.value]

  try {
    // 设置超时
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 30000) // 30秒超时

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
      }),
      signal: controller.signal
    })

    clearTimeout(timeoutId)

    if (!response.ok) {
      throw new Error(`API调用失败: ${response.status}`)
    }

    const data = await response.json()
    // 设置AI回答
    question.answer = data.choices?.[0]?.message?.content || '抱歉，未能生成回答'
    
    // 确保Vue响应式更新
    questions.value = [...questions.value]
  } catch (error) {
    console.error('获取AI回答失败:', error)
    question.answer = '获取AI回答失败，请稍后再试'
    ElMessage.error('获取AI回答失败')
    
    // 确保Vue响应式更新
    questions.value = [...questions.value]
  } finally {
    question.isProcessing = false
    
    // 确保Vue响应式更新
    questions.value = [...questions.value]
    saveQuestionsToStorage()
  }
}

// 提交新问题
const submitQuestion = async () => {
  if (!questionFormRef.value) return

  try {
    await questionFormRef.value.validate()
    isSubmitting.value = true

    // 添加新问题到列表（id 使用当前最大 id+1，避免与历史记录冲突）
    const maxId = questions.value.length ? Math.max(...questions.value.map(q => q.id)) : 0
    const newQ = {
      id: maxId + 1,
      title: newQuestion.value.title,
      question: newQuestion.value.question,
      type: newQuestion.value.type,
      questioner: '当前用户',
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
}

.header-content h1 {
  font-size: 36px;
  margin-bottom: 12px;
}

.header-content p {
  font-size: 16px;
  opacity: 0.9;
}

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

.qa-header h2 {
  font-size: 24px;
  color: #303133;
  margin: 0 0 8px 0;
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

.answer-content {
  background: white;
  border-radius: 8px;
  padding: 16px;
  margin-top: 12px;
  border-left: 4px solid #409EFF;
}

.answer-header {
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

.is-loading {
  animation: rotate 1s linear infinite;
}

@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>
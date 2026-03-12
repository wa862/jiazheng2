<template>
  <admin-layout>
    <div class="banner-management">
    <el-card shadow="hover">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <h3>轮播图管理</h3>
            <span class="subtitle">管理前台首页轮播图展示</span>
          </div>
          <div class="header-right">
            <el-button type="primary" @click="handleAdd">
              <el-icon><Plus /></el-icon>
              添加轮播图
            </el-button>
            <el-button @click="loadData">
              <el-icon><Refresh /></el-icon>
              刷新
            </el-button>
          </div>
        </div>
      </template>

      <el-table :data="bannerList" v-loading="loading" stripe>
        <el-table-column type="index" label="#" width="50" />
        <el-table-column label="预览" width="200">
          <template #default="{ row }">
            <el-image :src="row.image" fit="cover" style="width: 180px; height: 100px; border-radius: 8px;">
              <template #error>
                <div class="image-error">图片加载失败</div>
              </template>
            </el-image>
          </template>
        </el-table-column>
        <el-table-column prop="title" label="标题" min-width="150" />
        <el-table-column prop="subtitle" label="副标题" min-width="200" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-switch
              v-model="row.status"
              :active-value="1"
              :inactive-value="0"
              @change="(val) => handleStatusChange(row, val)"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 添加/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑轮播图' : '添加轮播图'" width="700px">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入标题" />
        </el-form-item>
        <el-form-item label="副标题" prop="subtitle">
          <el-input v-model="form.subtitle" placeholder="请输入副标题" />
        </el-form-item>
        <el-form-item label="图片" prop="image">
          <div class="image-input-row">
            <el-input
              v-model="form.image"
              placeholder="请输入图片URL，或点击右侧从本地上传"
            />
            <el-upload
              class="upload-btn"
              :show-file-list="false"
              :before-upload="beforeBannerUpload"
              :http-request="handleBannerUpload"
              accept="image/jpeg,image/png,image/webp,image/gif"
            >
              <el-button type="primary" plain>本地上传</el-button>
            </el-upload>
          </div>
          <div v-if="form.image" class="banner-preview-wrap">
            <img :src="form.image" class="banner-preview" alt="预览" />
          </div>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>
    </div>
  </admin-layout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Refresh } from '@element-plus/icons-vue'
import AdminLayout from '@components/AdminLayout.vue'
import { getBanners, createBanner, updateBanner, deleteBanner, uploadImage } from '@api'

const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref(null)
const bannerList = ref([])

const form = ref({
  title: '',
  subtitle: '',
  image: '',
  link: '',
  sortOrder: 0,
  status: 1
})

const rules = {
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }],
  subtitle: [{ required: true, message: '请输入副标题', trigger: 'blur' }],
  image: [{ required: true, message: '请输入图片URL', trigger: 'blur' }]
}

// 轮播图上传前校验
const beforeBannerUpload = (file) => {
  const isJPG = file.type === 'image/jpeg'
  const isPNG = file.type === 'image/png'
  const isWebP = file.type === 'image/webp'
  const isGIF = file.type === 'image/gif'
  const isImage = isJPG || isPNG || isWebP || isGIF
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传 JPG/PNG/WebP/GIF 格式的图片')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB')
    return false
  }
  return true
}

// 自定义上传：调用后端 /api/upload/image，成功后把返回路径写入 form.image
const handleBannerUpload = async (options) => {
  try {
    const res = await uploadImage(options.file)
    if (res && res.code === 200 && res.data) {
      const path = res.data
      const url = path.startsWith('/') ? path : '/' + path
      form.value.image = url
      ElMessage.success('图片上传成功')
      options.onSuccess(res)
    } else {
      const msg = res?.message || '图片上传失败'
      ElMessage.error(msg)
      options.onError(new Error(msg))
    }
  } catch (error) {
    const msg = error?.response?.data?.message || error?.message || '图片上传失败'
    ElMessage.error(msg)
    options.onError(error)
  }
}

const loadData = async () => {
  loading.value = true
  try {
    const res = await getBanners()
    if (res && res.code === 200 && res.data) {
      bannerList.value = Array.isArray(res.data) ? res.data : (res.data.content || [])
    } else {
      bannerList.value = []
    }
  } catch (error) {
    console.error('加载轮播图失败:', error)
    ElMessage.error('加载轮播图失败')
    bannerList.value = []
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  isEdit.value = false
  form.value = {
    title: '',
    subtitle: '',
    image: '',
    link: '',
    sortOrder: 0,
    status: 1
  }
  dialogVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  form.value = { ...row }
  dialogVisible.value = true
}

const handleSubmit = async () => {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return

  submitLoading.value = true
  try {
    if (isEdit.value) {
      await updateBanner(form.value.id, form.value)
      ElMessage.success('轮播图更新成功')
    } else {
      await createBanner(form.value)
      ElMessage.success('轮播图创建成功')
    }
    dialogVisible.value = false
    loadData()
  } catch (error) {
    console.error('保存轮播图失败:', error)
    ElMessage.error('保存轮播图失败')
  } finally {
    submitLoading.value = false
  }
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除这个轮播图吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await deleteBanner(row.id)
    ElMessage.success('轮播图已删除')
    loadData()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除轮播图失败:', error)
      ElMessage.error('删除轮播图失败')
    }
  }
}

const handleStatusChange = async (row, val) => {
  try {
    await updateBanner(row.id, { ...row, status: val })
    ElMessage.success('状态更新成功')
  } catch (error) {
    console.error('更新状态失败:', error)
    ElMessage.error('更新状态失败')
    row.status = val === 1 ? 0 : 1
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.banner-management {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-left h3 {
  margin: 0;
}

.subtitle {
  color: #909399;
  font-size: 14px;
}

.image-error {
  width: 180px;
  height: 100px;
  background: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
  border-radius: 8px;
}

.image-input-row {
  display: flex;
  gap: 12px;
  align-items: center;
}

.upload-btn {
  flex-shrink: 0;
}

.banner-preview-wrap {
  margin-top: 10px;
  width: 300px;
  height: 156px;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #ebeef5;
}

.banner-preview {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.form-hint {
  margin-left: 10px;
  color: #909399;
  font-size: 12px;
}
</style>

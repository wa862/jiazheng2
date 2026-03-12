<template>
  <div class="booking">
    <div class="main-content">
      <el-card class="booking-card">
        <template #header>
          <div class="card-header">
            <span>预约服务</span>
          </div>
        </template>
        
        <el-form :model="bookingForm" :rules="rules" ref="bookingFormRef" label-width="120px">
          <el-form-item label="家政人员" prop="workerId">
            <el-input v-model="workerName" disabled></el-input>
          </el-form-item>
          
          <el-form-item label="服务日期" prop="serviceDate">
            <el-date-picker
              v-model="bookingForm.serviceDate"
              type="date"
              placeholder="选择日期"
              :disabled-date="disabledDate"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
            />
          </el-form-item>
          
          <el-form-item label="服务时间" prop="serviceTime">
            <el-time-picker
              v-model="bookingForm.serviceTime"
              placeholder="选择时间"
              format="HH:mm"
              value-format="HH:mm"
            />
          </el-form-item>
          
          <el-form-item label="服务时长" prop="duration">
            <el-select v-model="bookingForm.duration" placeholder="请选择服务时长">
              <el-option label="2小时" :value="2"></el-option>
              <el-option label="4小时" :value="4"></el-option>
              <el-option label="6小时" :value="6"></el-option>
              <el-option label="8小时" :value="8"></el-option>
            </el-select>
          </el-form-item>
          
          <el-form-item label="服务地址" prop="address">
            <el-input v-model="bookingForm.address" placeholder="请输入服务地址">
              <template #append>
                <el-button :loading="locating" @click="locateCurrentPosition">定位当前位置</el-button>
              </template>
            </el-input>
          </el-form-item>

          <el-form-item label="详细地址">
            <el-input
              v-model="bookingForm.detailAddress"
              placeholder="如楼栋、单元、门牌号等详细信息"
            ></el-input>
          </el-form-item>
          
          <el-form-item label="联系电话" prop="phone">
            <el-input v-model="bookingForm.phone" placeholder="请输入联系电话"></el-input>
          </el-form-item>
          
          <el-form-item label="备注信息" prop="remark">
            <el-input
              v-model="bookingForm.remark"
              type="textarea"
              :rows="4"
              placeholder="请输入备注信息（选填）"
            ></el-input>
          </el-form-item>
          
          <el-form-item label="订单金额">
            <div class="amount-display">
              <span class="amount">¥{{ totalAmount }}</span>
            </div>
          </el-form-item>
          
          <el-form-item>
            <el-button type="primary" size="large" @click="handleSubmit" :loading="submitting">提交订单</el-button>
            <el-button size="large" @click="$router.back()">取消</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getWorkerById, createOrder } from '../../api'
import { getCurrentLocationByBaidu } from '@/utils/location'

const router = useRouter()
const route = useRoute()

const bookingFormRef = ref(null)
const submitting = ref(false)
const locating = ref(false)
const workerName = ref('')
const workerPrice = ref(0)

const bookingForm = ref({
  workerId: '',
  serviceDate: '',
  serviceTime: '',
  duration: 2,
  address: '',
  detailAddress: '',
  phone: '',
  remark: ''
})

const rules = {
  workerId: [{ required: true, message: '请选择家政人员', trigger: 'change' }],
  serviceDate: [{ required: true, message: '请选择服务日期', trigger: 'change' }],
  serviceTime: [{ required: true, message: '请选择服务时间', trigger: 'change' }],
  duration: [{ required: true, message: '请选择服务时长', trigger: 'change' }],
  address: [{ required: true, message: '请输入服务地址', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的11位手机号码', trigger: 'blur' }
  ]
}

const totalAmount = computed(() => {
  return workerPrice.value * bookingForm.value.duration
})

const disabledDate = (time) => {
  return time.getTime() < Date.now() - 24 * 60 * 60 * 1000
}

const loadWorkerInfo = async () => {
  try {
    const workerId = route.query.workerId
    if (workerId) {
      const data = await getWorkerById(workerId)
      workerName.value = data.name
      workerPrice.value = data.price
      bookingForm.value.workerId = parseInt(workerId)
    }
  } catch (error) {
    console.error('加载家政人员信息失败:', error)
  }
}

const handleSubmit = async () => {
  if (!bookingFormRef.value) return
  
  try {
    await bookingFormRef.value.validate()
    submitting.value = true
    
    const userId = localStorage.getItem('userId')
    if (!userId) {
      ElMessage.error('请先登录')
      router.push('/login')
      return
    }
    
    const fullAddress = bookingForm.value.detailAddress
      ? `${bookingForm.value.address} ${bookingForm.value.detailAddress}`
      : bookingForm.value.address

    const orderData = {
      workerId: bookingForm.value.workerId,
      serviceDate: bookingForm.value.serviceDate,
      serviceTime: bookingForm.value.serviceTime,
      duration: bookingForm.value.duration,
      address: fullAddress,
      phone: bookingForm.value.phone,
      remark: bookingForm.value.remark,
      userId: parseInt(userId),
      amount: totalAmount.value
    }
    
    const result = await createOrder(orderData)
    if (result && (result.code === 200 || result.status === 200)) {
      ElMessage.success('订单创建成功，请完成支付')
      router.push('/orders?tab=unpaid')
    } else {
      ElMessage.error(result?.message || result?.data?.message || '订单创建失败')
    }
  } catch (error) {
    if (error !== false) {
      const msg = error?.response?.data?.message || error?.message || '订单创建失败，请重试'
      console.error('创建订单失败:', error)
      ElMessage.error(typeof msg === 'string' ? msg : '订单创建失败，请重试')
    }
  } finally {
    submitting.value = false
  }
}

const locateCurrentPosition = () => {
  locating.value = true
  getCurrentLocationByBaidu()
    .then((loc) => {
      // 使用百度返回的格式化地址，例如：河北省石家庄市新华区河北经贸大学
      bookingForm.value.address = loc.fullAddress || `${loc.province}${loc.city}${loc.district}${loc.street}${loc.streetNumber}`
      ElMessage.success('已根据当前位置获取地址')
    })
    .catch((err) => {
      ElMessage.error(err.message || '获取当前位置失败，请稍后重试')
    })
    .finally(() => {
      locating.value = false
    })
}

onMounted(() => {
  loadWorkerInfo()
})
</script>

<style scoped>
.booking {
  min-height: 100%;
}

.main-content {
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
}

.booking-card {
  margin-bottom: 20px;
}

.card-header {
  font-size: 20px;
  font-weight: bold;
}

.amount-display {
  padding: 15px;
  background: #fff7e6;
  border-radius: 4px;
  border: 1px solid #ffd591;
}

.amount {
  font-size: 28px;
  color: #ff6600;
  font-weight: bold;
}
</style>
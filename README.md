# 家政服务系统

基于智能算法的家政服务管理系统，包含前台用户端和后台管理端。

## 项目结构

```
家政服务/
├── frontend/          # 前台用户端（Vue3）
│   ├── src/
│   │   ├── views/
│   │   │   └── frontend/  # 前台页面
│   │   │       ├── Home.vue          # 首页
│   │   │       ├── Services.vue      # 服务分类页
│   │   │       ├── WorkerDetail.vue  # 家政人员详情页
│   │   │       ├── Orders.vue        # 订单管理页
│   │   │       └── Profile.vue      # 个人中心页
│   │   ├── api/
│   │   ├── router/
│   │   └── utils/
│   ├── package.json
│   └── vite.config.js
├── admin/            # 后台管理端（Vue3）
│   ├── src/
│   │   ├── views/
│   │   │   ├── dashboard/    # 数据看板
│   │   │   ├── users/        # 用户管理
│   │   │   ├── workers/      # 家政人员管理
│   │   │   ├── orders/       # 订单管理
│   │   │   ├── algorithm/    # 推荐算法管理
│   │   │   ├── statistics/   # 数据统计
│   │   │   ├── categories/   # 服务分类管理
│   │   │   ├── banners/      # 轮播图管理
│   │   │   ├── applications/ # 家政人员入驻申请管理
│   │   │   ├── feedbacks/    # 用户反馈管理
│   │   │   └── system/       # 系统设置
│   │   ├── api/
│   │   ├── router/
│   │   └── utils/
│   ├── package.json
│   └── vite.config.js
└── backend/          # 后端服务（Java Spring Boot）
    ├── src/main/java/com/jiazheng/
    │   ├── controller/       # 控制器
    │   ├── service/          # 服务层
    │   ├── entity/           # 实体类
    │   ├── mapper/           # 数据访问层
    │   ├── algorithm/        # 智能算法
    │   │   ├── impl/
    │   │   │   ├── CollaborativeFilteringAlgorithm.java    # 协同过滤算法
    │   │   │   ├── ContentBasedRecommendationAlgorithm.java # 基于内容推荐算法
    │   │   │   ├── IntelligentMatchingAlgorithm.java       # 智能匹配算法
    │   │   │   └── SatisfactionPredictionAlgorithm.java    # 满意度预测算法
    │   │   └── RecommendationAlgorithm.java
    │   └── config/           # 配置类
    └── pom.xml
```

## 技术栈

### 前台用户端
- Vue 3.4.0
- Element Plus 2.5.0
- Vue Router 4.2.0
- Axios 1.6.0
- ECharts 5.4.0
- Vite 5.0.0

### 后台管理端
- Vue 3.4.0
- Element Plus 2.5.0
- Vue Router 4.2.0
- Axios 1.6.0
- ECharts 5.4.0
- Vite 5.0.0

### 后端服务
- Java 17
- Spring Boot 3.2.0
- Spring Data JPA
- MySQL 8.0.33

## 智能算法

### 1. 协同过滤推荐算法
- 基于用户历史行为和相似度计算
- 支持多种相似度计算方法（余弦相似度、皮尔逊相关系数、Jaccard相似度）
- 推荐相似用户喜欢的家政人员

### 2. 基于内容推荐算法
- 根据服务分类、价格、评分、距离等因素
- 加权计算家政人员匹配度
- 推荐符合用户偏好的家政人员

### 3. 智能匹配算法
- 综合考虑时间、地点、技能、价格等因素
- 为用户智能匹配最合适的家政人员
- 提高服务匹配成功率

### 4. 满意度预测算法
- 基于用户历史订单和评价数据
- 预测用户对家政人员的满意度
- 帮助用户做出更好的选择

## 快速开始

### 前台用户端

```bash
cd frontend
npm install
npm run dev
```

访问地址：http://localhost:5173

### 后台管理端

```bash
cd admin
npm install
npm run dev
```

访问地址：http://localhost:5174

### 后端服务

```bash
cd backend
mvn spring-boot:run
```

后端服务地址：http://localhost:8082

### 默认账号及密码

> 初次运行建议先使用默认账号登录系统，登录成功后请及时在系统中修改为自己的安全密码。

- 管理员端登录地址：`http://localhost:5174/admin/login`

- 超级管理员（拥有全部后台权限）
  - 用户名：`supperadmin`
  - 密码：`123456`

- 普通管理员（仅做示例，可在后台「用户管理」中自行创建/调整权限）
  - 用户名：`admin`
  - 密码：`123456`

> 说明：如在导入数据库脚本或运行过程中自行修改了账号信息，请以实际数据库中的用户表 (`users`) 为准。

## 功能模块

### 前台用户端
- 首页：轮播图、服务分类、智能推荐、热门家政人员
- 服务分类页：按类别、价格、评分、距离筛选家政人员
- 家政人员详情页：查看详细信息、预约服务、满意度预测
- 订单管理：查看订单状态、取消订单、评价服务
- 个人中心：修改个人信息、查看历史订单、收藏家政人员

### 后台管理端
- 数据看板：实时监控平台运营数据
- 用户管理：添加、编辑、删除用户
- 家政人员管理：添加、编辑、删除家政人员
- 订单管理：查看订单、更新订单状态
- 评价管理：查看、删除评价
- 服务分类管理：管理前台服务分类展示
- 轮播图管理：管理首页轮播图
- 家政人员入驻申请管理：审核入驻申请
- 用户反馈管理：查看和回复用户反馈
- 推荐算法管理：配置智能推荐算法参数
- 系统设置：平台基本设置
- 数据统计：详细的数据分析和统计报表

## 数据库配置

在 `backend/src/main/resources/application.properties` 中配置数据库连接：

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/jiazheng?useSSL=false&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=your_password
spring.jpa.hibernate.ddl-auto=update
```

## API 接口

### 用户端 API
- `POST /api/auth/login` - 用户登录
- `GET /api/workers` - 获取家政人员列表
- `GET /api/workers/{id}` - 获取家政人员详情
- `POST /api/orders` - 创建订单
- `GET /api/orders` - 获取订单列表
- `POST /api/reviews` - 提交评价

### 管理端 API
- `POST /api/admin/login` - 管理员登录
- `GET /api/admin/statistics` - 获取统计数据
- `GET /api/admin/users` - 获取用户列表
- `POST /api/admin/users` - 添加用户
- `GET /api/admin/workers` - 获取家政人员列表
- `POST /api/admin/workers` - 添加家政人员
- `GET /api/admin/orders` - 获取订单列表
- `PUT /api/admin/orders/{id}/status` - 更新订单状态
- `GET /api/admin/reviews` - 获取评价列表
- `GET /api/admin/categories` - 获取服务分类列表
- `POST /api/admin/categories` - 创建服务分类
- `PUT /api/admin/categories/{id}` - 更新服务分类
- `DELETE /api/admin/categories/{id}` - 删除服务分类
- `GET /api/admin/banners` - 获取轮播图列表
- `POST /api/admin/banners` - 创建轮播图
- `PUT /api/admin/banners/{id}` - 更新轮播图
- `DELETE /api/admin/banners/{id}` - 删除轮播图
- `GET /api/admin/applications` - 获取入驻申请列表
- `GET /api/admin/applications/stats` - 获取入驻申请统计
- `POST /api/admin/applications/{id}/approve` - 批准入驻申请
- `POST /api/admin/applications/{id}/reject` - 拒绝入驻申请
- `GET /api/admin/feedbacks` - 获取用户反馈列表
- `GET /api/admin/feedbacks/stats` - 获取用户反馈统计
- `POST /api/admin/feedbacks/{id}/reply` - 回复用户反馈
- `GET /api/admin/algorithm/config` - 获取算法配置
- `PUT /api/admin/algorithm/config` - 更新算法配置
- `GET /api/admin/settings` - 获取系统设置
- `PUT /api/admin/settings` - 更新系统设置

## 开发说明

### 前台和后台分离
- 前台用户端和后台管理端是完全独立的两个 Vue3 项目
- 分别运行在不同的端口（前台 `5173`，后台 `5174`）
- 共享同一个后端服务（端口 `8082`）

### 图片上传与头像管理
- 后端提供统一的图片上传接口：`POST /api/upload/image`
  - 请求：`multipart/form-data`，字段名为 `file`
  - 校验：仅支持 `jpg/png/webp/gif`，大小不超过 `2MB`
  - 返回：形如 `uploads/xxxx.png` 的相对路径
- 静态资源映射：
  - `application.properties` 中通过 `upload.path` 指定物理存储目录（默认项目根目录下 `uploads`）
  - `WebConfig` 将 `/uploads/**` 映射到该目录，浏览器可通过 `http://localhost:8082/uploads/xxxx.png` 访问
- 前台用户端：
  - 个人中心头像支持「本地上传」与「输入图片 URL」两种方式
  - 本地上传成功后，将返回的 `/uploads/xxxx.png` 写入用户 `avatar` 字段并实时预览
- 后台管理端：
  - 家政人员管理支持头像本地上传
  - 上传成功后自动回填头像地址到表单，并在列表和详情页展示

### 页面尺寸规范
- 前台页面：按照网页版标准尺寸设计
- 后台页面：按照管理后台标准尺寸设计
- 统一的字体大小、间距、圆角等设计规范

### 代码规范
- 使用 Vue 3 Composition API
- 使用 `<script setup>` 语法
- 统一的代码风格和命名规范

## 许可证

MIT License
# jiazheng2

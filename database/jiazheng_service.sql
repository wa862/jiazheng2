/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80034 (8.0.34)
 Source Host           : localhost:3306
 Source Schema         : jiazheng_service

 Target Server Type    : MySQL
 Target Server Version : 80034 (8.0.34)
 File Encoding         : 65001

 Date: 10/03/2026 17:44:40
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for algorithm_config
-- ----------------------------
DROP TABLE IF EXISTS `algorithm_config`;
CREATE TABLE `algorithm_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of algorithm_config
-- ----------------------------

-- ----------------------------
-- Table structure for banners
-- ----------------------------
DROP TABLE IF EXISTS `banners`;
CREATE TABLE `banners`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `subtitle` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '副标题',
  `image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片URL',
  `link` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '链接地址',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '轮播图表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of banners
-- ----------------------------
INSERT INTO `banners` VALUES (1, '专业家政服务', '让生活更美好', 'https://pub-141831e61e69445289222976a15b6fb3.r2.dev/Image_to_url_V2/QQ20260228-141301-imagetourl.cloud-1772260094486-4u01be.png', '/services', 1, 1, '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `banners` VALUES (2, '智能匹配', '为您推荐最适合的家政人员', 'https://pub-141831e61e69445289222976a15b6fb3.r2.dev/Image_to_url_V2/QQ20260228-141338-imagetourl.cloud-1772259461373-c9kyqi.png', '/smart-match', 2, 1, '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `banners` VALUES (3, '品质保证', '严格审核，放心选择', 'https://pub-141831e61e69445289222976a15b6fb3.r2.dev/Image_to_url_V2/QQ20260228-141536-imagetourl.cloud-1772259488169-ldgkwz.png', '', 3, 1, '2026-03-01 14:07:35', '2026-03-01 14:07:35');

-- ----------------------------
-- Table structure for certifications
-- ----------------------------
DROP TABLE IF EXISTS `certifications`;
CREATE TABLE `certifications`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `worker_id` bigint NOT NULL,
  `cert_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `cert_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `issue_date` date NULL DEFAULT NULL,
  `expiry_date` date NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'pending',
  `verify_time` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_cert_worker`(`worker_id` ASC) USING BTREE,
  CONSTRAINT `fk_cert_worker` FOREIGN KEY (`worker_id`) REFERENCES `workers` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of certifications
-- ----------------------------

-- ----------------------------
-- Table structure for favorites
-- ----------------------------
DROP TABLE IF EXISTS `favorites`;
CREATE TABLE `favorites`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `worker_id` bigint NOT NULL COMMENT '家政人员ID',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_worker`(`user_id` ASC, `worker_id` ASC) USING BTREE,
  INDEX `worker_id`(`worker_id` ASC) USING BTREE,
  CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`worker_id`) REFERENCES `workers` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户收藏表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of favorites
-- ----------------------------
INSERT INTO `favorites` VALUES (1, 12, 2, '2026-03-10 14:33:30');
INSERT INTO `favorites` VALUES (2, 21, 2, '2026-03-10 14:46:02');

-- ----------------------------
-- Table structure for feedbacks
-- ----------------------------
DROP TABLE IF EXISTS `feedbacks`;
CREATE TABLE `feedbacks`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL DEFAULT NULL,
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `user_avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '反馈类型: suggestion-功能建议, bug-问题反馈, complaint-投诉, other-其他',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `contact` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '状态: pending-待处理, processing-处理中, resolved-已解决, closed-已关闭',
  `is_urgent` int NULL DEFAULT NULL,
  `reply_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '回复内容',
  `replied_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '回复人',
  `replied_at` datetime NULL DEFAULT NULL COMMENT '回复时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户反馈表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of feedbacks
-- ----------------------------
INSERT INTO `feedbacks` VALUES (1, NULL, '张三', NULL, 'suggestion', '建议增加夜间服务模式', '希望平台能增加夜间服务模式，方便上班族晚上预约保洁服务。', '13800138000', 'resolved', 0, '我们会进行改善的', '管理员', '2026-03-10 14:51:15', '2026-01-15 14:30:00', '2026-03-10 14:51:15');
INSERT INTO `feedbacks` VALUES (2, NULL, '李四', NULL, 'bug', '订单支付出现问题', '在支付订单时提示\"系统错误\"，无法完成支付，请尽快修复。', '13900139000', 'processing', 1, NULL, NULL, NULL, '2026-01-15 13:20:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (3, NULL, '王五', NULL, 'complaint', '对家政人员服务不满意', '预约的保洁阿姨服务态度不好，打扫也不干净，要求退款。', '13700137000', 'resolved', 0, '非常抱歉给您带来不好的体验！我们已对涉事阿姨进行严肃处理，并为您办理全额退款。', '客服主管', '2026-01-14 09:00:00', '2026-01-14 16:45:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (4, NULL, '赵六', NULL, 'suggestion', '希望增加更多服务类型', '建议增加家电维修、管道疏通等服务类型，满足更多家庭需求。', '13600136000', 'pending', 0, NULL, NULL, NULL, '2026-01-16 09:15:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (5, NULL, '钱七', NULL, 'bug', 'APP闪退问题', '打开APP后经常闪退，特别是在查看订单详情时，影响使用体验。', '13500135000', 'processing', 1, NULL, NULL, NULL, '2026-01-16 11:30:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (6, NULL, '孙八', NULL, 'complaint', '预约时间被无故取消', '明明预约成功了，却被系统无故取消，没有任何通知，非常不满意。', '13400134000', 'pending', 1, NULL, NULL, NULL, '2026-01-16 14:20:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (7, NULL, '周九', NULL, 'suggestion', '建议优化搜索功能', '搜索家政人员时，希望能按价格区间、工作经验等条件筛选。', '13300133000', 'resolved', 0, '感谢您的建议！我们已将夜间服务模式列入开发计划，预计下月上线，敬请期待。', '客服小张', '2026-01-16 10:00:00', '2026-01-13 10:00:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (8, NULL, '吴十', NULL, 'other', '咨询合作事宜', '我是家政公司负责人，想了解如何入驻平台，成为合作伙伴。', '13200132000', 'closed', 0, '感谢您的咨询！合作事宜请联系商务部门，电话：400-888-8888，邮箱：business@jiazheng.com', '客服小李', '2026-01-13 09:30:00', '2026-01-12 16:00:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (9, NULL, '郑十一', NULL, 'bug', '定位功能不准确', '定位功能总是显示错误的位置，导致推荐的家政人员距离太远。', '13100131000', 'processing', 0, NULL, NULL, NULL, '2026-01-17 08:45:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (10, NULL, '陈十二', NULL, 'complaint', '收费不透明', '服务完成后被告知需要额外支付材料费，事先没有告知，感觉被坑了。', '13000130000', 'pending', 1, NULL, NULL, NULL, '2026-01-17 13:10:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (11, NULL, '林十三', NULL, 'suggestion', '建议增加评价奖励机制', '希望平台能对积极评价的用户给予积分奖励，提高评价率。', '12900129000', 'pending', 0, NULL, NULL, NULL, '2026-01-17 15:30:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (12, NULL, '黄十四', NULL, 'bug', '无法上传头像', '在个人中心上传头像时一直提示\"上传失败\"，换了多张图片都不行。', '12800128000', 'resolved', 0, '头像上传问题已修复，请重新尝试。如仍有问题，请检查图片格式是否为jpg或png，大小不超过2MB。', '技术客服', '2026-01-12 09:00:00', '2026-01-11 11:20:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (13, NULL, '刘十五', NULL, 'complaint', '客服响应太慢', '遇到问题联系客服，等了半天都没人回复，服务体验太差。', '12700127000', 'processing', 1, NULL, NULL, NULL, '2026-01-18 09:00:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (14, NULL, '杨十六', NULL, 'suggestion', '建议增加服务套餐', '希望能推出定期保洁套餐，比如每周一次、每月四次的优惠套餐。', '12600126000', 'pending', 0, NULL, NULL, NULL, '2026-01-18 14:45:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (15, NULL, '朱十七', NULL, 'other', '表扬优秀员工', '上次预约的李阿姨服务非常好，工作认真细致，特此表扬！', '12500125000', 'resolved', 0, '感谢您的表扬！我们会将您的认可转达给李阿姨，并为她申请优秀员工奖励。', '客服小王', '2026-01-11 10:00:00', '2026-01-10 16:30:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (16, NULL, '徐十八', NULL, 'bug', '优惠券无法使用', '账户里有优惠券，但下单时显示\"优惠券不可用\"，明明在有效期内。', '12400124000', 'processing', 0, NULL, NULL, NULL, '2026-01-19 10:15:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (17, NULL, '胡十九', NULL, 'complaint', '家政人员迟到', '预约的阿姨迟到了2个小时，严重影响我的安排，希望平台加强管理。', '12300123000', 'pending', 1, NULL, NULL, NULL, '2026-01-19 13:40:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (18, NULL, '郭二十', NULL, 'suggestion', '建议增加在线客服', '希望平台能增加在线客服功能，有问题能及时得到解答。', '12200122000', 'resolved', 0, '感谢您的建议！在线客服功能已上线，您可以在\"我的\"-\"在线客服\"中随时咨询。', '客服小陈', '2026-01-10 14:00:00', '2026-01-09 11:00:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (19, NULL, '何二十一', NULL, 'bug', '推送通知太多', '每天收到大量推送通知，很烦人，希望能设置通知偏好。', '12100121000', 'closed', 0, NULL, NULL, NULL, '2026-01-20 08:30:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (20, NULL, '高二十二', NULL, 'complaint', '退款迟迟不到账', '申请退款已经一周了，钱还没退回来，客服也说不清楚原因。', '12000120000', 'processing', 1, NULL, NULL, NULL, '2026-01-20 15:20:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (21, NULL, '马二十三', NULL, 'suggestion', '建议增加服务跟踪', '希望能实时查看家政人员的位置和服务进度，更放心。', '11900119000', 'pending', 0, NULL, NULL, NULL, '2026-01-21 09:45:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (22, NULL, '罗二十四', NULL, 'other', '询问发票问题', '服务完成后如何开具发票？需要提供哪些信息？', '11800118000', 'resolved', 0, '发票可以在订单完成后，在\"订单详情\"-\"申请发票\"中提交申请，我们会尽快为您开具。', '客服小刘', '2026-01-09 10:30:00', '2026-01-08 14:00:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (23, NULL, '梁二十五', NULL, 'bug', '密码重置失败', '点击\"忘记密码\"后收不到验证码，无法重置密码。', '11700117000', 'processing', 1, NULL, NULL, NULL, '2026-01-21 11:30:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (24, NULL, '宋二十六', NULL, 'complaint', '服务质量参差不齐', '不同家政人员的服务质量差异很大，希望能统一培训标准。', '11600116000', 'pending', 0, NULL, NULL, NULL, '2026-01-22 10:00:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (25, NULL, '郑二十七', NULL, 'suggestion', '建议增加会员等级', '希望能推出会员等级制度，等级越高享受越多优惠。', '11500115000', 'resolved', 0, '感谢您的建议！会员等级制度正在开发中，预计近期上线，届时会有更多专属优惠。', '客服小赵', '2026-01-08 11:00:00', '2026-01-07 16:15:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (26, NULL, '谢二十八', NULL, 'bug', '分享功能失效', '点击分享按钮没有反应，无法分享给朋友。', '11400114000', 'closed', 0, NULL, NULL, NULL, '2026-01-22 13:45:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (27, NULL, '韩二十九', NULL, 'complaint', '被家政人员索要小费', '服务完成后阿姨暗示要给小费，不给就态度不好，这种情况怎么处理？', '11300113000', 'processing', 1, NULL, NULL, NULL, '2026-01-23 09:30:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (28, NULL, '唐三十', NULL, 'suggestion', '建议增加服务预约提醒', '希望能在服务前1小时发送提醒，避免忘记预约时间。', '11200112000', 'pending', 0, NULL, NULL, NULL, '2026-01-23 14:20:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (29, NULL, '冯三十一', NULL, 'other', '咨询企业合作', '我们公司有50名员工，想统一购买保洁服务，有团购优惠吗？', '11100111000', 'resolved', 0, '感谢您的咨询！企业团购可享受8折优惠，具体请联系企业客服：400-888-8888转3。', '客服小吴', '2026-01-07 10:00:00', '2026-01-06 11:45:00', '2026-03-01 19:20:37');
INSERT INTO `feedbacks` VALUES (30, NULL, '于三十二', NULL, 'bug', '收藏功能异常', '收藏的家政人员显示不出来，但取消收藏又提示\"未收藏\"。', '11000110000', 'processing', 0, NULL, NULL, NULL, '2026-01-24 10:30:00', '2026-03-01 19:20:37');

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息类型：order-订单, system-系统, promotion-促销',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '内容',
  `is_read` tinyint NULL DEFAULT 0 COMMENT '是否已读：0-未读，1-已读',
  `link` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跳转链接',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '消息通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notifications
-- ----------------------------

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单编号',
  `order_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT '订单状态：pending-待服务, processing-服务中, completed-已完成, cancelled-已取消',
  `user_id` bigint NOT NULL COMMENT '用户ID，关联users表',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户姓名（冗余字段）',
  `user_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户电话（冗余字段）',
  `user_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '服务地址',
  `worker_id` bigint NOT NULL COMMENT '服务人员ID，关联workers表',
  `worker_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '服务人员姓名（冗余字段）',
  `worker_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '服务人员电话（冗余字段）',
  `service_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '服务类型',
  `service_date` date NOT NULL COMMENT '服务日期',
  `start_time` time NOT NULL COMMENT '开始时间',
  `end_time` time NOT NULL COMMENT '结束时间',
  `duration` int NOT NULL COMMENT '服务时长（分钟）',
  `service_price` decimal(10, 2) NOT NULL COMMENT '服务单价（元/小时）',
  `total_amount` decimal(10, 2) NOT NULL COMMENT '订单总金额',
  `payment_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unpaid' COMMENT '支付状态：unpaid-未支付, paid-已支付, refunded-已退款',
  `payment_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付方式：alipay-支付宝, wechat-微信, bank-银行转账, cash-现金',
  `payment_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `transaction_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付交易ID',
  `rating` int NULL DEFAULT NULL,
  `review_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '评价内容',
  `review_time` datetime NULL DEFAULT NULL COMMENT '评价时间',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `cancel_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '取消原因',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `user_remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '用户备注',
  `admin_remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '管理员备注',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_worker_id`(`worker_id` ASC) USING BTREE,
  INDEX `idx_order_status`(`order_status` ASC) USING BTREE,
  INDEX `idx_service_date`(`service_date` ASC) USING BTREE,
  INDEX `idx_payment_status`(`payment_status` ASC) USING BTREE,
  INDEX `idx_service_type`(`service_type` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 165 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (1, 'ORD20260228001', 'completed', 1, '王先生', '13800138001', '北京市东城区王府井大街1号', 1, '张阿姨', '13900139001', '保洁服务', '2026-02-28', '09:00:00', '11:00:00', 120, 80.00, 160.00, 'paid', 'alipay', '2026-02-27 10:05:00', '20260227100500123456', 5, '服务非常好，阿姨很专业', '2026-02-28 11:30:00', '需要清洁厨房和卫生间', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (2, 'ORD20260228002', 'completed', 2, '李女士', '13900139002', '北京市西城区西单大街120号', 2, '李师傅', '13800138002', '月嫂服务', '2026-02-27', '00:00:00', '23:59:59', 1440, 3000.00, 3000.00, 'paid', 'wechat', '2026-02-26 09:10:00', '20260226091000123456', 5, '月嫂服务非常专业，照顾宝宝很细心', '2026-02-27 19:00:00', '需要24小时陪护', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (3, 'ORD20260228003', 'completed', 3, '张先生', '13700137001', '北京市朝阳区建国路88号', 3, '王阿姨', '13600136001', '护理服务', '2026-02-26', '14:00:00', '16:00:00', 120, 100.00, 200.00, 'paid', 'alipay', '2026-02-25 10:05:00', '20260225100500123456', 4, '护理服务很专业，态度很好', '2026-02-26 16:30:00', '需要术后护理', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (4, 'ORD20260228004', 'completed', 4, '刘女士', '13600136002', '北京市海淀区中关村大街1号', 4, '陈师傅', '13500135001', '钟点工', '2026-02-25', '10:00:00', '12:00:00', 120, 60.00, 120.00, 'paid', 'cash', '2026-02-25 12:00:00', NULL, 5, '钟点工服务很及时，打扫很干净', '2026-02-25 12:30:00', '需要打扫客厅和卧室', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (5, 'ORD20260228005', 'completed', 5, '赵先生', '13500135002', '北京市丰台区丰台路100号', 5, '刘阿姨', '13400134001', '育儿嫂', '2026-02-24', '08:00:00', '18:00:00', 600, 250.00, 2500.00, 'paid', 'wechat', '2026-02-23 10:05:00', '20260223100500123456', 5, '育儿嫂很专业，对孩子很有耐心', '2026-02-24 18:30:00', '需要照顾2岁宝宝', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (6, 'ORD20260228006', 'completed', 6, '钱女士', '13400134002', '北京市石景山区石景山路1号', 6, '赵师傅', '13300133001', '老人陪护', '2026-02-23', '08:00:00', '18:00:00', 600, 30.00, 300.00, 'paid', 'cash', '2026-02-23 18:30:00', NULL, 4, '老人陪护服务很好，态度很亲切', '2026-02-23 19:00:00', '需要照顾行动不便的老人', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (7, 'ORD20260228007', 'completed', 7, '孙先生', '13300133002', '北京市东城区东直门外大街42号', 1, '张阿姨', '13900139001', '保洁服务', '2026-02-22', '14:00:00', '16:00:00', 120, 80.00, 160.00, 'paid', 'alipay', '2026-02-21 10:05:00', '20260221100500123456', 5, '保洁服务很彻底，阿姨很认真', '2026-02-22 16:30:00', '需要深度清洁', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (8, 'ORD20260228008', 'completed', 8, '周女士', '13200132001', '北京市西城区金融街15号', 2, '李师傅', '13800138002', '月嫂服务', '2026-02-21', '00:00:00', '23:59:59', 1440, 3000.00, 3000.00, 'paid', 'wechat', '2026-02-20 09:10:00', '20260220091000123456', 5, '月嫂服务很专业，照顾产妇和宝宝都很细心', '2026-02-21 19:00:00', '需要专业月嫂服务', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (9, 'ORD20260228009', 'completed', 9, '吴先生', '13100131001', '北京市朝阳区三里屯路19号', 3, '王阿姨', '13600136001', '护理服务', '2026-02-20', '09:00:00', '11:00:00', 120, 100.00, 200.00, 'paid', 'alipay', '2026-02-19 10:05:00', '20260219100500123456', 4, '护理服务很专业，态度很好', '2026-02-20 11:30:00', '需要照顾老人', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (10, 'ORD20260228010', 'completed', 10, '郑女士', '13000130001', '北京市海淀区学院路30号', 4, '陈师傅', '13500135001', '钟点工', '2026-02-19', '16:00:00', '18:00:00', 120, 60.00, 120.00, 'paid', 'cash', '2026-02-19 18:00:00', NULL, 5, '钟点工服务很及时，打扫很干净', '2026-02-19 18:30:00', '需要做饭和打扫', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (11, 'ORD20260228011', 'completed', 11, '杨先生', '13900139003', '北京市丰台区方庄路1号', 5, '刘阿姨', '13400134001', '育儿嫂', '2026-02-18', '08:00:00', '18:00:00', 600, 250.00, 2500.00, 'paid', 'wechat', '2026-02-17 10:05:00', '20260217100500123456', 5, '育儿嫂很专业，对孩子很有耐心', '2026-02-18 18:30:00', '需要照顾3岁宝宝', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (12, 'ORD20260228012', 'completed', 12, '黄女士', '13800138003', '北京市石景山区苹果园南路1号', 6, '赵师傅', '13300133001', '老人陪护', '2026-02-17', '08:00:00', '18:00:00', 600, 30.00, 300.00, 'paid', 'cash', '2026-02-17 18:30:00', NULL, 4, '老人陪护服务很好，态度很亲切', '2026-02-17 19:00:00', '需要照顾卧床老人', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (13, 'ORD20260228013', 'completed', 13, '周先生', '13700137002', '北京市东城区东单北大街1号', 1, '张阿姨', '13900139001', '保洁服务', '2026-02-16', '09:00:00', '11:00:00', 120, 80.00, 160.00, 'paid', 'alipay', '2026-02-15 10:05:00', '20260215100500123456', 5, '保洁服务很彻底，阿姨很认真', '2026-02-16 11:30:00', '需要清洁客厅和厨房', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (14, 'ORD20260228014', 'completed', 14, '吴女士', '13600136003', '北京市西城区德胜门外大街1号', 2, '李师傅', '13800138002', '月嫂服务', '2026-02-15', '00:00:00', '23:59:59', 1440, 3000.00, 3000.00, 'paid', 'wechat', '2026-02-14 09:10:00', '20260214091000123456', 5, '月嫂服务很专业，照顾产妇和宝宝都很细心', '2026-02-15 19:00:00', '需要24小时陪护', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (15, 'ORD20260228015', 'completed', 15, '郑先生', '13500135003', '北京市朝阳区望京街1号', 3, '王阿姨', '13600136001', '护理服务', '2026-02-14', '14:00:00', '16:00:00', 120, 100.00, 200.00, 'paid', 'alipay', '2026-02-13 10:05:00', '20260213100500123456', 4, '护理服务很专业，态度很好', '2026-02-14 16:30:00', '需要术后护理', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (16, 'ORD20260228016', 'completed', 16, '杨女士', '13400134003', '北京市海淀区中关村南大街5号', 4, '陈师傅', '13500135001', '钟点工', '2026-02-13', '10:00:00', '12:00:00', 120, 60.00, 120.00, 'paid', 'cash', '2026-02-13 12:00:00', NULL, 5, '钟点工服务很及时，打扫很干净', '2026-02-13 12:30:00', '需要打扫书房和客厅', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (17, 'ORD20260228017', 'completed', 17, '黄先生', '13300133003', '北京市丰台区丽泽路1号', 5, '刘阿姨', '13400134001', '育儿嫂', '2026-02-12', '08:00:00', '18:00:00', 600, 250.00, 2500.00, 'paid', 'wechat', '2026-02-11 10:05:00', '20260211100500123456', 5, '育儿嫂很专业，对孩子很有耐心', '2026-02-12 18:30:00', '需要照顾1岁宝宝', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (18, 'ORD20260228018', 'completed', 18, '周女士', '13200132002', '北京市石景山区鲁谷路1号', 6, '赵师傅', '13300133001', '老人陪护', '2026-02-11', '08:00:00', '18:00:00', 600, 30.00, 300.00, 'paid', 'cash', '2026-02-11 18:30:00', NULL, 4, '老人陪护服务很好，态度很亲切', '2026-02-11 19:00:00', '需要照顾行动不便的老人', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (19, 'ORD20260228019', 'completed', 19, '吴先生', '13100131002', '北京市东城区交道口南大街1号', 1, '张阿姨', '13900139001', '保洁服务', '2026-02-10', '14:00:00', '16:00:00', 120, 80.00, 160.00, 'paid', 'alipay', '2026-02-09 10:05:00', '20260209100500123456', 5, '保洁服务很彻底，阿姨很认真', '2026-02-10 16:30:00', '需要深度清洁', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (20, 'ORD20260228020', 'completed', 20, '郑女士', '13000130002', '北京市西城区西长安街1号', 2, '李师傅', '13800138002', '月嫂服务', '2026-02-09', '00:00:00', '23:59:59', 1440, 3000.00, 3000.00, 'paid', 'wechat', '2026-02-08 09:10:00', '20260208091000123456', 5, '月嫂服务很专业，照顾产妇和宝宝都很细心', '2026-02-09 19:00:00', '需要专业月嫂服务', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (22, 'ORD20260228022', 'processing', 22, '黄女士', '13800138004', '北京市海淀区清华大学1号', 4, '陈师傅', '13500135001', '钟点工', '2026-02-28', '10:00:00', '12:00:00', 120, 60.00, 120.00, 'paid', 'cash', '2026-02-28 10:00:00', NULL, NULL, NULL, NULL, '需要打扫实验室', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (23, 'ORD20260228023', 'processing', 23, '周先生', '13700137003', '北京市丰台区北京南站1号', 5, '刘阿姨', '13400134001', '育儿嫂', '2026-02-28', '08:00:00', '18:00:00', 600, 250.00, 2500.00, 'paid', 'wechat', '2026-02-27 10:05:00', '20260227100500123458', NULL, NULL, NULL, '需要照顾2岁宝宝', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (24, 'ORD20260228024', 'processing', 24, '吴女士', '13600136004', '北京市石景山区首钢园1号', 6, '赵师傅', '13300133001', '老人陪护', '2026-02-28', '08:00:00', '18:00:00', 600, 30.00, 300.00, 'paid', 'cash', '2026-02-28 08:00:00', NULL, NULL, NULL, NULL, '需要照顾卧床老人', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (25, 'ORD20260228025', 'processing', 25, '郑先生', '13500135004', '北京市东城区故宫博物院1号', 1, '张阿姨', '13900139001', '保洁服务', '2026-02-28', '14:00:00', '16:00:00', 120, 80.00, 160.00, 'paid', 'alipay', '2026-02-27 10:05:00', '20260227100500123459', NULL, NULL, NULL, '需要深度清洁', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (26, 'ORD20260228026', 'processing', 26, '杨女士', '13400134004', '北京市西城区人民大会堂1号', 2, '李师傅', '13800138002', '月嫂服务', '2026-02-28', '00:00:00', '23:59:59', 1440, 3000.00, 3000.00, 'paid', 'wechat', '2026-02-27 09:10:00', '20260227091000123456', NULL, NULL, NULL, '需要24小时陪护', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (27, 'ORD20260228027', 'processing', 27, '黄先生', '13300133004', '北京市朝阳区CBD商务中心1号', 3, '王阿姨', '13600136001', '护理服务', '2026-02-28', '14:00:00', '16:00:00', 120, 100.00, 200.00, 'paid', 'alipay', '2026-02-27 10:05:00', '20260227100500123460', NULL, NULL, NULL, '需要照顾老人', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (28, 'ORD20260228028', 'processing', 28, '周女士', '13200132003', '北京市海淀区中关村软件园1号', 4, '陈师傅', '13500135001', '钟点工', '2026-02-28', '16:00:00', '18:00:00', 120, 60.00, 120.00, 'paid', 'cash', '2026-02-28 16:00:00', NULL, NULL, NULL, NULL, '需要打扫办公室', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (29, 'ORD20260228029', 'completed', 29, '吴先生', '13100131003', '北京市丰台区丽泽商务区1号', 5, '刘阿姨', '13400134001', '育儿嫂', '2026-02-28', '08:00:00', '18:00:00', 600, 250.00, 2500.00, 'paid', 'wechat', '2026-02-27 10:05:00', '20260227100500123461', 5, '123456', '2026-03-01 16:06:37', '需要照顾3岁宝宝', NULL, '2026-02-28 17:36:59', '2026-03-01 16:06:37', NULL, NULL);
INSERT INTO `orders` VALUES (30, 'ORD20260228030', 'processing', 30, '郑女士', '13000130003', '北京市石景山区八大处公园1号', 6, '赵师傅', '13300133001', '老人陪护', '2026-02-28', '08:00:00', '18:00:00', 600, 30.00, 300.00, 'paid', 'cash', '2026-02-28 08:00:00', NULL, NULL, NULL, NULL, '需要照顾行动不便的老人', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (31, 'ORD20260228031', 'pending', 31, '杨先生', '13900139005', '北京市东城区国子监街1号', 1, '张阿姨', '13900139001', '保洁服务', '2026-03-02', '09:00:00', '11:00:00', 120, 80.00, 160.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要清洁厨房和卫生间', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (32, 'ORD20260228032', 'pending', 32, '黄女士', '13800138005', '北京市西城区北海公园1号', 2, '李师傅', '13800138002', '月嫂服务', '2026-03-02', '00:00:00', '23:59:59', 1440, 3000.00, 3000.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要24小时陪护', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (33, 'ORD20260228033', 'pending', 33, '周先生', '13700137004', '北京市朝阳区奥林匹克公园1号', 3, '王阿姨', '13600136001', '护理服务', '2026-03-02', '14:00:00', '16:00:00', 120, 100.00, 200.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要术后护理', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (34, 'ORD20260228034', 'pending', 34, '吴女士', '13600136005', '北京市海淀区颐和园1号', 4, '陈师傅', '13500135001', '钟点工', '2026-03-02', '10:00:00', '12:00:00', 120, 60.00, 120.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要打扫客厅和卧室', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (35, 'ORD20260228035', 'pending', 35, '郑先生', '13500135005', '北京市丰台区世界公园1号', 5, '刘阿姨', '13400134001', '育儿嫂', '2026-03-02', '08:00:00', '18:00:00', 600, 250.00, 2500.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要照顾2岁宝宝', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (36, 'ORD20260228036', 'pending', 36, '杨女士', '13400134005', '北京市石景山区香山公园1号', 6, '赵师傅', '13300133001', '老人陪护', '2026-03-02', '08:00:00', '18:00:00', 600, 30.00, 300.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要照顾行动不便的老人', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (37, 'ORD20260228037', 'pending', 37, '黄先生', '13300133005', '北京市东城区南锣鼓巷1号', 1, '张阿姨', '13900139001', '保洁服务', '2026-03-02', '14:00:00', '16:00:00', 120, 80.00, 160.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要深度清洁', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (38, 'ORD20260228038', 'pending', 38, '周女士', '13200132004', '北京市西城区什刹海1号', 2, '李师傅', '13800138002', '月嫂服务', '2026-03-02', '00:00:00', '23:59:59', 1440, 3000.00, 3000.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要专业月嫂服务', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (39, 'ORD20260228039', 'pending', 39, '吴先生', '13100131004', '北京市朝阳区三里屯太古里1号', 3, '王阿姨', '13600136001', '护理服务', '2026-03-02', '09:00:00', '11:00:00', 120, 100.00, 200.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要照顾老人', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (40, 'ORD20260228040', 'pending', 40, '郑女士', '13000130004', '北京市海淀区北京大学1号', 4, '陈师傅', '13500135001', '钟点工', '2026-03-02', '16:00:00', '18:00:00', 120, 60.00, 120.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要做饭和打扫', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (41, 'ORD20260228041', 'pending', 41, '杨先生', '13900139006', '北京市丰台区北京西站1号', 5, '刘阿姨', '13400134001', '育儿嫂', '2026-03-03', '08:00:00', '18:00:00', 600, 250.00, 2500.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要照顾3岁宝宝', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (42, 'ORD20260228042', 'pending', 42, '黄女士', '13800138006', '北京市石景山区模式口大街1号', 6, '赵师傅', '13300133001', '老人陪护', '2026-03-03', '08:00:00', '18:00:00', 600, 30.00, 300.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要照顾卧床老人', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (43, 'ORD20260228043', 'pending', 43, '周先生', '13700137005', '北京市东城区前门大街1号', 1, '张阿姨', '13900139001', '保洁服务', '2026-03-03', '09:00:00', '11:00:00', 120, 80.00, 160.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要清洁客厅和厨房', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (44, 'ORD20260228044', 'pending', 44, '吴女士', '13600136006', '北京市西城区阜成门内大街1号', 2, '李师傅', '13800138002', '月嫂服务', '2026-03-03', '00:00:00', '23:59:59', 1440, 3000.00, 3000.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要24小时陪护', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (45, 'ORD20260228045', 'pending', 45, '郑先生', '13500135006', '北京市朝阳区望京SOHO1号', 3, '王阿姨', '13600136001', '护理服务', '2026-03-03', '14:00:00', '16:00:00', 120, 100.00, 200.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要术后护理', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (46, 'ORD20260228046', 'pending', 46, '杨女士', '13400134006', '北京市海淀区中关村大街1号', 4, '陈师傅', '13500135001', '钟点工', '2026-03-03', '10:00:00', '12:00:00', 120, 60.00, 120.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要打扫书房和客厅', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (47, 'ORD20260228047', 'pending', 47, '黄先生', '13300133006', '北京市丰台区丰台体育中心1号', 5, '刘阿姨', '13400134001', '育儿嫂', '2026-03-03', '08:00:00', '18:00:00', 600, 250.00, 2500.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要照顾1岁宝宝', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (48, 'ORD20260228048', 'pending', 48, '周女士', '13200132005', '北京市石景山区金顶街1号', 6, '赵师傅', '13300133001', '老人陪护', '2026-03-03', '08:00:00', '18:00:00', 600, 30.00, 300.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要照顾行动不便的老人', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (49, 'ORD20260228049', 'pending', 49, '吴先生', '13100131005', '北京市东城区东直门内大街1号', 1, '张阿姨', '13900139001', '保洁服务', '2026-03-03', '14:00:00', '16:00:00', 120, 80.00, 160.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要深度清洁', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (50, 'ORD20260228050', 'pending', 50, '郑女士', '13000130005', '北京市西城区西单北大街1号', 2, '李师傅', '13800138002', '月嫂服务', '2026-03-03', '00:00:00', '23:59:59', 1440, 3000.00, 3000.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '需要专业月嫂服务', NULL, '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (51, 'ORD20260228051', 'cancelled', 51, '杨先生', '13900139007', '北京市朝阳区国贸中心1号', 3, '王阿姨', '13600136001', '护理服务', '2026-02-28', '09:00:00', '11:00:00', 120, 100.00, 200.00, 'refunded', 'alipay', '2026-02-27 10:05:00', '20260227100500123462', NULL, NULL, NULL, '需要术后护理', '临时有事，无法按时服务', '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (52, 'ORD20260228052', 'cancelled', 52, '黄女士', '13800138007', '北京市海淀区中关村南大街1号', 4, '陈师傅', '13500135001', '钟点工', '2026-02-28', '10:00:00', '12:00:00', 120, 60.00, 120.00, 'refunded', 'cash', '2026-02-28 10:00:00', NULL, NULL, NULL, NULL, '需要打扫办公室', '工作安排变动，无法按时服务', '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (53, 'ORD20260228053', 'cancelled', 53, '周先生', '13700137006', '北京市丰台区丽泽桥1号', 5, '刘阿姨', '13400134001', '育儿嫂', '2026-02-28', '08:00:00', '18:00:00', 600, 250.00, 2500.00, 'refunded', 'wechat', '2026-02-27 10:05:00', '20260227100500123463', NULL, NULL, NULL, '需要照顾2岁宝宝', '孩子生病，暂时不需要服务', '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (54, 'ORD20260228054', 'cancelled', 54, '吴女士', '13600136007', '北京市石景山区苹果园大街1号', 6, '赵师傅', '13300133001', '老人陪护', '2026-02-28', '08:00:00', '18:00:00', 600, 30.00, 300.00, 'refunded', 'cash', '2026-02-28 08:00:00', NULL, NULL, NULL, NULL, '需要照顾卧床老人', '老人住院，暂时不需要服务', '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (55, 'ORD20260228055', 'cancelled', 55, '郑先生', '13500135007', '北京市东城区王府井大街1号', 1, '张阿姨', '13900139001', '保洁服务', '2026-02-28', '14:00:00', '16:00:00', 120, 80.00, 160.00, 'refunded', 'alipay', '2026-02-27 10:05:00', '20260227100500123464', NULL, NULL, NULL, '需要深度清洁', '临时出差，无法按时服务', '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (56, 'ORD20260228056', 'cancelled', 56, '杨女士', '13400134007', '北京市西城区金融街1号', 2, '李师傅', '13800138002', '月嫂服务', '2026-02-28', '00:00:00', '23:59:59', 1440, 3000.00, 3000.00, 'refunded', 'wechat', '2026-02-27 09:10:00', '20260227091000123465', NULL, NULL, NULL, '需要24小时陪护', '生产时间推迟，暂时不需要服务', '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (57, 'ORD20260228057', 'cancelled', 57, '黄先生', '13300133007', '北京市朝阳区三里屯1号', 3, '王阿姨', '13600136001', '护理服务', '2026-02-28', '14:00:00', '16:00:00', 120, 100.00, 200.00, 'refunded', 'alipay', '2026-02-27 10:05:00', '20260227100500123466', NULL, NULL, NULL, '需要照顾老人', '老人康复，暂时不需要服务', '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (58, 'ORD20260228058', 'cancelled', 58, '周女士', '13200132006', '北京市海淀区清华大学1号', 4, '陈师傅', '13500135001', '钟点工', '2026-02-28', '16:00:00', '18:00:00', 120, 60.00, 120.00, 'refunded', 'cash', '2026-02-28 16:00:00', NULL, NULL, NULL, NULL, '需要打扫实验室', '实验取消，暂时不需要服务', '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (59, 'ORD20260228059', 'cancelled', 59, '吴先生', '13100131006', '北京市丰台区北京南站1号', 5, '刘阿姨', '13400134001', '育儿嫂', '2026-02-28', '08:00:00', '18:00:00', 600, 250.00, 2500.00, 'refunded', 'wechat', '2026-02-27 10:05:00', '20260227100500123467', NULL, NULL, NULL, '需要照顾3岁宝宝', '孩子去外婆家，暂时不需要服务', '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (60, 'ORD20260228060', 'cancelled', 60, '郑女士', '13000130006', '北京市石景山区首钢园1号', 6, '赵师傅', '13300133001', '老人陪护', '2026-02-28', '08:00:00', '18:00:00', 600, 30.00, 300.00, 'refunded', 'cash', '2026-02-28 08:00:00', NULL, NULL, NULL, NULL, '需要照顾行动不便的老人', '老人转院，暂时不需要服务', '2026-02-28 17:36:59', '2026-02-28 17:36:59', NULL, NULL);
INSERT INTO `orders` VALUES (121, 'ORD20260228184414', 'pending', 1, '用户1', '15478956864', '河北省保定市莲池区', 7, '孙师傅', '13321098765', '家庭保洁', '2026-03-03', '18:36:00', '20:36:00', 120, 95.00, 190.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '', NULL, '2026-02-28 18:44:15', '2026-02-28 18:44:15', NULL, NULL);
INSERT INTO `orders` VALUES (122, 'ORD20260228185509', 'cancelled', 12, '用户12', '15789456721', '河北省保定市莲池区', 1, '张阿姨', '13812345678', '家庭保洁', '2026-03-04', '18:54:00', '20:54:00', 120, 80.00, 160.00, 'refunded', NULL, NULL, NULL, NULL, NULL, NULL, '', NULL, '2026-02-28 18:55:10', '2026-02-28 20:24:27', NULL, NULL);
INSERT INTO `orders` VALUES (123, 'ORD20260228185613', 'pending', 1, '用户1', '15478956864', '河北省保定市莲池区', 7, '孙师傅', '13321098765', '家庭保洁', '2026-03-03', '18:36:00', '20:36:00', 120, 95.00, 190.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '', NULL, '2026-02-28 18:56:13', '2026-02-28 18:56:13', NULL, NULL);
INSERT INTO `orders` VALUES (124, 'ORD20260228185940', 'pending', 12, '用户12', '15478956864', '河北省保定市莲池区', 1, '张阿姨', '13812345678', '家庭保洁', '2026-03-06', '18:59:00', '20:59:00', 120, 80.00, 160.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '', NULL, '2026-02-28 18:59:41', '2026-02-28 18:59:41', NULL, NULL);
INSERT INTO `orders` VALUES (125, 'ORD20260228191611', 'pending', 12, '用户12', '15696574532', '河北省保定市莲池区', 1, '张阿姨', '13812345678', '保洁服务', '2026-03-05', '19:15:00', '21:15:00', 120, 80.00, 160.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '', NULL, '2026-02-28 19:16:11', '2026-02-28 19:16:11', NULL, NULL);
INSERT INTO `orders` VALUES (126, 'ORD20260228192046', 'pending', 1, '用户1', '15478956864', '河北省保定市莲池区', 7, '孙师傅', '13321098765', '保洁服务', '2026-03-03', '18:36:00', '20:36:00', 120, 95.00, 190.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '', NULL, '2026-02-28 19:20:47', '2026-02-28 19:20:47', NULL, NULL);
INSERT INTO `orders` VALUES (127, 'ORD20260228202239', 'pending', 12, '用户12', '15133261589', '河北省', 1, '张阿姨', '13812345678', '保洁服务', '2026-03-02', '20:21:00', '22:21:00', 120, 80.00, 160.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, '', NULL, '2026-02-28 20:22:39', '2026-02-28 20:22:39', NULL, NULL);
INSERT INTO `orders` VALUES (128, 'ORD20260301001', 'pending', 21, '陈伟', '13800138001', '北京市朝阳区建国路1号', 201, '张建国', '13900139001', '老人陪护', '2026-03-05', '08:00:00', '12:00:00', 240, 50.00, 200.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-01 14:19:52', '2026-03-01 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (129, 'ORD20260301002', 'pending', 22, '刘梅', '13800138002', '北京市海淀区中关村大街2号', 202, '李秀英', '13900139002', '月嫂服务', '2026-03-06', '09:00:00', '17:00:00', 480, 45.00, 360.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-01 14:19:52', '2026-03-01 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (130, 'ORD20260301003', 'pending', 23, '王军', '13800138003', '北京市西城区金融街3号', 203, '王德明', '13900139003', '家庭保洁', '2026-03-07', '14:00:00', '18:00:00', 240, 40.00, 160.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-01 14:19:52', '2026-03-01 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (131, 'ORD20260301014', 'pending', 25, '孙丽', '13800138005', '上海市浦东新区世纪大道100号', 212, '胡秀芳', '13900139012', '月嫂服务', '2026-03-08', '08:00:00', '16:00:00', 480, 43.00, 344.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-01 14:19:52', '2026-03-01 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (132, 'ORD20260301015', 'pending', 26, '周强', '13800138006', '广州市天河区天河路208号', 211, '孙德胜', '13900139011', '老人陪护', '2026-03-09', '09:00:00', '17:00:00', 480, 52.00, 416.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-01 14:19:52', '2026-03-01 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (133, 'ORD20260301016', 'pending', 27, '吴杰', '13800138007', '深圳市南山区科技园1号', 213, '郭志刚', '13900139013', '深度清洁', '2026-03-10', '10:00:00', '16:00:00', 360, 47.00, 282.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-01 14:19:52', '2026-03-01 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (134, 'ORD20260301004', 'processing', 21, '陈伟', '13800138001', '北京市朝阳区建国路1号', 204, '张淑芬', '13900139004', '钟点工', '2026-03-01', '08:00:00', '12:00:00', 240, 35.00, 140.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-27 14:19:52', '2026-03-01 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (135, 'ORD20260301005', 'processing', 22, '刘梅', '13800138002', '北京市海淀区中关村大街2号', 205, '刘志强', '13900139005', '护理服务', '2026-03-01', '09:00:00', '15:00:00', 360, 55.00, 330.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-27 14:19:52', '2026-03-01 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (136, 'ORD20260301017', 'processing', 28, '徐佳', '13800138008', '杭州市西湖区教工路42号', 214, '马秀云', '13900139014', '钟点工', '2026-03-01', '14:00:00', '18:00:00', 240, 44.00, 176.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-27 14:19:52', '2026-03-01 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (137, 'ORD20260301018', 'completed', 29, '黄涛', '13800138009', '成都市锦江区春熙路1号', 215, '高建军', '13900139015', '家电清洗', '2026-03-01', '10:00:00', '14:00:00', 240, 41.00, 164.00, 'paid', NULL, NULL, NULL, 5, '123456', '2026-03-01 17:50:54', NULL, NULL, '2026-02-27 14:19:52', '2026-03-01 17:50:54', NULL, NULL);
INSERT INTO `orders` VALUES (138, 'ORD20260301019', 'processing', 30, '杨帆', '13800138010', '武汉市江汉区解放大道100号', 208, '周秀兰', '13900139008', '育儿服务', '2026-03-01', '08:00:00', '16:00:00', 480, 46.00, 368.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-27 14:19:52', '2026-03-01 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (139, 'ORD20260301006', 'completed', 21, '陈伟', '13800138001', '北京市朝阳区建国路1号', 206, '陈玉兰', '13900139006', '月嫂服务', '2026-02-25', '08:00:00', '16:00:00', 480, 48.00, 384.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-24 14:19:52', '2026-02-28 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (140, 'ORD20260301007', 'completed', 22, '刘梅', '13800138002', '北京市海淀区中关村大街2号', 207, '杨志明', '13900139007', '家电清洗', '2026-02-26', '10:00:00', '14:00:00', 240, 42.00, 168.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-25 14:19:52', '2026-02-27 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (141, 'ORD20260301008', 'completed', 23, '王军', '13800138003', '北京市西城区金融街3号', 208, '周秀兰', '13900139008', '育儿服务', '2026-02-27', '09:00:00', '17:00:00', 480, 46.00, 368.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-26 14:19:52', '2026-02-28 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (142, 'ORD20260301020', 'completed', 24, '赵静', '13800138004', '北京市东城区王府井4号', 210, '郑美玲', '13900139010', '保洁服务', '2026-02-24', '14:00:00', '18:00:00', 240, 38.00, 152.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-23 14:19:52', '2026-02-26 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (143, 'ORD20260301021', 'completed', 25, '孙丽', '13800138005', '上海市浦东新区世纪大道100号', 212, '胡秀芳', '13900139012', '月嫂服务', '2026-02-23', '08:00:00', '16:00:00', 480, 43.00, 344.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-22 14:19:52', '2026-02-25 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (144, 'ORD20260301022', 'completed', 26, '周强', '13800138006', '广州市天河区天河路208号', 211, '孙德胜', '13900139011', '老人陪护', '2026-02-22', '09:00:00', '17:00:00', 480, 52.00, 416.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-21 14:19:52', '2026-02-24 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (145, 'ORD20260301009', 'completed', 21, '陈伟', '13800138001', '北京市朝阳区建国路1号', 209, '吴德贵', '13900139009', '管家服务', '2026-02-20', '08:00:00', '18:00:00', 600, 60.00, 600.00, 'paid', NULL, NULL, NULL, 5, '吴师傅非常专业，把家里打理得井井有条，很满意！', '2026-02-21 14:19:52', NULL, NULL, '2026-02-19 14:19:52', '2026-02-21 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (146, 'ORD20260301010', 'completed', 22, '刘梅', '13800138002', '北京市海淀区中关村大街2号', 210, '郑美玲', '13900139010', '保洁服务', '2026-02-22', '14:00:00', '18:00:00', 240, 38.00, 152.00, 'paid', NULL, NULL, NULL, 4, '郑阿姨打扫得很干净，人也热情，就是稍微慢了一点', '2026-02-22 14:19:52', NULL, NULL, '2026-02-20 14:19:52', '2026-02-22 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (147, 'ORD20260301011', 'completed', 23, '王军', '13800138003', '北京市西城区金融街3号', 201, '张建国', '13900139001', '老人陪护', '2026-02-23', '09:00:00', '17:00:00', 480, 50.00, 400.00, 'paid', NULL, NULL, NULL, 5, '张师傅非常有耐心，老人很喜欢他，下次还找他', '2026-02-23 14:19:52', NULL, NULL, '2026-02-21 14:19:52', '2026-02-23 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (148, 'ORD20260301023', 'completed', 24, '赵静', '13800138004', '北京市东城区王府井4号', 202, '李秀英', '13900139002', '月嫂服务', '2026-02-19', '08:00:00', '16:00:00', 480, 45.00, 360.00, 'paid', NULL, NULL, NULL, 5, '李阿姨照顾宝宝很专业，很有爱心，推荐！', '2026-02-20 14:19:52', NULL, NULL, '2026-02-18 14:19:52', '2026-02-20 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (149, 'ORD20260301024', 'completed', 25, '孙丽', '13800138005', '上海市浦东新区世纪大道100号', 203, '王德明', '13900139003', '深度清洁', '2026-02-18', '09:00:00', '15:00:00', 360, 40.00, 240.00, 'paid', NULL, NULL, NULL, 5, '王师傅干活特别仔细，角落里都打扫到了，很好', '2026-02-19 14:19:52', NULL, NULL, '2026-02-17 14:19:52', '2026-02-19 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (150, 'ORD20260301025', 'completed', 26, '周强', '13800138006', '广州市天河区天河路208号', 206, '陈玉兰', '13900139006', '月嫂服务', '2026-02-17', '08:00:00', '16:00:00', 480, 48.00, 384.00, 'paid', NULL, NULL, NULL, 5, '陈阿姨经验丰富，把宝宝照顾得很好，月子餐也很美味', '2026-02-18 14:19:52', NULL, NULL, '2026-02-16 14:19:52', '2026-02-18 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (151, 'ORD20260301026', 'completed', 27, '吴杰', '13800138007', '深圳市南山区科技园1号', 205, '刘志强', '13900139005', '康复护理', '2026-02-16', '09:00:00', '15:00:00', 360, 55.00, 330.00, 'paid', NULL, NULL, NULL, 5, '刘师傅专业水平高，帮我父亲做康复训练，效果很好', '2026-02-17 14:19:52', NULL, NULL, '2026-02-15 14:19:52', '2026-02-17 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (152, 'ORD20260301027', 'completed', 28, '徐佳', '13800138008', '杭州市西湖区教工路42号', 208, '周秀兰', '13900139008', '育儿服务', '2026-02-15', '08:00:00', '16:00:00', 480, 46.00, 368.00, 'paid', NULL, NULL, NULL, 4, '周阿姨对孩子很有耐心，还会教英语儿歌', '2026-02-16 14:19:52', NULL, NULL, '2026-02-14 14:19:52', '2026-02-16 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (153, 'ORD20260301028', 'completed', 29, '黄涛', '13800138009', '成都市锦江区春熙路1号', 213, '郭志刚', '13900139013', '地毯清洗', '2026-02-14', '10:00:00', '14:00:00', 240, 47.00, 188.00, 'paid', NULL, NULL, NULL, 5, '地毯洗得跟新的一样，技术很好', '2026-02-15 14:19:52', NULL, NULL, '2026-02-13 14:19:52', '2026-02-15 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (154, 'ORD20260301029', 'completed', 30, '杨帆', '13800138010', '武汉市江汉区解放大道100号', 214, '马秀云', '13900139014', '做饭', '2026-02-13', '11:00:00', '13:00:00', 120, 44.00, 88.00, 'paid', NULL, NULL, NULL, 5, '马阿姨做的菜特别好吃，很合我们口味', '2026-02-14 14:19:52', NULL, NULL, '2026-02-12 14:19:52', '2026-02-14 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (155, 'ORD20260301012', 'cancelled', 24, '赵静', '13800138004', '北京市东城区王府井4号', 202, '李秀英', '13900139002', '月嫂服务', '2026-02-28', '08:00:00', '16:00:00', 480, 45.00, 360.00, 'refunded', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '临时有事，需要取消服务', '2026-02-26 14:19:52', '2026-02-27 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (156, 'ORD20260301013', 'cancelled', 21, '陈伟', '13800138001', '北京市朝阳区建国路1号', 203, '王德明', '13900139003', '家庭保洁', '2026-02-24', '10:00:00', '14:00:00', 240, 40.00, 160.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '选错时间了，重新预约', '2026-02-22 14:19:52', '2026-02-23 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (157, 'ORD20260301030', 'cancelled', 25, '孙丽', '13800138005', '上海市浦东新区世纪大道100号', 212, '胡秀芳', '13900139012', '月嫂服务', '2026-02-26', '08:00:00', '16:00:00', 480, 43.00, 344.00, 'refunded', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '家人临时来帮忙', '2026-02-24 14:19:52', '2026-02-25 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (158, 'ORD20260301031', 'cancelled', 26, '周强', '13800138006', '广州市天河区天河路208号', 211, '孙德胜', '13900139011', '老人陪护', '2026-02-27', '09:00:00', '17:00:00', 480, 52.00, 416.00, 'unpaid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '行程变更', '2026-02-25 14:19:52', '2026-02-26 14:19:52', NULL, NULL);
INSERT INTO `orders` VALUES (159, 'ORD20260302001', 'pending', 42, '孙八', '13912345601', '北京市丰台区南四环西路5号', 2, '李秀英', '13900139002', '月嫂服务', '2026-03-10', '08:00:00', '16:00:00', 480, 45.00, 360.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-03-01 14:24:50', '2026-03-01 14:24:50', NULL, NULL);
INSERT INTO `orders` VALUES (160, 'ORD20260302002', 'completed', 42, '孙八', '13912345601', '北京市丰台区南四环西路5号', 3, '王德明', '13900139003', '家庭保洁', '2026-02-20', '09:00:00', '13:00:00', 240, 40.00, 160.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-19 14:24:50', '2026-02-21 14:24:50', NULL, NULL);
INSERT INTO `orders` VALUES (161, 'ORD20260302003', 'completed', 42, '孙八', '13912345601', '北京市丰台区南四环西路5号', 4, '张淑芬', '13900139004', '钟点工', '2026-02-25', '14:00:00', '18:00:00', 240, 35.00, 140.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-24 14:24:50', '2026-02-26 14:24:50', NULL, NULL);
INSERT INTO `orders` VALUES (162, 'ORD20260302004', 'processing', 43, '周九', '13912345602', '北京市通州区新华大街6号', 5, '刘志强', '13900139005', '护理服务', '2026-03-01', '08:00:00', '14:00:00', 360, 55.00, 330.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-28 14:26:12', '2026-03-01 14:26:12', NULL, NULL);
INSERT INTO `orders` VALUES (163, 'ORD20260302005', 'completed', 43, '周九', '13912345602', '北京市通州区新华大街6号', 6, '陈玉兰', '13900139006', '月嫂服务', '2026-02-15', '09:00:00', '17:00:00', 480, 48.00, 384.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-14 14:26:12', '2026-02-16 14:26:12', NULL, NULL);
INSERT INTO `orders` VALUES (164, 'ORD20260302006', 'cancelled', 43, '周九', '13912345602', '北京市通州区新华大街6号', 7, '杨志明', '13900139007', '家电清洗', '2026-02-28', '10:00:00', '14:00:00', 240, 42.00, 168.00, 'refunded', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-26 14:26:12', '2026-02-27 14:26:12', NULL, NULL);

-- ----------------------------
-- Table structure for reviews
-- ----------------------------
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `worker_id` bigint NOT NULL,
  `rating` int NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `order_id`(`order_id` ASC) USING BTREE,
  INDEX `fk_review_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_review_worker`(`worker_id` ASC) USING BTREE,
  INDEX `idx_review_rating`(`rating` ASC) USING BTREE,
  CONSTRAINT `fk_review_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_review_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_review_worker` FOREIGN KEY (`worker_id`) REFERENCES `workers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of reviews
-- ----------------------------
INSERT INTO `reviews` VALUES (1, 1, 2, 1, 4, '服务满意，值得推荐', '2026-02-27 22:01:36', '2026-02-27 22:01:36', NULL);
INSERT INTO `reviews` VALUES (2, 2, 3, 2, 4, '服务满意，值得推荐', '2026-02-27 22:01:36', '2026-02-27 22:01:36', NULL);
INSERT INTO `reviews` VALUES (3, 3, 4, 3, 4, '服务满意，值得推荐', '2026-02-27 22:01:36', '2026-02-27 22:01:36', NULL);
INSERT INTO `reviews` VALUES (4, 4, 5, 4, 4, '服务满意，值得推荐', '2026-02-27 22:01:36', '2026-02-27 22:01:36', NULL);
INSERT INTO `reviews` VALUES (5, 5, 6, 5, 4, '服务满意，值得推荐', '2026-02-27 22:01:36', '2026-02-27 22:01:36', NULL);
INSERT INTO `reviews` VALUES (6, 6, 7, 6, 4, '服务满意，值得推荐', '2026-02-27 22:01:36', '2026-02-27 22:01:36', NULL);
INSERT INTO `reviews` VALUES (7, 7, 8, 7, 4, '服务满意，值得推荐', '2026-02-27 22:01:36', '2026-02-27 22:01:36', NULL);
INSERT INTO `reviews` VALUES (8, 8, 9, 8, 4, '服务满意，值得推荐', '2026-02-27 22:01:36', '2026-02-27 22:01:36', NULL);
INSERT INTO `reviews` VALUES (9, 9, 10, 9, 4, '服务满意，值得推荐', '2026-02-27 22:01:36', '2026-02-27 22:01:36', NULL);
INSERT INTO `reviews` VALUES (10, 10, 2, 10, 4, '服务满意，值得推荐', '2026-02-27 22:01:36', '2026-02-27 22:01:36', NULL);

-- ----------------------------
-- Table structure for service_categories
-- ----------------------------
DROP TABLE IF EXISTS `service_categories`;
CREATE TABLE `service_categories`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '#409EFF' COMMENT '分类颜色',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序',
  `status` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of service_categories
-- ----------------------------
INSERT INTO `service_categories` VALUES (1, '保洁服务', '家庭保洁、深度清洁、日常保洁', 'Brush', '2026-02-27 22:01:10', '2026-03-01 14:07:35', '#4CAF50', 1, 1);
INSERT INTO `service_categories` VALUES (2, '月嫂服务', '专业月嫂、母婴护理、新生儿护理', 'User', '2026-02-27 22:01:10', '2026-03-01 14:07:35', '#2196F3', 2, 1);
INSERT INTO `service_categories` VALUES (3, '护理服务', '老人陪护、康复护理、医疗护理', 'Monitor', '2026-02-27 22:01:10', '2026-03-01 14:07:35', '#FF9800', 3, 1);
INSERT INTO `service_categories` VALUES (4, '钟点工', '临时帮工、日常杂务、家电清洗', 'Tools', '2026-02-27 22:01:10', '2026-03-01 14:07:35', '#9C27B0', 4, 1);
INSERT INTO `service_categories` VALUES (5, '搬家服务', '居民搬家、公司搬迁、物品打包', 'van', '2026-02-27 22:01:10', '2026-02-27 22:01:10', '#409EFF', 0, 1);
INSERT INTO `service_categories` VALUES (6, '管道疏通', '下水道疏通、马桶疏通、管道维修', 'water', '2026-02-27 22:01:10', '2026-02-27 22:01:10', '#409EFF', 0, 1);
INSERT INTO `service_categories` VALUES (7, '家电维修', '空调维修、冰箱维修、洗衣机维修', 'cpu', '2026-02-27 22:01:10', '2026-02-27 22:01:10', '#409EFF', 0, 1);
INSERT INTO `service_categories` VALUES (8, '甲醛检测', '新房除甲醛、空气质量检测', 'wind', '2026-02-27 22:01:10', '2026-02-27 22:01:10', '#409EFF', 0, 1);

-- ----------------------------
-- Table structure for system_logs
-- ----------------------------
DROP TABLE IF EXISTS `system_logs`;
CREATE TABLE `system_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NULL DEFAULT NULL,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `target_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `target_id` bigint NULL DEFAULT NULL,
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_log_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_log_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_logs
-- ----------------------------

-- ----------------------------
-- Table structure for system_settings
-- ----------------------------
DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE `system_settings`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置键',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '配置值',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统设置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_settings
-- ----------------------------
INSERT INTO `system_settings` VALUES (1, 'site_name', '家政服务平台', '网站名称', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (2, 'site_logo', '', '网站Logo URL', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (3, 'site_description', '专业家政服务，让生活更美好', '网站描述', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (4, 'contact_email', 'service@jiazheng.com', '联系邮箱', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (5, 'contact_phone', '400-123-4567', '客服电话', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (6, 'enable_registration', 'true', '是否开启用户注册', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (7, 'enable_review', 'true', '是否开启评价功能', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (8, 'enable_favorite', 'true', '是否开启收藏功能', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (9, 'enable_recommendation', 'true', '是否开启智能推荐', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (10, 'min_booking_hours', '2', '最小预约时间（小时）', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (11, 'max_booking_days', '30', '最大预约时间（天）', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (12, 'cancel_order_hours', '24', '取消订单时限（小时）', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (13, 'enable_online_payment', 'true', '是否开启在线支付', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (14, 'enable_cash_on_delivery', 'true', '是否开启货到付款', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (15, 'page_size', '10', '每页显示数量', '2026-03-01 14:07:35', '2026-03-01 14:07:35');
INSERT INTO `system_settings` VALUES (16, 'home_recommendation_count', '4', '首页推荐数量', '2026-03-01 14:07:35', '2026-03-01 14:07:35');

-- ----------------------------
-- Table structure for user_addresses
-- ----------------------------
DROP TABLE IF EXISTS `user_addresses`;
CREATE TABLE `user_addresses`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系人姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系电话',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '省份',
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '城市',
  `district` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区县',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '详细地址',
  `is_default` tinyint NULL DEFAULT 0 COMMENT '是否默认：0-否，1-是',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `user_addresses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户地址表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_addresses
-- ----------------------------

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'user',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `gender` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '性别',
  `birthday` date NULL DEFAULT NULL COMMENT '生日',
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '身份证号',
  `emergency_contact` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '紧急联系人',
  `emergency_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '紧急联系电话',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `phone`(`phone` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 54 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '13800000001', 'admin@test.com', '陈志远', '北京市朝阳区', '', 'admin', 'active', '2026-02-27 22:01:15', '2026-03-10 00:35:19', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (2, 'superadmin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '13800000002', 'user1@test.com', '李明轩', '北京市海淀区', '', 'superadmin', 'active', '2026-02-27 22:01:15', '2026-03-10 15:24:47', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (3, 'user2', '$2a$10$hash', '13800000003', 'user2@test.com', '王思雨', '北京市西城区', '', 'user', 'active', '2026-02-27 22:01:15', '2026-03-10 00:35:36', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (4, 'user3', '$2a$10$hash', '13800000004', 'user3@test.com', '赵嘉诚', '北京市东城区', '', 'user', 'active', '2026-02-27 22:01:15', '2026-03-10 00:36:43', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (5, 'user4', '$2a$10$hash', '13800000005', 'user4@test.com', '刘子涵', '北京市丰台区', '', 'user', 'active', '2026-02-27 22:01:15', '2026-03-10 14:17:25', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (6, 'user5', '$2a$10$hash', '13800000006', 'user5@test.com', '孙浩然', '北京市通州区', '', 'user', 'active', '2026-02-27 22:01:15', '2026-03-10 14:17:25', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (7, 'user6', '$2a$10$hash', '13800000007', 'user6@test.com', '周雅婷', '北京市昌平区', '', 'user', 'active', '2026-02-27 22:01:15', '2026-03-10 14:17:26', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (8, 'user7', '$2a$10$hash', '13800000008', 'user7@test.com', '黄俊杰', '北京市大兴区', '', 'user', 'active', '2026-02-27 22:01:15', '2026-03-10 14:17:26', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (9, 'user8', '$2a$10$hash', '13800000009', 'user8@test.com', '何雨桐', '北京市顺义区', '', 'user', 'active', '2026-02-27 22:01:15', '2026-03-10 14:17:27', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (10, 'user9', '$2a$10$hash', '13800000010', 'user9@test.com', '郭晨曦', '北京市石景山区', '', 'user', 'active', '2026-02-27 22:01:15', '2026-03-10 14:17:27', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (12, 'sumu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '16989562436', NULL, '张季安', NULL, NULL, 'user', 'active', '2026-02-28 13:54:39', '2026-03-10 00:12:06', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (21, 'chenwei', '$2a$10$NvyYf6wiunsC2Yp2pIdab.eRB0N.F/vmnIEyim8.LlKEzBfCBRCaC', '13800138001', 'chenwei@example.com', '陈威', '北京市朝阳区建国路1号', '/uploads/1773132799735_b152ca8f.png', 'user', 'active', '2026-03-01 14:17:55', '2026-03-10 16:53:20', '陈伟', '男', '1990-01-15', NULL, NULL, NULL);
INSERT INTO `users` VALUES (22, 'liumei', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13800138002', 'liumei@example.com', '刘梅', '北京市海淀区中关村大街2号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=liumei', 'user', 'active', '2026-03-01 14:17:55', '2026-03-10 00:12:07', '刘梅', '女', '1992-03-20', NULL, NULL, NULL);
INSERT INTO `users` VALUES (23, 'wangjun', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13800138003', 'wangjun@example.com', '王军', '北京市西城区金融街3号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=wangjun', 'user', 'active', '2026-03-01 14:17:55', '2026-03-10 00:12:09', '王军', '男', '1988-07-08', NULL, NULL, NULL);
INSERT INTO `users` VALUES (24, 'zhaojing', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13800138004', 'zhaojing@example.com', '赵静', '北京市东城区王府井4号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=zhaojing', 'user', 'active', '2026-03-01 14:17:55', '2026-03-10 00:12:10', '赵静', '女', '1995-11-25', NULL, NULL, NULL);
INSERT INTO `users` VALUES (25, 'sunli', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13800138005', 'sunli@example.com', '孙丽', '上海市浦东新区世纪大道100号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=sunli', 'user', 'active', '2026-03-01 14:17:55', '2026-03-10 00:12:11', '孙丽', '女', '1993-09-12', NULL, NULL, NULL);
INSERT INTO `users` VALUES (26, 'zhouqiang', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13800138006', 'zhouqiang@example.com', '周强', '广州市天河区天河路208号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=zhouqiang', 'user', 'active', '2026-03-01 14:17:55', '2026-03-10 00:12:16', '周强', '男', '1987-12-03', NULL, NULL, NULL);
INSERT INTO `users` VALUES (27, 'wujie', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13800138007', 'wujie@example.com', '吴杰', '深圳市南山区科技园1号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=wujie', 'user', 'active', '2026-03-01 14:17:55', '2026-03-10 00:12:18', '吴杰', '男', '1991-06-18', NULL, NULL, NULL);
INSERT INTO `users` VALUES (28, 'xujia', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13800138008', 'xujia@example.com', '徐佳', '杭州市西湖区教工路42号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=xujia', 'user', 'active', '2026-03-01 14:17:55', '2026-03-10 00:12:19', '徐佳', '女', '1994-04-22', NULL, NULL, NULL);
INSERT INTO `users` VALUES (29, 'huangtao', '$2a$10$cb00BB9F7h3h53SQxyyJ4emCarWPQW9/PB9RlOl991dC0nLA/t5ee', '13800138009', 'huangtao@example.com', '黄涛', '成都市锦江区春熙路1号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=huangtao', 'user', 'active', '2026-03-01 14:17:55', '2026-03-10 00:12:20', '黄涛', '男', '1989-08-30', NULL, NULL, NULL);
INSERT INTO `users` VALUES (30, 'yangfan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13800138010', 'yangfan@example.com', '杨帆', '武汉市江汉区解放大道100号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=yangfan', 'user', 'active', '2026-03-01 14:17:55', '2026-03-10 00:12:24', '杨帆', '女', '1992-11-07', NULL, NULL, NULL);
INSERT INTO `users` VALUES (42, 'sunba', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13912345601', 'sunba@example.com', '孙八', '北京市丰台区南四环西路5号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=sunba', 'user', 'active', '2026-03-01 14:24:50', '2026-03-10 00:12:25', '孙八', '男', '1987-09-12', NULL, NULL, NULL);
INSERT INTO `users` VALUES (43, 'zhoujiu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13912345602', 'zhoujiu@example.com', '周九', '北京市通州区新华大街6号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=zhoujiu&gender=female', 'user', 'active', '2026-03-01 14:24:50', '2026-03-10 00:12:26', '周九', '女', '1993-04-18', NULL, NULL, NULL);
INSERT INTO `users` VALUES (44, 'wushi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13912345603', 'wushi@example.com', '吴十', '北京市顺义区天竺路7号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=wushi', 'user', 'active', '2026-03-01 14:24:50', '2026-03-10 00:12:27', '吴十', '男', '1985-12-03', NULL, NULL, NULL);
INSERT INTO `users` VALUES (45, 'zhengshi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13912345604', 'zhengshi@example.com', '郑十一', '北京市大兴区黄村大街8号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=zhengshi&gender=female', 'user', 'active', '2026-03-01 14:24:50', '2026-03-10 00:12:28', '郑十一', '女', '1991-06-25', NULL, NULL, NULL);
INSERT INTO `users` VALUES (46, 'chenshier', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13912345605', 'chenshier@example.com', '陈十二', '北京市房山区良乡路9号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=chenshier', 'user', 'active', '2026-03-01 14:24:50', '2026-03-10 00:12:29', '陈十二', '男', '1989-11-08', NULL, NULL, NULL);
INSERT INTO `users` VALUES (47, 'liushisan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13912345606', 'liushisan@example.com', '刘十三', '北京市昌平区回龙观10号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=liushisan&gender=female', 'user', 'active', '2026-03-01 14:24:50', '2026-03-10 00:12:31', '刘十三', '女', '1994-02-14', NULL, NULL, NULL);
INSERT INTO `users` VALUES (48, 'huangshisi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13912345607', 'huangshisi@example.com', '黄十四', '北京市门头沟区新桥大街11号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=huangshisi', 'user', 'active', '2026-03-01 14:24:50', '2026-03-10 00:12:32', '黄十四', '男', '1986-08-20', NULL, NULL, NULL);
INSERT INTO `users` VALUES (49, 'linshiwu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13912345608', 'linshiwu@example.com', '林十五', '北京市怀柔区青春路12号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=linshiwu&gender=female', 'user', 'active', '2026-03-01 14:24:50', '2026-03-10 00:12:34', '林十五', '女', '1992-10-30', NULL, NULL, NULL);
INSERT INTO `users` VALUES (50, 'xushiliu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13912345609', 'xushiliu@example.com', '徐十六', '北京市密云区鼓楼大街13号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=xushiliu', 'user', 'active', '2026-03-01 14:24:50', '2026-03-10 00:12:34', '徐十六', '男', '1988-05-16', NULL, NULL, NULL);
INSERT INTO `users` VALUES (51, 'mashiqi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EO', '13912345610', 'mashiqi@example.com', '马十七', '北京市平谷区府前街14号', 'https://api.dicebear.com/7.x/avataaars/svg?seed=mashiqi&gender=female', 'user', 'active', '2026-03-01 14:24:50', '2026-03-10 00:12:38', '马十七', '女', '1990-12-22', NULL, NULL, NULL);
INSERT INTO `users` VALUES (52, 'yis', '$2a$10$ySjzVZBjYOESYyVBqqJoFOBbCMaGUgmoDltz/FhGiYnrdLCVO5WsW', '16789652349', NULL, 'yishiqi', NULL, NULL, 'user', 'active', '2026-03-01 14:35:31', '2026-03-10 00:12:38', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `users` VALUES (53, 'supperadmin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '13900000000', 'superadmin@admin.com', '超级管理员', NULL, NULL, 'supperadmin', 'active', '2026-03-10 14:32:27', '2026-03-10 14:50:00', NULL, NULL, NULL, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for worker_applications
-- ----------------------------
DROP TABLE IF EXISTS `worker_applications`;
CREATE TABLE `worker_applications`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '姓名',
  `gender` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '性别',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号',
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '身份证号',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `service_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '服务类型',
  `experience` int NULL DEFAULT NULL COMMENT '从业经验(年)',
  `expected_salary` double NULL DEFAULT NULL COMMENT '期望薪资(元/小时)',
  `work_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工作状态：全职/兼职',
  `service_area` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '服务区域',
  `introduction` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '个人简介',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '状态：pending-待审核, approved-已通过, rejected-已拒绝',
  `apply_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `review_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `reviewer` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核人',
  `reject_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '拒绝原因',
  `certificates` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '资质证书(JSON格式)',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_apply_time`(`apply_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '家政人员入驻申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of worker_applications
-- ----------------------------
INSERT INTO `worker_applications` VALUES (1, '张阿姨', '女', '13800138001', '110101198001011234', NULL, '保洁', 8, 50, '全职', '北京市朝阳区、海淀区', '从事家政服务8年，擅长深度保洁、日常保洁，工作认真负责。', 'pending', '2026-01-15 10:30:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (2, '李师傅', '男', '13900139001', '110101197505056789', NULL, '月嫂', 12, 80, '全职', '北京市朝阳区', '专业月嫂，有12年经验，擅长新生儿护理和产妇护理。', 'pending', '2026-01-15 09:15:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (3, '王阿姨', '女', '13700137001', '110101198508152345', NULL, '护理', 6, 60, '兼职', '北京市海淀区、西城区', '有护理经验6年，擅长老人陪护和康复护理。', 'pending', '2026-01-15 08:30:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (4, '陈师傅', '男', '13600136001', '110101197808082456', NULL, '钟点工', 10, 40, '兼职', '北京市东城区、朝阳区', '擅长钟点工服务，做饭好吃，打扫卫生干净。', 'pending', '2026-01-14 16:45:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (5, '刘阿姨', '女', '13500135001', '110101198210103456', NULL, '育儿嫂', 9, 70, '全职', '北京市朝阳区、通州区', '有育儿嫂经验9年，擅长婴幼儿护理和早教。', 'pending', '2026-01-14 14:20:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (6, '赵阿姨', '女', '13400134001', '110101197212124567', NULL, '保洁', 15, 55, '全职', '北京市海淀区', '15年保洁经验，擅长深度清洁和开荒保洁。', 'approved', '2026-01-13 11:00:00', '2026-01-13 12:00:00', '管理员', NULL, NULL);
INSERT INTO `worker_applications` VALUES (7, '钱师傅', '男', '13300133001', '110101198606065678', NULL, '月嫂', 8, 75, '全职', '北京市西城区', '专业月嫂，有催乳师证书，经验丰富。', 'approved', '2026-01-12 10:30:00', '2026-01-13 12:00:00', '管理员', NULL, NULL);
INSERT INTO `worker_applications` VALUES (8, '孙阿姨', '女', '13200132001', '110101198909096789', NULL, '护理', 7, 65, '兼职', '北京市丰台区', '有护士资格证，擅长医疗护理和康复训练。', 'approved', '2026-01-11 09:15:00', '2026-01-13 12:00:00', '管理员', NULL, NULL);
INSERT INTO `worker_applications` VALUES (9, '周师傅', '男', '13100131001', '110101197404047890', NULL, '钟点工', 11, 45, '兼职', '北京市昌平区', '擅长做饭，川菜、粤菜都会，口味好。', 'approved', '2026-01-10 15:30:00', '2026-01-13 12:00:00', '管理员', NULL, NULL);
INSERT INTO `worker_applications` VALUES (10, '吴阿姨', '女', '13000130001', '110101198707078901', NULL, '育儿嫂', 10, 72, '全职', '北京市大兴区', '有育婴师证书，擅长婴幼儿护理和辅食制作。', 'approved', '2026-01-09 14:00:00', '2026-01-13 12:00:00', '管理员', NULL, NULL);
INSERT INTO `worker_applications` VALUES (11, '郑阿姨', '女', '12900129001', '110101198303039012', NULL, '保洁', 5, 48, '兼职', '北京市顺义区', '有5年保洁经验，工作细致认真。', 'rejected', '2026-01-08 11:30:00', '2026-01-08 12:00:00', '管理员', '经验不足，暂不符合入驻要求', NULL);
INSERT INTO `worker_applications` VALUES (12, '王师傅', '男', '12800128001', '110101197707071234', NULL, '月嫂', 4, 70, '兼职', '北京市通州区', '经验不足，暂不符合要求', 'rejected', '2026-01-07 10:00:00', '2026-01-08 12:00:00', '管理员', '经验不足，暂不符合入驻要求', NULL);
INSERT INTO `worker_applications` VALUES (13, '冯阿姨', '女', '12700127001', '110101198404041235', NULL, '护理', 3, 55, '兼职', '北京市房山区', '从业时间较短，暂不符合要求', 'rejected', '2026-01-06 16:45:00', '2026-01-08 12:00:00', '管理员', '经验不足，暂不符合入驻要求', NULL);
INSERT INTO `worker_applications` VALUES (16, '卫阿姨', '女', '12400124001', '110101198888881238', NULL, '保洁', 7, 52, '全职', '北京市平谷区', '有7年保洁经验，擅长深度清洁。', 'approved', '2026-01-16 07:00:00', '2026-03-01 20:43:10', '管理员', NULL, NULL);
INSERT INTO `worker_applications` VALUES (17, '蒋阿姨', '女', '12300123001', '110101197999991239', NULL, '月嫂', 14, 85, '全职', '北京市密云区', '资深月嫂，有催乳师和产后恢复证书。', 'pending', '2026-01-15 20:30:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (18, '沈师傅', '男', '12200122001', '110101198555551240', NULL, '护理', 8, 62, '兼职', '北京市延庆区', '有护理经验，擅长老人陪护。', 'pending', '2026-01-15 19:15:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (19, '韩阿姨', '女', '12100121001', '110101197666661241', NULL, '育儿嫂', 11, 74, '全职', '北京市石景山区', '有11年育儿经验，擅长婴幼儿早教。', 'pending', '2026-01-15 18:00:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (20, '杨阿姨', '女', '12000120001', '110101198777771242', NULL, '保洁', 9, 53, '全职', '北京市东城区', '有9年保洁经验，工作认真负责。', 'pending', '2026-01-15 17:30:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (27, '施师傅', '男', '11300113001', '110101197787871249', NULL, '月嫂', 11, 82, '全职', '北京市大兴区', '资深月嫂，有催乳师证书。', 'pending', '2026-01-15 20:30:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (28, '张阿姨', '女', '11200112001', '110101198898981250', NULL, '护理', 6, 60, '兼职', '北京市通州区', '有护士背景，擅长康复护理。', 'pending', '2026-01-15 19:15:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (29, '孔师傅', '男', '11100111001', '110101197909091251', NULL, '钟点工', 10, 44, '兼职', '北京市顺义区', '擅长川菜和粤菜，口味好。', 'pending', '2026-01-15 18:00:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (30, '曹阿姨', '女', '11000110001', '110101198010101252', NULL, '育儿嫂', 8, 70, '全职', '北京市房山区', '有育婴师证书，擅长早教。', 'pending', '2026-01-15 17:30:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (31, '严阿姨', '女', '10900109001', '110101198111111253', NULL, '保洁', 7, 50, '全职', '北京市门头沟区', '有7年保洁经验，擅长开荒保洁。', 'pending', '2026-01-14 16:00:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (32, '华师傅', '男', '10800108001', '110101197222221254', NULL, '月嫂', 13, 88, '全职', '北京市怀柔区', '资深月嫂，经验丰富。', 'pending', '2026-01-14 15:30:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (33, '金阿姨', '女', '10700107001', '110101198333331255', NULL, '护理', 9, 65, '兼职', '北京市平谷区', '有护理经验9年，工作细心。', 'pending', '2026-01-14 14:00:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (34, '魏师傅', '男', '10600106001', '110101197444441256', NULL, '钟点工', 12, 46, '兼职', '北京市密云区', '擅长各种家常菜。', 'pending', '2026-01-14 13:30:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (35, '陶阿姨', '女', '10500105001', '110101198555551257', NULL, '育儿嫂', 10, 73, '全职', '北京市延庆区', '有10年育儿经验，擅长辅食制作。', 'pending', '2026-01-14 12:00:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (36, '姜阿姨', '女', '10400104001', '110101198666661258', NULL, '保洁', 8, 52, '全职', '北京市石景山区', '有8年保洁经验，工作细致。', 'pending', '2026-01-14 11:30:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (37, '戚师傅', '男', '10300103001', '110101197777771259', NULL, '月嫂', 15, 90, '全职', '北京市东城区', '资深月嫂，有多个专业证书。', 'pending', '2026-01-14 10:00:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (38, '谢阿姨', '女', '10200102001', '110101198888881260', NULL, '护理', 7, 63, '兼职', '北京市西城区', '有护理经验，擅长康复训练。', 'pending', '2026-01-14 09:30:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (39, '邹师傅', '男', '10100101001', '110101197999991261', NULL, '钟点工', 9, 42, '兼职', '北京市朝阳区', '擅长做饭，速度快。', 'pending', '2026-01-14 09:00:00', NULL, NULL, NULL, NULL);
INSERT INTO `worker_applications` VALUES (40, '喻阿姨', '女', '10000100001', '110101198000001262', NULL, '育儿嫂', 11, 75, '全职', '北京市海淀区', '有11年育儿经验，擅长早教。', 'pending', '2026-01-14 08:30:00', NULL, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for worker_categories
-- ----------------------------
DROP TABLE IF EXISTS `worker_categories`;
CREATE TABLE `worker_categories`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `worker_id` bigint NOT NULL,
  `category_id` bigint NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_worker`(`worker_id` ASC) USING BTREE,
  INDEX `fk_category`(`category_id` ASC) USING BTREE,
  CONSTRAINT `fk_category` FOREIGN KEY (`category_id`) REFERENCES `service_categories` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_worker` FOREIGN KEY (`worker_id`) REFERENCES `workers` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of worker_categories
-- ----------------------------
INSERT INTO `worker_categories` VALUES (1, 1, 1, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (2, 7, 1, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (3, 2, 2, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (4, 9, 2, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (5, 13, 2, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (6, 3, 3, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (7, 8, 3, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (8, 4, 4, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (9, 11, 4, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (10, 5, 5, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (11, 12, 5, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (12, 6, 6, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (13, 14, 6, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (14, 10, 7, '2026-02-27 22:01:26');
INSERT INTO `worker_categories` VALUES (15, 15, 8, '2026-02-27 22:01:26');

-- ----------------------------
-- Table structure for workers
-- ----------------------------
DROP TABLE IF EXISTS `workers`;
CREATE TABLE `workers`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '家政人员ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '手机号',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `gender` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '性别',
  `age` int NULL DEFAULT NULL COMMENT '年龄',
  `experience` int NULL DEFAULT 0 COMMENT '从业年限',
  `price` double NOT NULL,
  `rating` double NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'active' COMMENT '状态（active/inactive）',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '个人描述',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `category_id` int NULL DEFAULT NULL,
  `work_city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作城市',
  `work_district` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作区域',
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '身份证号',
  `emergency_contact` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '紧急联系人',
  `emergency_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '紧急联系电话',
  `work_experience` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '工作经历',
  `skills` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '技能标签（JSON格式）',
  `service_area` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '服务区域（JSON格式）',
  `total_orders` int NULL DEFAULT 0 COMMENT '接单总数',
  `total_reviews` int NULL DEFAULT 0 COMMENT '评价总数',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `phone`(`phone` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_price`(`price` ASC) USING BTREE,
  INDEX `idx_rating`(`rating` ASC) USING BTREE,
  INDEX `idx_experience`(`experience` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 225 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '家政人员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of workers
-- ----------------------------
INSERT INTO `workers` VALUES (1, '张阿姨', '13812345678', '/uploads/1773129632906_6abd3b4d.png', '女', 45, 8, 85, 4.8, 'approved', '从事家政服务8年，擅长日常保洁、烹饪和照顾老人，做事认真负责，有耐心。', '2026-02-28 18:00:52', '2026-03-10 16:00:42', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (2, '李阿姨', '13987654321', NULL, '女', 50, 10, 90, 4.9, 'available', '有10年家政经验，擅长照顾婴儿和老人，会做各种家常菜，工作细致。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (3, '王师傅', '13765432109', 'https://c-ssl.duitang.com/uploads/item/201908/30/20190830212859_lfkps.jpg', '男', 48, 12, 100, 4.7, 'available', '从事家政服务12年，擅长家电维修、水电维修和日常保洁，技术精湛。', '2026-02-28 18:00:52', '2026-03-10 15:58:29', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (4, '刘阿姨', '13654321098', NULL, '女', 42, 6, 70, 4.6, 'available', '有6年家政经验，擅长日常保洁和烹饪，性格开朗，服务态度好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (5, '陈师傅', '13543210987', NULL, '男', 52, 15, 120, 4.9, 'available', '从事家政服务15年，擅长家电维修、水电维修和搬运，力气大，技术好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (6, '赵阿姨', '13432109876', NULL, '女', 40, 5, 65, 4.5, 'available', '有5年家政经验，擅长日常保洁和照顾儿童，做事细心，有爱心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (7, '孙师傅', '13321098765', NULL, '男', 46, 9, 95, 4.7, 'available', '从事家政服务9年，擅长家电维修和日常保洁，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (8, '周阿姨', '13210987654', NULL, '女', 44, 7, 75, 4.6, 'available', '有7年家政经验，擅长烹饪和日常保洁，会做各种地方菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (9, '吴师傅', '13109876543', NULL, '男', 49, 11, 105, 4.8, 'available', '从事家政服务11年，擅长水电维修和搬运，工作效率高。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (10, '郑阿姨', '13098765432', NULL, '女', 43, 6, 70, 4.6, 'available', '有6年家政经验，擅长照顾老人和日常保洁，有耐心，服务态度好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (11, '杨阿姨', '15912345678', NULL, '女', 47, 9, 85, 4.7, 'available', '从事家政服务9年，擅长烹饪和照顾儿童，会做各种家常菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (12, '黄师傅', '15887654321', NULL, '男', 51, 14, 115, 4.8, 'available', '从事家政服务14年，擅长家电维修和水电维修，技术精湛。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (13, '何阿姨', '15765432109', NULL, '女', 41, 5, 65, 4.5, 'available', '有5年家政经验，擅长日常保洁和照顾儿童，做事细心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (14, '郭师傅', '15654321098', NULL, '男', 48, 10, 100, 4.7, 'available', '从事家政服务10年，擅长水电维修和搬运，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (15, '马阿姨', '15543210987', NULL, '女', 46, 8, 80, 4.6, 'available', '有8年家政经验，擅长烹饪和日常保洁，会做各种地方菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (16, '罗师傅', '15432109876', NULL, '男', 50, 13, 110, 4.8, 'available', '从事家政服务13年，擅长家电维修和水电维修，技术好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (17, '梁阿姨', '15321098765', NULL, '女', 44, 7, 75, 4.6, 'available', '有7年家政经验，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (18, '宋师傅', '15210987654', NULL, '男', 47, 10, 95, 4.7, 'available', '从事家政服务10年，擅长水电维修和搬运，工作效率高。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (19, '谢阿姨', '15109876543', NULL, '女', 42, 6, 70, 4.5, 'available', '有6年家政经验，擅长日常保洁和照顾儿童，性格开朗。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (20, '韩师傅', '15098765432', NULL, '男', 49, 12, 105, 4.8, 'available', '从事家政服务12年，擅长家电维修和水电维修，技术精湛。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (21, '曹阿姨', '18912345678', NULL, '女', 45, 8, 80, 4.7, 'available', '从事家政服务8年，擅长烹饪和日常保洁，会做各种家常菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (22, '邓师傅', '18887654321', NULL, '男', 51, 14, 115, 4.8, 'available', '从事家政服务14年，擅长水电维修和搬运，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (23, '彭阿姨', '18765432109', NULL, '女', 43, 6, 70, 4.6, 'available', '有6年家政经验，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (24, '肖师傅', '18654321098', NULL, '男', 48, 11, 100, 4.7, 'available', '从事家政服务11年，擅长家电维修和水电维修，技术好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (25, '田阿姨', '18543210987', NULL, '女', 46, 9, 85, 4.7, 'available', '有9年家政经验，擅长烹饪和照顾儿童，会做各种地方菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (26, '董师傅', '18432109876', NULL, '男', 50, 13, 110, 4.8, 'available', '从事家政服务13年，擅长水电维修和搬运，工作效率高。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (27, '袁阿姨', '18321098765', NULL, '女', 44, 7, 75, 4.6, 'available', '有7年家政经验，擅长日常保洁和照顾儿童，做事细心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (28, '潘师傅', '18210987654', NULL, '男', 47, 10, 95, 4.7, 'available', '从事家政服务10年，擅长家电维修和水电维修，技术精湛。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (29, '于阿姨', '18109876543', NULL, '女', 42, 5, 65, 4.5, 'available', '有5年家政经验，擅长日常保洁和烹饪，性格开朗。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (30, '余师傅', '18098765432', NULL, '男', 49, 12, 105, 4.8, 'available', '从事家政服务12年，擅长水电维修和搬运，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (31, '叶阿姨', '17912345678', NULL, '女', 45, 8, 80, 4.7, 'available', '从事家政服务8年，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (32, '蒋师傅', '17887654321', NULL, '男', 51, 14, 115, 4.8, 'available', '从事家政服务14年，擅长家电维修和水电维修，技术好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (33, '杜阿姨', '17765432109', NULL, '女', 43, 6, 70, 4.6, 'available', '有6年家政经验，擅长日常保洁和照顾儿童，做事细心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (34, '苏师傅', '17654321098', NULL, '男', 48, 11, 100, 4.7, 'available', '从事家政服务11年，擅长水电维修和搬运，工作效率高。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (35, '魏阿姨', '17543210987', NULL, '女', 46, 9, 85, 4.7, 'available', '有9年家政经验，擅长烹饪和日常保洁，会做各种家常菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (36, '程师傅', '17432109876', NULL, '男', 50, 13, 110, 4.8, 'available', '从事家政服务13年，擅长家电维修和水电维修，技术精湛。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (37, '吕阿姨', '17321098765', NULL, '女', 44, 7, 75, 4.6, 'available', '有7年家政经验，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (38, '丁师傅', '17210987654', NULL, '男', 47, 10, 95, 4.7, 'available', '从事家政服务10年，擅长水电维修和搬运，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (39, '沈阿姨', '17109876543', NULL, '女', 42, 5, 65, 4.5, 'available', '有5年家政经验，擅长日常保洁和照顾儿童，性格开朗。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (40, '任师傅', '17098765432', NULL, '男', 49, 12, 105, 4.8, 'available', '从事家政服务12年，擅长家电维修和水电维修，技术好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (41, '姚阿姨', '16912345678', NULL, '女', 45, 8, 80, 4.7, 'available', '从事家政服务8年，擅长烹饪和日常保洁，会做各种地方菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (42, '卢师傅', '16887654321', NULL, '男', 51, 14, 115, 4.8, 'available', '从事家政服务14年，擅长水电维修和搬运，工作效率高。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (43, '姜阿姨', '16765432109', NULL, '女', 43, 6, 70, 4.6, 'available', '有6年家政经验，擅长日常保洁和照顾儿童，做事细心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (44, '崔师傅', '16654321098', NULL, '男', 48, 11, 100, 4.7, 'available', '从事家政服务11年，擅长家电维修和水电维修，技术精湛。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (45, '钟阿姨', '16543210987', NULL, '女', 46, 9, 85, 4.7, 'available', '有9年家政经验，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (46, '谭师傅', '16432109876', NULL, '男', 50, 13, 110, 4.8, 'available', '从事家政服务13年，擅长水电维修和搬运，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (47, '陆阿姨', '16321098765', NULL, '女', 44, 7, 75, 4.6, 'available', '有7年家政经验，擅长烹饪和日常保洁，会做各种家常菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (48, '汪师傅', '16210987654', NULL, '男', 47, 10, 95, 4.7, 'available', '从事家政服务10年，擅长家电维修和水电维修，技术好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (49, '范阿姨', '16109876543', NULL, '女', 42, 5, 65, 4.5, 'available', '有5年家政经验，擅长日常保洁和照顾儿童，性格开朗。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (50, '金师傅', '16098765432', NULL, '男', 49, 12, 105, 4.8, 'available', '从事家政服务12年，擅长水电维修和搬运，工作效率高。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (51, '石阿姨', '13823456789', NULL, '女', 45, 8, 80, 4.7, 'available', '从事家政服务8年，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (52, '廖师傅', '13934567890', NULL, '男', 51, 14, 115, 4.8, 'available', '从事家政服务14年，擅长家电维修和水电维修，技术精湛。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (53, '贾阿姨', '13745678901', NULL, '女', 43, 6, 70, 4.6, 'available', '有6年家政经验，擅长日常保洁和照顾儿童，做事细心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (54, '夏师傅', '13656789012', NULL, '男', 48, 11, 100, 4.7, 'available', '从事家政服务11年，擅长水电维修和搬运，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (55, '韦阿姨', '13567890123', NULL, '女', 46, 9, 85, 4.7, 'available', '有9年家政经验，擅长烹饪和日常保洁，会做各种地方菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (56, '付师傅', '13478901234', NULL, '男', 50, 13, 110, 4.8, 'available', '从事家政服务13年，擅长家电维修和水电维修，技术好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (57, '方阿姨', '13389012345', NULL, '女', 44, 7, 75, 4.6, 'available', '有7年家政经验，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (58, '白师傅', '13290123456', NULL, '男', 47, 10, 95, 4.7, 'available', '从事家政服务10年，擅长水电维修和搬运，工作效率高。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (59, '邹阿姨', '13101234567', NULL, '女', 42, 5, 65, 4.5, 'available', '有5年家政经验，擅长日常保洁和照顾儿童，性格开朗。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (60, '孟师傅', '13012345678', NULL, '男', 49, 12, 105, 4.8, 'available', '从事家政服务12年，擅长家电维修和水电维修，技术精湛。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (61, '熊阿姨', '15923456789', NULL, '女', 45, 8, 80, 4.7, 'available', '从事家政服务8年，擅长烹饪和日常保洁，会做各种家常菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (62, '秦师傅', '15834567890', NULL, '男', 51, 14, 115, 4.8, 'available', '从事家政服务14年，擅长水电维修和搬运，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (63, '邱阿姨', '15745678901', NULL, '女', 43, 6, 70, 4.6, 'available', '有6年家政经验，擅长日常保洁和照顾儿童，做事细心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (64, '尹师傅', '15656789012', NULL, '男', 48, 11, 100, 4.7, 'available', '从事家政服务11年，擅长家电维修和水电维修，技术好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (65, '薛阿姨', '15567890123', NULL, '女', 46, 9, 85, 4.7, 'available', '有9年家政经验，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (66, '闫师傅', '15478901234', NULL, '男', 50, 13, 110, 4.8, 'available', '从事家政服务13年，擅长水电维修和搬运，工作效率高。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (67, '段阿姨', '15389012345', NULL, '女', 44, 7, 75, 4.6, 'available', '有7年家政经验，擅长烹饪和日常保洁，会做各种地方菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (68, '雷师傅', '15290123456', NULL, '男', 47, 10, 95, 4.7, 'available', '从事家政服务10年，擅长家电维修和水电维修，技术精湛。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (69, '侯阿姨', '15101234567', NULL, '女', 42, 5, 65, 4.5, 'available', '有5年家政经验，擅长日常保洁和照顾儿童，性格开朗。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (70, '龙师傅', '15012345678', NULL, '男', 49, 12, 105, 4.8, 'available', '从事家政服务12年，擅长水电维修和搬运，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (71, '史阿姨', '18923456789', NULL, '女', 45, 8, 80, 4.7, 'available', '从事家政服务8年，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (72, '陶师傅', '18834567890', NULL, '男', 51, 14, 115, 4.8, 'available', '从事家政服务14年，擅长家电维修和水电维修，技术好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (73, '黎阿姨', '18745678901', NULL, '女', 43, 6, 70, 4.6, 'available', '有6年家政经验，擅长日常保洁和照顾儿童，做事细心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (74, '贺师傅', '18656789012', NULL, '男', 48, 11, 100, 4.7, 'available', '从事家政服务11年，擅长水电维修和搬运，工作效率高。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (75, '顾阿姨', '18567890123', NULL, '女', 46, 9, 85, 4.7, 'available', '有9年家政经验，擅长烹饪和日常保洁，会做各种家常菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (76, '毛师傅', '18478901234', NULL, '男', 50, 13, 110, 4.8, 'available', '从事家政服务13年，擅长家电维修和水电维修，技术精湛。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (77, '牛阿姨', '18389012345', NULL, '女', 44, 7, 75, 4.6, 'available', '有7年家政经验，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (78, '冯师傅', '18290123456', NULL, '男', 47, 10, 95, 4.7, 'available', '从事家政服务10年，擅长水电维修和搬运，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (79, '沈阿姨', '18101234567', NULL, '女', 42, 5, 65, 4.5, 'available', '有5年家政经验，擅长日常保洁和照顾儿童，性格开朗。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (80, '韩师傅', '18012345678', NULL, '男', 49, 12, 105, 4.8, 'available', '从事家政服务12年，擅长家电维修和水电维修，技术好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (81, '杨师傅', '17923456789', NULL, '男', 48, 11, 100, 4.7, 'available', '从事家政服务11年，擅长水电维修和搬运，工作效率高。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (82, '朱阿姨', '17834567890', NULL, '女', 45, 8, 80, 4.7, 'available', '从事家政服务8年，擅长烹饪和日常保洁，会做各种家常菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (83, '秦阿姨', '17745678901', NULL, '女', 43, 6, 70, 4.6, 'available', '有6年家政经验，擅长日常保洁和照顾儿童，做事细心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (84, '尤师傅', '17656789012', NULL, '男', 51, 14, 115, 4.8, 'available', '从事家政服务14年，擅长家电维修和水电维修，技术精湛。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (85, '许阿姨', '17567890123', NULL, '女', 46, 9, 85, 4.7, 'available', '有9年家政经验，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (86, '何师傅', '17478901234', NULL, '男', 50, 13, 110, 4.8, 'available', '从事家政服务13年，擅长水电维修和搬运，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (87, '吕师傅', '17389012345', NULL, '男', 47, 10, 95, 4.7, 'available', '从事家政服务10年，擅长家电维修和水电维修，技术好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (88, '施阿姨', '17290123456', NULL, '女', 44, 7, 75, 4.6, 'available', '有7年家政经验，擅长烹饪和日常保洁，会做各种地方菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (89, '张师傅', '17101234567', NULL, '男', 49, 12, 105, 4.8, 'available', '从事家政服务12年，擅长水电维修和搬运，工作效率高。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (90, '孔阿姨', '17012345678', NULL, '女', 42, 5, 65, 4.5, 'available', '有5年家政经验，擅长日常保洁和照顾儿童，性格开朗。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (91, '曹师傅', '16923456789', NULL, '男', 48, 11, 100, 4.7, 'available', '从事家政服务11年，擅长家电维修和水电维修，技术精湛。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (92, '严阿姨', '16834567890', NULL, '女', 45, 8, 80, 4.7, 'available', '从事家政服务8年，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (93, '华师傅', '16745678901', NULL, '男', 51, 14, 115, 4.8, 'available', '从事家政服务14年，擅长水电维修和搬运，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (94, '金阿姨', '16656789012', NULL, '女', 43, 6, 70, 4.6, 'available', '有6年家政经验，擅长日常保洁和照顾儿童，做事细心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (95, '魏师傅', '16567890123', NULL, '男', 50, 13, 110, 4.8, 'available', '从事家政服务13年，擅长家电维修和水电维修，技术好。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (96, '陶阿姨', '16478901234', NULL, '女', 46, 9, 85, 4.7, 'available', '有9年家政经验，擅长烹饪和日常保洁，会做各种地方菜。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (97, '姜师傅', '16389012345', NULL, '男', 47, 10, 95, 4.7, 'available', '从事家政服务10年，擅长水电维修和搬运，工作效率高。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (98, '戚阿姨', '16290123456', NULL, '女', 44, 7, 75, 4.6, 'available', '有7年家政经验，擅长照顾老人和日常保洁，有耐心。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (99, '谢师傅', '16101234567', NULL, '男', 49, 12, 105, 4.8, 'available', '从事家政服务12年，擅长家电维修和水电维修，技术精湛。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (100, '邹师傅', '16012345678', NULL, '男', 48, 11, 100, 4.7, 'available', '从事家政服务11年，擅长水电维修和搬运，工作认真负责。', '2026-02-28 18:00:52', '2026-02-28 20:52:32', 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (201, '张建国', '13900139001', NULL, '男', 45, 10, 50, 4.8, 'active', '专业老人陪护，有护理证，经验丰富，耐心细致', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 3, '北京', '石景山区', NULL, NULL, NULL, NULL, '[\"老人陪护\", \"康复护理\", \"日常照料\"]', '[\"石景山区\", \"海淀区\", \"西城区\"]', 156, 89);
INSERT INTO `workers` VALUES (202, '李秀英', '13900139002', NULL, '女', 42, 8, 45, 4.9, 'active', '金牌月嫂，育婴师资格证，擅长新生儿护理和产妇照料', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 2, '北京', '朝阳区', NULL, NULL, NULL, NULL, '[\"月嫂\", \"育婴\", \"产后护理\"]', '[\"朝阳区\", \"东城区\", \"通州区\"]', 203, 156);
INSERT INTO `workers` VALUES (203, '王德明', '13900139003', NULL, '男', 38, 5, 40, 4.7, 'active', '专业保洁，深度清洁专家，工具齐全，服务周到', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 1, '北京', '海淀区', NULL, NULL, NULL, NULL, '[\"家庭保洁\", \"深度清洁\", \"开荒保洁\"]', '[\"海淀区\", \"石景山区\", \"丰台区\"]', 312, 198);
INSERT INTO `workers` VALUES (204, '张淑芬', '13900139004', NULL, '女', 50, 15, 35, 4.6, 'active', '钟点工，做饭好吃，家务整理井井有条，为人勤快', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 4, '北京', '东城区', NULL, NULL, NULL, NULL, '[\"钟点工\", \"做饭\", \"家务整理\"]', '[\"东城区\", \"西城区\", \"朝阳区\"]', 428, 267);
INSERT INTO `workers` VALUES (205, '刘志强', '13900139005', NULL, '男', 35, 6, 55, 4.9, 'active', '专业护理，护士资格证，擅长病患护理和康复训练', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 3, '北京', '西城区', NULL, NULL, NULL, NULL, '[\"病患护理\", \"康复训练\", \"医疗陪护\"]', '[\"西城区\", \"海淀区\", \"石景山区\"]', 178, 134);
INSERT INTO `workers` VALUES (206, '陈玉兰', '13900139006', NULL, '女', 48, 12, 48, 4.8, 'active', '资深月嫂，双胞胎护理经验，催乳师资格证', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 2, '北京', '通州区', NULL, NULL, NULL, NULL, '[\"月嫂\", \"催乳\", \"双胞胎护理\"]', '[\"通州区\", \"朝阳区\", \"大兴区\"]', 245, 189);
INSERT INTO `workers` VALUES (207, '杨志明', '13900139007', NULL, '男', 40, 7, 42, 4.5, 'active', '家电清洗专家，空调油烟机清洗，专业设备', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 1, '北京', '丰台区', NULL, NULL, NULL, NULL, '[\"家电清洗\", \"油烟机清洗\", \"空调清洗\"]', '[\"丰台区\", \"大兴区\", \"房山区\"]', 267, 145);
INSERT INTO `workers` VALUES (208, '周秀兰', '13900139008', NULL, '女', 44, 9, 46, 4.7, 'active', '育儿嫂，早教经验，会英语儿歌，喜欢和宝宝互动', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 2, '北京', '大兴区', NULL, NULL, NULL, NULL, '[\"育儿嫂\", \"早教\", \"英语启蒙\"]', '[\"大兴区\", \"丰台区\", \"通州区\"]', 198, 156);
INSERT INTO `workers` VALUES (209, '吴德贵', '13900139009', NULL, '男', 52, 20, 60, 4.9, 'active', '高级管家，别墅管理经验，会开车，综合素质高', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 4, '北京', '顺义区', NULL, NULL, NULL, NULL, '[\"管家\", \"司机\", \"别墅管理\"]', '[\"顺义区\", \"朝阳区\", \"海淀区\"]', 89, 78);
INSERT INTO `workers` VALUES (210, '郑美玲', '13900139010', NULL, '女', 36, 4, 38, 4.4, 'active', '年轻有活力，擅长收纳整理，会简单维修', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 1, '北京', '房山区', NULL, NULL, NULL, NULL, '[\"收纳整理\", \"简单维修\", \"日常保洁\"]', '[\"房山区\", \"丰台区\", \"大兴区\"]', 156, 98);
INSERT INTO `workers` VALUES (211, '孙德胜', '13900139011', NULL, '男', 48, 12, 52, 4.7, 'active', '专业护工，10年经验，擅长瘫痪老人护理', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 3, '北京', '海淀区', NULL, NULL, NULL, NULL, '[\"老人陪护\", \"瘫痪护理\", \"康复按摩\"]', '[\"海淀区\", \"朝阳区\", \"西城区\"]', 267, 189);
INSERT INTO `workers` VALUES (212, '胡秀芳', '13900139012', NULL, '女', 39, 6, 43, 4.6, 'active', '金牌月嫂，有高级育婴师证，性格温和', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 2, '北京', '朝阳区', NULL, NULL, NULL, NULL, '[\"月嫂\", \"育儿嫂\", \"月子餐\"]', '[\"朝阳区\", \"通州区\", \"大兴区\"]', 178, 134);
INSERT INTO `workers` VALUES (213, '郭志刚', '13900139013', NULL, '男', 42, 8, 47, 4.8, 'active', '深度清洁专家，擅长地毯清洗、沙发护理', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 1, '北京', '丰台区', NULL, NULL, NULL, NULL, '[\"深度清洁\", \"地毯清洗\", \"沙发护理\"]', '[\"丰台区\", \"大兴区\", \"房山区\"]', 234, 167);
INSERT INTO `workers` VALUES (214, '马秀云', '13900139014', NULL, '女', 46, 11, 44, 4.5, 'active', '钟点工，做饭好吃，擅长北方菜系', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 4, '北京', '西城区', NULL, NULL, NULL, NULL, '[\"钟点工\", \"做饭\", \"家务\"]', '[\"西城区\", \"东城区\", \"海淀区\"]', 389, 245);
INSERT INTO `workers` VALUES (215, '高建军', '13900139015', NULL, '男', 37, 5, 41, 4.4, 'active', '家电清洗，空调、油烟机、洗衣机专业清洗', '2026-03-01 14:17:55', '2026-03-01 14:52:34', 1, '北京', '昌平区', NULL, NULL, NULL, NULL, '[\"家电清洗\", \"空调清洗\", \"油烟机清洗\"]', '[\"昌平区\", \"海淀区\", \"朝阳区\"]', 156, 98);
INSERT INTO `workers` VALUES (216, '朱阿姨', '11900119001', NULL, '女', NULL, 6, 48, 0, 'active', '有6年保洁经验，擅长日常保洁和深度清洁。', '2026-03-01 20:23:27', '2026-03-01 20:23:27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (217, '秦师傅', '11800118001', NULL, '男', NULL, 9, 78, 0, 'active', '专业月嫂，有产后恢复证书。', '2026-03-01 20:23:40', '2026-03-01 20:23:40', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (218, '尤阿姨', '11700117001', NULL, '女', NULL, 5, 58, 0, 'active', '有护理经验，擅长老人陪护。', '2026-03-01 20:23:58', '2026-03-01 20:23:58', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (219, '许师傅', '11600116001', NULL, '男', NULL, 8, 43, 0, 'active', '擅长做饭，各种菜系都会。', '2026-03-01 20:26:41', '2026-03-01 20:26:41', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (220, '吕阿姨', '11400114001', NULL, '女', NULL, 4, 46, 0, 'active', '有4年保洁经验，工作认真。', '2026-03-01 20:26:59', '2026-03-01 20:26:59', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (221, '褚师傅', '12500125001', NULL, '男', NULL, 9, 42, 0, 'active', '擅长各种家常菜，做饭速度快。', '2026-03-01 20:27:03', '2026-03-01 20:27:03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (222, '何阿姨', '11500115001', NULL, '女', NULL, 7, 68, 0, 'active', '有育儿经验，擅长婴幼儿护理。', '2026-03-01 20:39:19', '2026-03-01 20:39:19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (223, '陈阿姨', '12600126001', NULL, '女', NULL, 6, 68, 0, 'active', '有育儿经验，擅长早教和辅食。', '2026-03-01 20:40:50', '2026-03-01 20:40:50', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);
INSERT INTO `workers` VALUES (224, '卫阿姨', '12400124001', NULL, '女', NULL, 7, 52, 0, 'active', '有7年保洁经验，擅长深度清洁。', '2026-03-01 20:43:10', '2026-03-01 20:43:10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0);

SET FOREIGN_KEY_CHECKS = 1;

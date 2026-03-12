package com.jiazheng.controller;

import com.jiazheng.common.Result;
import com.jiazheng.entity.User;
import com.jiazheng.entity.Order;
import com.jiazheng.entity.Worker;
import com.jiazheng.entity.Feedback;
import com.jiazheng.entity.WorkerApplication;
import com.jiazheng.entity.ServiceCategory;
import com.jiazheng.service.UserService;
import com.jiazheng.service.WorkerService;
import com.jiazheng.service.OrderService;
import com.jiazheng.service.ReviewService;
import com.jiazheng.service.FeedbackService;
import com.jiazheng.service.WorkerApplicationService;
import com.jiazheng.service.AdminNoticeService;
import com.jiazheng.mapper.ServiceCategoryRepository;
import com.jiazheng.algorithm.impl.CollaborativeFilteringAlgorithm;
import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.write.builder.ExcelWriterBuilder;
import com.alibaba.excel.write.builder.ExcelWriterSheetBuilder;
import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.annotation.write.style.ColumnWidth;
import com.alibaba.excel.annotation.write.style.ContentRowHeight;
import com.alibaba.excel.annotation.write.style.HeadRowHeight;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    @Autowired
    private UserService userService;

    @Autowired
    private WorkerService workerService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private ReviewService reviewService;

    @Autowired
    private FeedbackService feedbackService;

    @Autowired
    private WorkerApplicationService workerApplicationService;

    @Autowired
    private ServiceCategoryRepository serviceCategoryRepository;

    @Autowired
    private AdminNoticeService adminNoticeService;

    @Autowired
    private CollaborativeFilteringAlgorithm collaborativeFilteringAlgorithm;

    @GetMapping("/notices")
    public Result<List<Map<String, Object>>> getNotices() {
        return Result.success(adminNoticeService.getNotices());
    }

    @PostMapping("/notices/read/{noticeId}")
    public Result<?> markNoticeRead(@PathVariable String noticeId) {
        adminNoticeService.markRead(noticeId);
        return Result.success("已标为已读");
    }

    @PostMapping("/notices/read-all")
    public Result<?> markAllNoticesRead() {
        adminNoticeService.markAllRead();
        return Result.success("全部已读");
    }

    @GetMapping("/statistics")
    public Result<Map<String, Object>> getStatistics() {
        Map<String, Object> statistics = new HashMap<>();
        statistics.put("todayOrders", orderService.getTodayOrderCount());
        statistics.put("totalUsers", userService.getAllUsers().size());
        statistics.put("totalWorkers", workerService.getAllWorkers().size());
        
        double totalRevenue = orderService.getAllOrders().stream()
                .filter(o -> "completed".equals(o.getOrderStatus()))
                .mapToDouble(o -> o.getTotalAmount() != null ? o.getTotalAmount().doubleValue() : 0.0)
                .sum();
        statistics.put("totalRevenue", totalRevenue);
        
        return Result.success(statistics);
    }

    @GetMapping("/trend")
    public Result<Map<String, Object>> getTrendData(@RequestParam(defaultValue = "week") String period) {
        Map<String, Object> trend = new HashMap<>();
        List<String> dates = new ArrayList<>();
        List<Integer> orders = new ArrayList<>();
        List<Double> revenue = new ArrayList<>();
        
        // 获取最近7天的真实数据
        LocalDate today = LocalDate.now();
        for (int i = 6; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            dates.add(date.format(DateTimeFormatter.ofPattern("MM-dd")));
            
            // 查询当天的订单数量和收入
            LocalDateTime startOfDay = date.atStartOfDay();
            LocalDateTime endOfDay = date.plusDays(1).atStartOfDay();
            
            List<Order> dayOrders = orderService.getAllOrders().stream()
                    .filter(o -> o.getCreatedAt() != null && 
                            !o.getCreatedAt().isBefore(startOfDay) && 
                            o.getCreatedAt().isBefore(endOfDay))
                    .collect(Collectors.toList());
            
            orders.add(dayOrders.size());
            
            double dayRevenue = dayOrders.stream()
                    .filter(o -> "completed".equals(o.getOrderStatus()))
                    .mapToDouble(o -> o.getTotalAmount() != null ? o.getTotalAmount().doubleValue() : 0.0)
                    .sum();
            revenue.add(dayRevenue);
        }
        
        trend.put("dates", dates);
        trend.put("orders", orders);
        trend.put("revenue", revenue);
        return Result.success(trend);
    }

    @GetMapping("/service-distribution")
    public Result<List<Map<String, Object>>> getServiceDistribution() {
        List<Map<String, Object>> distribution = new ArrayList<>();
        
        // 从订单中统计服务类型分布
        List<Order> allOrders = orderService.getAllOrders();
        Map<String, Long> serviceCount = allOrders.stream()
                .filter(o -> o.getServiceType() != null)
                .collect(Collectors.groupingBy(Order::getServiceType, Collectors.counting()));
        
        // 如果没有数据，返回默认分类
        if (serviceCount.isEmpty()) {
            Map<String, Object> item1 = new HashMap<>();
            item1.put("value", 1048);
            item1.put("name", "保洁服务");
            distribution.add(item1);
            
            Map<String, Object> item2 = new HashMap<>();
            item2.put("value", 735);
            item2.put("name", "月嫂服务");
            distribution.add(item2);
            
            Map<String, Object> item3 = new HashMap<>();
            item3.put("value", 580);
            item3.put("name", "护理服务");
            distribution.add(item3);
            
            Map<String, Object> item4 = new HashMap<>();
            item4.put("value", 484);
            item4.put("name", "钟点工");
            distribution.add(item4);
        } else {
            serviceCount.forEach((name, value) -> {
                Map<String, Object> item = new HashMap<>();
                item.put("value", value);
                item.put("name", name);
                distribution.add(item);
            });
        }
        
        return Result.success(distribution);
    }

    @GetMapping("/algorithm/config")
    public Result<Map<String, Object>> getAlgorithmConfig() {
        Map<String, Object> config = new HashMap<>();
        config.put("type", "hybrid");
        config.put("ratingWeight", 40);
        config.put("distanceWeight", 20);
        config.put("experienceWeight", 25);
        config.put("priceWeight", 15);
        return Result.success(config);
    }

    @PutMapping("/algorithm/config")
    public Result<?> updateAlgorithmConfig(@RequestBody Map<String, Object> config) {
        double rating = getConfigDouble(config, "ratingWeight", "contentBased", "ratingWeight", 30);
        double distance = getConfigDouble(config, "distanceWeight", "contentBased", "distanceWeight", 20);
        double experience = getConfigDouble(config, "experienceWeight", "intelligentMatching", "skillWeight", 25);
        double price = getConfigDouble(config, "priceWeight", "contentBased", "priceWeight", 15);
        collaborativeFilteringAlgorithm.setWeights(rating, distance, experience, price);
        return Result.success("算法配置已更新");
    }

    private double getConfigDouble(Map<String, Object> config, String flatKey, String nestedKey, String innerKey, double defaultVal) {
        Object v = config.get(flatKey);
        if (v instanceof Number) return ((Number) v).doubleValue();
        if (config.get(nestedKey) instanceof Map) {
            Object n = ((Map<?, ?>) config.get(nestedKey)).get(innerKey);
            if (n instanceof Number) return ((Number) n).doubleValue();
        }
        return defaultVal;
    }

    @GetMapping("/algorithm/metrics")
    public Result<Map<String, Object>> getAlgorithmMetrics() {
        Map<String, Object> metrics = new HashMap<>();
        metrics.put("accuracy", 85.6);
        metrics.put("precision", 82.3);
        metrics.put("recall", 78.9);
        metrics.put("f1Score", 80.5);
        metrics.put("responseTime", 0.15);
        return Result.success(metrics);
    }

    @GetMapping("/users")
    public Result<?> getUsers(@RequestParam(defaultValue = "0") Integer page,
                                      @RequestParam(defaultValue = "10") Integer pageSize,
                                      @RequestParam(required = false) String keyword,
                                      @RequestParam(required = false) String role,
                                      @RequestParam(required = false) String status) {
        Page<User> userPage = userService.getUsers(page, pageSize, keyword, role, status);
        return Result.success(Map.of(
            "content", userPage.getContent(),
            "totalElements", userPage.getTotalElements(),
            "totalPages", userPage.getTotalPages(),
            "number", userPage.getNumber(),
            "size", userPage.getSize()
        ));
    }

    @GetMapping("/workers")
    public Result<?> getWorkers(@RequestParam(defaultValue = "0") Integer page,
                                        @RequestParam(defaultValue = "10") Integer pageSize,
                                        @RequestParam(required = false) String keyword,
                                        @RequestParam(required = false) String status) {
        List<Worker> all = workerService.getAllWorkers();
        String kw = (keyword != null && !keyword.isEmpty()) ? keyword.trim().toLowerCase() : null;
        String st = (status != null && !status.isEmpty()) ? status.trim().toLowerCase() : null;
        java.util.List<Worker> filtered = all.stream()
            .filter(w -> {
                if (kw != null) {
                    boolean match = (w.getName() != null && w.getName().toLowerCase().contains(kw))
                        || (w.getPhone() != null && w.getPhone().contains(kw));
                    if (!match) return false;
                }
                if (st != null) {
                    String ws = w.getStatus() == null ? "" : w.getStatus().toLowerCase();
                    if ("approved".equals(st) && !("active".equals(ws) || "available".equals(ws))) return false;
                    if ("pending".equals(st) && !"pending".equals(ws)) return false;
                    if ("rejected".equals(st) && !"rejected".equals(ws)) return false;
                }
                return true;
            })
            .toList();
        int start = page * pageSize;
        int end = Math.min(start + pageSize, filtered.size());
        java.util.List<Worker> content = start < filtered.size() ? filtered.subList(start, end) : java.util.List.of();
        return Result.success(Map.of(
            "content", content,
            "totalElements", (long) filtered.size(),
            "totalPages", (filtered.size() + pageSize - 1) / pageSize,
            "number", page,
            "size", pageSize
        ));
    }

    @GetMapping("/orders")
    public Result<?> getOrders(@RequestParam(defaultValue = "0") Integer page,
                                      @RequestParam(defaultValue = "10") Integer pageSize,
                                      @RequestParam(required = false) String keyword,
                                      @RequestParam(required = false) String status,
                                      @RequestParam(required = false) String startDate,
                                      @RequestParam(required = false) String endDate) {
        return Result.success(orderService.getOrders(page, pageSize, keyword, status, startDate, endDate));
    }

    @GetMapping("/orders/export")
    public void exportOrders(HttpServletResponse response) throws IOException {
        // 获取所有订单数据
        List<Order> orders = orderService.getAllOrders();
        
        // 转换为导出数据
        List<OrderExportData> exportData = orders.stream().map(order -> {
            OrderExportData data = new OrderExportData();
            data.setOrderNo(order.getOrderNo());
            data.setOrderStatus(getOrderStatusText(order.getOrderStatus()));
            data.setUserName(order.getUserName());
            data.setUserPhone(order.getUserPhone());
            data.setUserAddress(order.getUserAddress());
            data.setWorkerName(order.getWorkerName());
            data.setWorkerPhone(order.getWorkerPhone());
            data.setServiceType(order.getServiceType());
            data.setServiceDate(order.getServiceDate() != null ? order.getServiceDate().toString() : "");
            data.setServiceTime(order.getStartTime() != null && order.getEndTime() != null ? 
                order.getStartTime().toString() + "-" + order.getEndTime().toString() : "");
            data.setDuration(order.getDuration() + "小时");
            data.setTotalAmount(order.getTotalAmount() != null ? order.getTotalAmount().toString() : "0");
            data.setPaymentStatus(getPaymentStatusText(order.getPaymentStatus()));
            data.setPaymentMethod(order.getPaymentMethod() != null ? order.getPaymentMethod() : "");
            data.setCreateTime(order.getCreatedAt() != null ? order.getCreatedAt().toString() : "");
            data.setRemark(order.getNotes() != null ? order.getNotes() : "");
            return data;
        }).collect(Collectors.toList());
        
        // 设置响应头
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("订单数据_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")), "UTF-8");
        response.setHeader("Content-disposition", "attachment;filename=" + fileName + ".xlsx");
        
        // 写入Excel
        EasyExcel.write(response.getOutputStream(), OrderExportData.class)
                .sheet("订单数据")
                .doWrite(exportData);
    }
    
    private String getOrderStatusText(String status) {
        Map<String, String> statusMap = Map.of(
            "pending", "待接单",
            "accepted", "已接单",
            "in_progress", "服务中",
            "completed", "已完成",
            "cancelled", "已取消"
        );
        return statusMap.getOrDefault(status, status);
    }
    
    private String getPaymentStatusText(String status) {
        Map<String, String> statusMap = Map.of(
            "unpaid", "未支付",
            "paid", "已支付",
            "refunded", "已退款"
        );
        return statusMap.getOrDefault(status, status);
    }

    @GetMapping("/reviews")
    public Result<?> getReviews(@RequestParam(defaultValue = "1") Integer page,
                                        @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(reviewService.getAllReviews(page, pageSize));
    }

    @PostMapping("/users")
    public Result<User> createUser(@RequestBody User user) {
        User createdUser = userService.createUser(user);
        return Result.success("用户创建成功", createdUser);
    }

    @PutMapping("/users/{id}")
    public Result<User> updateUser(@PathVariable Long id, @RequestBody User user) {
        user.setId(id);
        User updatedUser = userService.updateUser(user);
        return Result.success("用户更新成功", updatedUser);
    }

    @PutMapping("/users/{id}/status")
    public Result<?> updateUserStatus(@PathVariable Long id, @RequestBody Map<String, String> request) {
        String status = request.get("status");
        userService.updateUserStatus(id, status);
        return Result.success("用户状态更新成功");
    }

    @PutMapping("/users/enable-all")
    public Result<?> enableAllUsers() {
        int count = userService.enableAllUsers();
        return Result.success("已全部启用，共 " + count + " 个用户", count);
    }

    @DeleteMapping("/users/{id}")
    public Result<?> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return Result.success("用户已删除");
    }

    @PostMapping("/workers")
    public Result<Worker> createWorker(@RequestBody Worker worker) {
        Worker createdWorker = workerService.createWorker(worker);
        return Result.success("家政人员创建成功", createdWorker);
    }

    @PutMapping("/workers/{id}")
    public Result<Worker> updateWorker(@PathVariable Long id, @RequestBody Worker worker) {
        worker.setId(id);
        Worker updatedWorker = workerService.updateWorker(worker);
        return Result.success("家政人员更新成功", updatedWorker);
    }

    @DeleteMapping("/workers/{id}")
    public Result<?> deleteWorker(@PathVariable Long id) {
        try {
            workerService.deleteWorker(id);
            return Result.success("家政人员已删除");
        } catch (DataIntegrityViolationException e) {
            return Result.error("该家政人员有关联订单、评价或收藏，无法删除");
        }
    }

    @GetMapping("/workers/export")
    public void exportWorkers(HttpServletResponse response) throws IOException {
        List<Worker> workers = workerService.getAllWorkers();
        List<WorkerExportData> exportData = workers.stream().map(worker -> {
            WorkerExportData data = new WorkerExportData();
            data.setName(worker.getName());
            data.setPhone(worker.getPhone() != null ? worker.getPhone() : "");
            String categoryName = worker.getCategoryId() != null
                    ? serviceCategoryRepository.findById(worker.getCategoryId().longValue())
                        .map(c -> c.getName())
                        .orElse("")
                    : "";
            data.setServiceType(categoryName);
            data.setExperience(worker.getExperience() != null ? worker.getExperience() + "年" : "0年");
            data.setPrice(worker.getPrice() != null ? "¥" + worker.getPrice() + "/小时" : "");
            data.setRating(worker.getRating() != null ? String.format("%.1f", worker.getRating()) : "0");
            data.setStatus(getWorkerStatusText(worker.getStatus()));
            data.setCreateTime(worker.getCreatedAt() != null ? worker.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "");
            data.setIntroduction(worker.getDescription() != null ? worker.getDescription() : "");
            return data;
        }).collect(Collectors.toList());

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("家政人员_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")), "UTF-8");
        response.setHeader("Content-disposition", "attachment;filename=" + fileName + ".xlsx");

        EasyExcel.write(response.getOutputStream(), WorkerExportData.class)
                .sheet("家政人员")
                .doWrite(exportData);
    }

    private String getWorkerStatusText(String status) {
        if (status == null) return "";
        Map<String, String> map = Map.of(
            "pending", "待审核",
            "approved", "已通过",
            "rejected", "已拒绝",
            "active", "可预约",
            "available", "可预约",
            "inactive", "已下线"
        );
        return map.getOrDefault(status, status);
    }

    @DeleteMapping("/orders/{id}")
    public Result<?> deleteOrder(@PathVariable Long id) {
        orderService.deleteOrder(id);
        return Result.success("订单已删除");
    }

    @PutMapping("/orders/{id}/status")
    public Result<?> updateOrderStatus(@PathVariable Long id, @RequestBody Map<String, String> request) {
        // 管理端传 status，兼容 orderStatus
        String orderStatus = request.get("status") != null ? request.get("status") : request.get("orderStatus");
        if (orderStatus == null || orderStatus.isBlank()) {
            return Result.error("请选择新状态");
        }
        orderService.updateOrderStatus(id, orderStatus);
        return Result.success("订单状态更新成功");
    }

    @DeleteMapping("/reviews/{id}")
    public Result<?> deleteReview(@PathVariable Long id) {
        reviewService.deleteReview(id);
        return Result.success("评价已删除");
    }

    @PutMapping("/reviews/{id}/status")
    public Result<?> updateReviewStatus(@PathVariable Long id, @RequestBody Map<String, Object> request) {
        Integer status = (Integer) request.get("status");
        reviewService.updateReviewStatus(id, status);
        return Result.success("评价状态更新成功");
    }

    // 服务分类管理
    @GetMapping("/categories")
    public Result<List<Map<String, Object>>> getCategories() {
        List<ServiceCategory> categories = serviceCategoryRepository.findAllByOrderBySortOrderAsc();
        List<Map<String, Object>> result = new ArrayList<>();
        
        for (ServiceCategory category : categories) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", category.getId());
            map.put("name", category.getName());
            map.put("description", category.getDescription());
            map.put("icon", category.getIcon());
            map.put("color", category.getColor());
            map.put("sortOrder", category.getSortOrder());
            map.put("status", category.getStatus());
            result.add(map);
        }
        
        return Result.success(result);
    }

    @PostMapping("/categories")
    public Result<Map<String, Object>> createCategory(@RequestBody Map<String, Object> categoryData) {
        ServiceCategory category = new ServiceCategory();
        category.setName((String) categoryData.get("name"));
        category.setDescription((String) categoryData.get("description"));
        category.setIcon((String) categoryData.get("icon"));
        category.setColor((String) categoryData.get("color"));
        category.setSortOrder((Integer) categoryData.get("sortOrder"));
        category.setStatus((Integer) categoryData.get("status"));
        
        ServiceCategory saved = serviceCategoryRepository.save(category);
        
        Map<String, Object> result = new HashMap<>();
        result.put("id", saved.getId());
        result.put("name", saved.getName());
        result.put("description", saved.getDescription());
        result.put("icon", saved.getIcon());
        result.put("color", saved.getColor());
        result.put("sortOrder", saved.getSortOrder());
        result.put("status", saved.getStatus());
        
        return Result.success("分类创建成功", result);
    }

    @PutMapping("/categories/{id}")
    public Result<Map<String, Object>> updateCategory(@PathVariable Long id, @RequestBody Map<String, Object> categoryData) {
        java.util.Optional<ServiceCategory> optional = serviceCategoryRepository.findById(id);
        if (optional.isPresent()) {
            ServiceCategory category = optional.get();
            category.setName((String) categoryData.get("name"));
            category.setDescription((String) categoryData.get("description"));
            category.setIcon((String) categoryData.get("icon"));
            category.setColor((String) categoryData.get("color"));
            category.setSortOrder((Integer) categoryData.get("sortOrder"));
            category.setStatus((Integer) categoryData.get("status"));
            
            ServiceCategory saved = serviceCategoryRepository.save(category);
            
            Map<String, Object> result = new HashMap<>();
            result.put("id", saved.getId());
            result.put("name", saved.getName());
            result.put("description", saved.getDescription());
            result.put("icon", saved.getIcon());
            result.put("color", saved.getColor());
            result.put("sortOrder", saved.getSortOrder());
            result.put("status", saved.getStatus());
            
            return Result.success("分类更新成功", result);
        }
        return Result.error("分类不存在");
    }

    @DeleteMapping("/categories/{id}")
    public Result<?> deleteCategory(@PathVariable Long id) {
        serviceCategoryRepository.deleteById(id);
        return Result.success("分类已删除");
    }

    // 轮播图管理（内存保存当前配置）
    private static final List<Map<String, Object>> BANNERS = new ArrayList<>();

    static {
        Map<String, Object> banner1 = new HashMap<>();
        banner1.put("id", 1L);
        banner1.put("title", "专业家政服务");
        banner1.put("subtitle", "让生活更美好");
        banner1.put("image", "https://pub-141831e61e69445289222976a15b6fb3.r2.dev/Image_to_url_V2/QQ20260228-141301-imagetourl.cloud-1772260094486-4u01be.png");
        banner1.put("link", "/services");
        banner1.put("status", 1);
        BANNERS.add(banner1);

        Map<String, Object> banner2 = new HashMap<>();
        banner2.put("id", 2L);
        banner2.put("title", "智能匹配");
        banner2.put("subtitle", "为您推荐最适合的家政人员");
        banner2.put("image", "https://pub-141831e61e69445289222976a15b6fb3.r2.dev/Image_to_url_V2/QQ20260228-141338-imagetourl.cloud-1772259461373-c9kyqi.png");
        banner2.put("link", "/smart-match");
        banner2.put("status", 1);
        BANNERS.add(banner2);

        Map<String, Object> banner3 = new HashMap<>();
        banner3.put("id", 3L);
        banner3.put("title", "品质保证");
        banner3.put("subtitle", "严格审核，放心选择");
        banner3.put("image", "https://pub-141831e61e69445289222976a15b6fb3.r2.dev/Image_to_url_V2/QQ20260228-141536-imagetourl.cloud-1772259488169-ldgkwz.png");
        banner3.put("link", "");
        banner3.put("status", 1);
        BANNERS.add(banner3);
    }

    @GetMapping("/banners")
    public Result<List<Map<String, Object>>> getBanners() {
        return Result.success(BANNERS);
    }

    @PostMapping("/banners")
    public Result<Map<String, Object>> createBanner(@RequestBody Map<String, Object> banner) {
        long nextId = BANNERS.stream()
                .map(m -> (Number) m.getOrDefault("id", 0L))
                .mapToLong(Number::longValue)
                .max()
                .orElse(0L) + 1;

        Map<String, Object> newBanner = new HashMap<>();
        newBanner.put("id", nextId);
        newBanner.put("title", banner.getOrDefault("title", ""));
        newBanner.put("subtitle", banner.getOrDefault("subtitle", ""));
        newBanner.put("image", banner.getOrDefault("image", ""));
        newBanner.put("link", banner.getOrDefault("link", ""));
        newBanner.put("status", banner.getOrDefault("status", 1));

        BANNERS.add(newBanner);
        return Result.success("轮播图创建成功", newBanner);
    }

    @PutMapping("/banners/{id}")
    public Result<Map<String, Object>> updateBanner(@PathVariable Long id, @RequestBody Map<String, Object> banner) {
        Map<String, Object> target = BANNERS.stream()
                .filter(b -> id.equals(((Number) b.getOrDefault("id", 0L)).longValue()))
                .findFirst()
                .orElse(null);

        if (target == null) {
            banner.put("id", id);
            BANNERS.add(new HashMap<>(banner));
            return Result.success("轮播图已创建", banner);
        }

        target.put("title", banner.getOrDefault("title", target.get("title")));
        target.put("subtitle", banner.getOrDefault("subtitle", target.get("subtitle")));
        target.put("image", banner.getOrDefault("image", target.get("image")));
        target.put("link", banner.getOrDefault("link", target.get("link")));
        target.put("status", banner.getOrDefault("status", target.get("status")));

        return Result.success("轮播图更新成功", target);
    }

    @DeleteMapping("/banners/{id}")
    public Result<?> deleteBanner(@PathVariable Long id) {
        BANNERS.removeIf(b -> id.equals(((Number) b.getOrDefault("id", 0L)).longValue()));
        return Result.success("轮播图已删除");
    }

    // 系统设置（持久化到内存，供管理端与首页读取）
    @GetMapping("/settings")
    public Result<Map<String, Object>> getSettings() {
        return Result.success(com.jiazheng.common.SettingsStore.getAll());
    }

    @PutMapping("/settings")
    public Result<Map<String, Object>> updateSettings(@RequestBody Map<String, Object> settings) {
        com.jiazheng.common.SettingsStore.putAll(settings);
        return Result.success("设置更新成功", com.jiazheng.common.SettingsStore.getAll());
    }

    // 用户反馈管理
    @GetMapping("/feedbacks")
    public Result<?> getFeedbacks(@RequestParam(defaultValue = "0") Integer page,
                                          @RequestParam(defaultValue = "10") Integer pageSize,
                                          @RequestParam(required = false) String keyword,
                                          @RequestParam(required = false) String type,
                                          @RequestParam(required = false) String status) {
        Page<Feedback> feedbackPage = feedbackService.getFeedbacks(page, pageSize, keyword, type, status);
        return Result.success(Map.of(
            "content", feedbackPage.getContent(),
            "totalElements", feedbackPage.getTotalElements(),
            "totalPages", feedbackPage.getTotalPages(),
            "number", feedbackPage.getNumber(),
            "size", feedbackPage.getSize()
        ));
    }

    @GetMapping("/feedbacks/{id}")
    public Result<Feedback> getFeedbackById(@PathVariable Long id) {
        Feedback feedback = feedbackService.getFeedbackById(id);
        return Result.success(feedback);
    }

    @PostMapping("/feedbacks/{id}/reply")
    public Result<?> replyFeedback(@PathVariable Long id, @RequestBody Map<String, String> request) {
        String replyContent = request.get("content");
        String repliedBy = request.get("repliedBy");
        feedbackService.replyFeedback(id, replyContent, repliedBy);
        return Result.success("回复成功");
    }

    @PutMapping("/feedbacks/{id}/status")
    public Result<?> updateFeedbackStatus(@PathVariable Long id, @RequestBody Map<String, String> request) {
        String status = request.get("status");
        feedbackService.updateFeedbackStatus(id, status);
        return Result.success("状态更新成功");
    }

    @DeleteMapping("/feedbacks/{id}")
    public Result<?> deleteFeedback(@PathVariable Long id) {
        feedbackService.deleteFeedback(id);
        return Result.success("反馈已删除");
    }

    @GetMapping("/feedbacks/stats")
    public Result<Map<String, Object>> getFeedbackStats() {
        Map<String, Object> stats = feedbackService.getFeedbackStats();
        return Result.success(stats);
    }

    // 获取最新订单
    @GetMapping("/recent-orders")
    public Result<List<Map<String, Object>>> getRecentOrders(@RequestParam(defaultValue = "5") Integer limit) {
        List<Order> recentOrders = orderService.getAllOrders().stream()
                .filter(o -> o.getCreatedAt() != null)
                .sorted((o1, o2) -> o2.getCreatedAt().compareTo(o1.getCreatedAt()))
                .limit(limit)
                .collect(Collectors.toList());
        
        List<Map<String, Object>> result = new ArrayList<>();
        for (Order order : recentOrders) {
            Map<String, Object> item = new HashMap<>();
            item.put("orderNo", order.getOrderNo());
            item.put("userName", order.getUserName());
            item.put("workerName", order.getWorkerName());
            item.put("serviceType", order.getServiceType());
            item.put("amount", order.getTotalAmount());
            item.put("status", getOrderStatusText(order.getOrderStatus()));
            item.put("createTime", order.getCreatedAt() != null ? 
                    order.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "");
            result.add(item);
        }
        
        return Result.success(result);
    }



    // 订单导出数据类
    @HeadRowHeight(20)
    @ContentRowHeight(18)
    public static class OrderExportData {
        @ExcelProperty("订单编号")
        @ColumnWidth(20)
        private String orderNo;
        
        @ExcelProperty("订单状态")
        @ColumnWidth(12)
        private String orderStatus;
        
        @ExcelProperty("用户姓名")
        @ColumnWidth(12)
        private String userName;
        
        @ExcelProperty("用户电话")
        @ColumnWidth(15)
        private String userPhone;
        
        @ExcelProperty("用户地址")
        @ColumnWidth(30)
        private String userAddress;
        
        @ExcelProperty("家政人员")
        @ColumnWidth(12)
        private String workerName;
        
        @ExcelProperty("家政人员电话")
        @ColumnWidth(15)
        private String workerPhone;
        
        @ExcelProperty("服务类型")
        @ColumnWidth(12)
        private String serviceType;
        
        @ExcelProperty("服务日期")
        @ColumnWidth(12)
        private String serviceDate;
        
        @ExcelProperty("服务时间")
        @ColumnWidth(15)
        private String serviceTime;
        
        @ExcelProperty("服务时长")
        @ColumnWidth(10)
        private String duration;
        
        @ExcelProperty("订单金额")
        @ColumnWidth(12)
        private String totalAmount;
        
        @ExcelProperty("支付状态")
        @ColumnWidth(10)
        private String paymentStatus;
        
        @ExcelProperty("支付方式")
        @ColumnWidth(10)
        private String paymentMethod;
        
        @ExcelProperty("创建时间")
        @ColumnWidth(20)
        private String createTime;
        
        @ExcelProperty("备注")
        @ColumnWidth(25)
        private String remark;
        
        // Getters and Setters
        public String getOrderNo() { return orderNo; }
        public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
        
        public String getOrderStatus() { return orderStatus; }
        public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }
        
        public String getUserName() { return userName; }
        public void setUserName(String userName) { this.userName = userName; }
        
        public String getUserPhone() { return userPhone; }
        public void setUserPhone(String userPhone) { this.userPhone = userPhone; }
        
        public String getUserAddress() { return userAddress; }
        public void setUserAddress(String userAddress) { this.userAddress = userAddress; }
        
        public String getWorkerName() { return workerName; }
        public void setWorkerName(String workerName) { this.workerName = workerName; }
        
        public String getWorkerPhone() { return workerPhone; }
        public void setWorkerPhone(String workerPhone) { this.workerPhone = workerPhone; }
        
        public String getServiceType() { return serviceType; }
        public void setServiceType(String serviceType) { this.serviceType = serviceType; }
        
        public String getServiceDate() { return serviceDate; }
        public void setServiceDate(String serviceDate) { this.serviceDate = serviceDate; }
        
        public String getServiceTime() { return serviceTime; }
        public void setServiceTime(String serviceTime) { this.serviceTime = serviceTime; }
        
        public String getDuration() { return duration; }
        public void setDuration(String duration) { this.duration = duration; }
        
        public String getTotalAmount() { return totalAmount; }
        public void setTotalAmount(String totalAmount) { this.totalAmount = totalAmount; }
        
        public String getPaymentStatus() { return paymentStatus; }
        public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
        
        public String getPaymentMethod() { return paymentMethod; }
        public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
        
        public String getCreateTime() { return createTime; }
        public void setCreateTime(String createTime) { this.createTime = createTime; }
        
        public String getRemark() { return remark; }
        public void setRemark(String remark) { this.remark = remark; }
    }

    @HeadRowHeight(20)
    @ContentRowHeight(18)
    public static class WorkerExportData {
        @ExcelProperty("姓名")
        @ColumnWidth(12)
        private String name;
        @ExcelProperty("手机号")
        @ColumnWidth(15)
        private String phone;
        @ExcelProperty("服务类型")
        @ColumnWidth(14)
        private String serviceType;
        @ExcelProperty("从业年限")
        @ColumnWidth(12)
        private String experience;
        @ExcelProperty("服务价格")
        @ColumnWidth(14)
        private String price;
        @ExcelProperty("评分")
        @ColumnWidth(8)
        private String rating;
        @ExcelProperty("状态")
        @ColumnWidth(10)
        private String status;
        @ExcelProperty("入驻时间")
        @ColumnWidth(20)
        private String createTime;
        @ExcelProperty("个人简介")
        @ColumnWidth(40)
        private String introduction;

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
        public String getServiceType() { return serviceType; }
        public void setServiceType(String serviceType) { this.serviceType = serviceType; }
        public String getExperience() { return experience; }
        public void setExperience(String experience) { this.experience = experience; }
        public String getPrice() { return price; }
        public void setPrice(String price) { this.price = price; }
        public String getRating() { return rating; }
        public void setRating(String rating) { this.rating = rating; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getCreateTime() { return createTime; }
        public void setCreateTime(String createTime) { this.createTime = createTime; }
        public String getIntroduction() { return introduction; }
        public void setIntroduction(String introduction) { this.introduction = introduction; }
    }

    // 入驻申请管理
    @GetMapping("/applications")
    public Result<?> getApplications(@RequestParam(defaultValue = "0") Integer page,
                                            @RequestParam(defaultValue = "10") Integer pageSize,
                                            @RequestParam(required = false) String keyword,
                                            @RequestParam(required = false) String status,
                                            @RequestParam(required = false) String serviceType) {
        Page<WorkerApplication> applicationPage = workerApplicationService.getApplications(page, pageSize, keyword, status, serviceType);
        return Result.success(Map.of(
            "content", applicationPage.getContent(),
            "totalElements", applicationPage.getTotalElements(),
            "totalPages", applicationPage.getTotalPages(),
            "number", applicationPage.getNumber(),
            "size", applicationPage.getSize()
        ));
    }

    @GetMapping("/applications/{id}")
    public Result<WorkerApplication> getApplicationById(@PathVariable Long id) {
        WorkerApplication application = workerApplicationService.getApplicationById(id);
        return Result.success(application);
    }

    @GetMapping("/applications/stats")
    public Result<Map<String, Object>> getApplicationStats() {
        Map<String, Object> stats = workerApplicationService.getApplicationStats();
        return Result.success(stats);
    }

    @PostMapping("/applications/{id}/approve")
    public Result<?> approveApplication(@PathVariable Long id, @RequestBody Map<String, String> request) {
        try {
            String reviewer = request != null && request.get("reviewer") != null ? request.get("reviewer") : "管理员";
            workerApplicationService.approveApplication(id, reviewer);
            return Result.success("申请已通过，家政人员已添加");
        } catch (Exception e) {
            return Result.error("审核失败: " + e.getMessage());
        }
    }

    @PostMapping("/applications/{id}/reject")
    public Result<?> rejectApplication(@PathVariable Long id, @RequestBody Map<String, String> request) {
        String reason = request.get("reason");
        workerApplicationService.rejectApplication(id, "管理员", reason);
        return Result.success("申请已拒绝");
    }

    @DeleteMapping("/applications/{id}")
    public Result<?> deleteApplication(@PathVariable Long id) {
        workerApplicationService.deleteApplication(id);
        return Result.success("申请已删除");
    }
}

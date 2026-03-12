package com.jiazheng.controller;

import com.jiazheng.common.Result;
import com.jiazheng.entity.Order;
import com.jiazheng.entity.Worker;
import com.jiazheng.entity.User;
import com.jiazheng.service.OrderService;
import com.jiazheng.service.WorkerService;
import com.jiazheng.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    @Autowired
    private OrderService orderService;
    
    @Autowired
    private WorkerService workerService;

    @Autowired
    private UserService userService;

    @PostMapping
    public ResponseEntity<?> createOrder(@RequestBody Map<String, Object> orderData) {
        try {
            // 解析用户 ID
            Long userId = Long.parseLong(orderData.get("userId").toString());

            // 从用户服务获取用户信息（使用 users 表中的 username 字段）
            Optional<User> userOptional = userService.getUserById(userId);
            if (!userOptional.isPresent()) {
                return ResponseEntity.badRequest().body("User not found");
            }
            User user = userOptional.get();

            // 从worker服务获取worker信息
            Long workerId = Long.parseLong(orderData.get("workerId").toString());
            Optional<Worker> workerOptional = workerService.getWorkerById(workerId);
            
            if (!workerOptional.isPresent()) {
                return ResponseEntity.badRequest().body("Worker not found");
            }
            
            Worker worker = workerOptional.get();
            
            // 创建订单对象
            Order order = new Order();
            
            // 设置基本信息
            order.setOrderNo("ORD" + java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss")));
            order.setOrderStatus("pending");
            order.setPaymentStatus("unpaid");
            
            // 设置与用户相关的字段
            order.setUserId(userId);
            order.setUserPhone(orderData.get("phone").toString());
            order.setUserAddress(orderData.get("address").toString());
            // 使用 users 表中的 username 作为订单里的用户名
            order.setUserName(user.getUsername());
            order.setWorkerId(workerId);
            order.setWorkerName(worker.getName());
            order.setWorkerPhone(worker.getPhone());
            
            // 从家政人员的服务项目中获取 serviceType；若无关联分类则用 workers.category_id 对应分类名
            var serviceCategories = workerService.getWorkerServiceCategories(workerId);
            if (!serviceCategories.isEmpty()) {
                order.setServiceType(serviceCategories.get(0).getName());
            } else if (worker.getCategoryId() != null) {
                var catOpt = workerService.getServiceCategoryById(worker.getCategoryId().longValue());
                order.setServiceType(catOpt.map(c -> c.getName()).orElse("家政服务"));
            } else {
                order.setServiceType("家政服务");
            }
            
            // 解析日期和时间
            String serviceDateStr = orderData.get("serviceDate").toString();
            String serviceTimeStr = orderData.get("serviceTime").toString();
            int duration = Integer.parseInt(orderData.get("duration").toString());
            
            LocalDate serviceDate = LocalDate.parse(serviceDateStr);
            LocalTime startTime = LocalTime.parse(serviceTimeStr);
            LocalTime endTime = startTime.plusHours(duration);
            
            order.setServiceDate(serviceDate);
            order.setStartTime(startTime);
            order.setEndTime(endTime);
            order.setDuration(duration * 60); // 转换为分钟
            
            // 设置价格信息
            BigDecimal totalAmount = new BigDecimal(orderData.get("amount").toString());
            order.setTotalAmount(totalAmount);
            order.setServicePrice(totalAmount.divide(new BigDecimal(duration), 2, BigDecimal.ROUND_HALF_UP));
            
            // 设置备注
            if (orderData.containsKey("remark")) {
                order.setNotes(orderData.get("remark").toString());
            }
            
            // 保存订单
            Order createdOrder = orderService.createOrder(order);
            return ResponseEntity.ok(Result.success(createdOrder));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Result.error("创建订单失败: " + e.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getOrderById(@PathVariable Long id) {
        Optional<Order> order = orderService.getOrderById(id);
        if (order.isPresent()) {
            return ResponseEntity.ok(order.get());
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping
    public Result<Map<String, Object>> getOrders(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) String orderStatus,
            @RequestParam(required = false) String paymentStatus) {

        Page<Order> orders = orderService.getOrders(page, pageSize, userId, orderStatus, paymentStatus);
        Map<String, Object> response = new HashMap<>();
        response.put("list", orders.getContent());
        response.put("total", orders.getTotalElements());
        return Result.success(response);
    }

    @GetMapping("/search")
    public ResponseEntity<?> searchOrders(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        
        Page<Order> orders = orderService.searchOrders(keyword, page, pageSize);
        Map<String, Object> response = new HashMap<>();
        response.put("list", orders.getContent());
        response.put("total", orders.getTotalElements());
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateOrder(@PathVariable Long id, @RequestBody Order order) {
        order.setId(id);
        Order updatedOrder = orderService.updateOrder(order);
        return ResponseEntity.ok(updatedOrder);
    }

    @PutMapping("/{id}/cancel")
    public ResponseEntity<?> cancelOrder(@PathVariable Long id) {
        orderService.cancelOrder(id);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "订单已取消");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateOrderStatus(@PathVariable Long id, @RequestBody Map<String, String> request) {
        String orderStatus = request.get("orderStatus");
        orderService.updateOrderStatus(id, orderStatus);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "状态更新成功");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/payment")
    public ResponseEntity<?> updatePaymentStatus(@PathVariable Long id, @RequestBody Map<String, String> request) {
        String paymentStatus = request.get("paymentStatus");
        String paymentMethod = request.get("paymentMethod");
        String transactionId = request.get("transactionId");
        orderService.updatePaymentStatus(id, paymentStatus, paymentMethod, transactionId);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "支付状态更新成功");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/review")
    public ResponseEntity<?> addReview(@PathVariable Long id, @RequestBody Map<String, Object> request) {
        Integer rating = (Integer) request.get("rating");
        String reviewContent = (String) request.get("reviewContent");
        orderService.addReview(id, rating, reviewContent);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "评价添加成功");
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteOrder(@PathVariable Long id) {
        orderService.deleteOrder(id);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "订单已删除");
        return ResponseEntity.ok(response);
    }
}
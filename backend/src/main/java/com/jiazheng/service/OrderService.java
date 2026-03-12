package com.jiazheng.service;

import com.jiazheng.entity.Order;
import com.jiazheng.entity.User;
import com.jiazheng.mapper.OrderRepository;
import com.jiazheng.mapper.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private UserRepository userRepository;

    public Order createOrder(Order order) {
        String orderNo = "ORD" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        order.setOrderNo(orderNo);
        order.setOrderStatus("pending");
        order.setPaymentStatus("unpaid");
        return orderRepository.save(order);
    }

    public Optional<Order> getOrderById(Long id) {
        return orderRepository.findById(id);
    }

    public List<Order> getOrdersByUserId(Long userId) {
        return orderRepository.findByUserId(userId);
    }

    public Page<Order> getOrders(Integer page, Integer pageSize, Long userId, String orderStatus, String paymentStatus) {
        Pageable pageable = PageRequest.of(page - 1, pageSize);

        if (userId != null && orderStatus != null && paymentStatus != null) {
            return orderRepository.findByUserIdAndOrderStatusAndPaymentStatus(userId, orderStatus, paymentStatus, pageable);
        }
        if (userId != null && orderStatus != null) {
            return orderRepository.findByUserIdAndOrderStatus(userId, orderStatus, pageable);
        } else if (orderStatus != null) {
            return orderRepository.findByOrderStatus(orderStatus, pageable);
        } else if (userId != null) {
            return orderRepository.findByUserId(userId, pageable);
        }

        return orderRepository.findAll(pageable);
    }

    public Page<Order> searchOrders(String keyword, Integer page, Integer pageSize) {
        Pageable pageable = PageRequest.of(page - 1, pageSize);
        // 使用内存过滤代替数据库查询
        List<Order> allOrders = orderRepository.findAll();
        List<Order> filtered = allOrders.stream()
            .filter(o -> (o.getOrderNo() != null && o.getOrderNo().contains(keyword)) ||
                        (o.getUserAddress() != null && o.getUserAddress().contains(keyword)) ||
                        (o.getNotes() != null && o.getNotes().contains(keyword)) ||
                        (o.getServiceType() != null && o.getServiceType().contains(keyword)) ||
                        (o.getUserName() != null && o.getUserName().contains(keyword)) ||
                        (o.getWorkerName() != null && o.getWorkerName().contains(keyword)))
            .toList();
        
        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), filtered.size());
        List<Order> pageContent = start < filtered.size() ? filtered.subList(start, end) : List.of();
        
        return new org.springframework.data.domain.PageImpl<>(pageContent, pageable, filtered.size());
    }

    public Order updateOrder(Order order) {
        return orderRepository.save(order);
    }

    public void cancelOrder(Long id) {
        Optional<Order> order = orderRepository.findById(id);
        if (order.isPresent()) {
            order.get().setOrderStatus("cancelled");
            order.get().setPaymentStatus("refunded");
            orderRepository.save(order.get());
        }
    }

    public void updateOrderStatus(Long id, String orderStatus) {
        Optional<Order> order = orderRepository.findById(id);
        if (order.isPresent()) {
            order.get().setOrderStatus(orderStatus);
            if ("completed".equals(orderStatus)) {
                order.get().setPaymentStatus("paid");
            }
            orderRepository.save(order.get());
        }
    }

    public void updatePaymentStatus(Long id, String paymentStatus, String paymentMethod, String transactionId) {
        Optional<Order> order = orderRepository.findById(id);
        if (order.isPresent()) {
            order.get().setPaymentStatus(paymentStatus);
            order.get().setPaymentMethod(paymentMethod);
            order.get().setTransactionId(transactionId);
            order.get().setPaymentTime(LocalDateTime.now());
            orderRepository.save(order.get());
        }
    }

    public void addReview(Long id, Integer rating, String reviewContent) {
        Optional<Order> order = orderRepository.findById(id);
        if (order.isPresent()) {
            order.get().setRating(rating);
            order.get().setReviewContent(reviewContent);
            order.get().setReviewTime(LocalDateTime.now());
            orderRepository.save(order.get());
        }
    }

    public void deleteOrder(Long id) {
        orderRepository.deleteById(id);
    }

    public Long getTodayOrderCount() {
        return orderRepository.countTodayOrders("completed");
    }

    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }

    public Page<Order> getOrders(Integer page, Integer pageSize, String keyword, String status,
                                 String startDateStr, String endDateStr) {
        Pageable pageable = PageRequest.of(page, pageSize);
        List<Order> allOrders = orderRepository.findAll();
        // 为了支持按「用户名 username」搜索，这里预先构建 userId -> username 的映射
        Map<Long, String> userIdToUsername = userRepository.findAll().stream()
                .collect(Collectors.toMap(
                        User::getId,
                        u -> u.getUsername() != null ? u.getUsername() : "",
                        (u1, u2) -> u1
                ));
        java.time.LocalDate startDate = null;
        java.time.LocalDate endDate = null;
        if (startDateStr != null && !startDateStr.isEmpty()) {
            try { startDate = java.time.LocalDate.parse(startDateStr); } catch (Exception ignored) {}
        }
        if (endDateStr != null && !endDateStr.isEmpty()) {
            try { endDate = java.time.LocalDate.parse(endDateStr); } catch (Exception ignored) {}
        }
        final java.time.LocalDate sd = startDate;
        final java.time.LocalDate ed = endDate;
        List<Order> filtered = allOrders.stream()
            .filter(o -> {
                if (status != null && !status.isEmpty() && !status.equals(o.getOrderStatus())) return false;
                if (keyword != null && !keyword.isEmpty()) {
                    String lowerKeyword = keyword.toLowerCase();
                    String username = userIdToUsername.get(o.getUserId());
                    if (!(
                          // 订单号
                          (o.getOrderNo() != null && o.getOrderNo().toLowerCase().contains(lowerKeyword)) ||
                          // 用户姓名（例如：王先生）
                          (o.getUserName() != null && o.getUserName().toLowerCase().contains(lowerKeyword)) ||
                          // 登录用户名（users 表里的 username，如 user54）
                          (username != null && !username.isEmpty() && username.toLowerCase().contains(lowerKeyword)) ||
                          // 家政人员姓名
                          (o.getWorkerName() != null && o.getWorkerName().toLowerCase().contains(lowerKeyword)) ||
                          // 用户手机号
                          (o.getUserPhone() != null && o.getUserPhone().toLowerCase().contains(lowerKeyword)) ||
                          // 用户地址
                          (o.getUserAddress() != null && o.getUserAddress().toLowerCase().contains(lowerKeyword)) ||
                          // 服务类型
                          (o.getServiceType() != null && o.getServiceType().toLowerCase().contains(lowerKeyword))
                    ))
                        return false;
                }
                // 时间范围按「下单时间」createdAt 匹配，与列表「下单时间」列一致
                if (sd != null && (o.getCreatedAt() == null || o.getCreatedAt().toLocalDate().isBefore(sd))) return false;
                if (ed != null && (o.getCreatedAt() == null || o.getCreatedAt().toLocalDate().isAfter(ed))) return false;
                return true;
            })
            .toList();
        int start = (int) pageable.getOffset();
        int end = Math.min((start + pageable.getPageSize()), filtered.size());
        List<Order> pageContent = start < filtered.size() ? filtered.subList(start, end) : List.of();
        return new org.springframework.data.domain.PageImpl<>(pageContent, pageable, filtered.size());
    }
}

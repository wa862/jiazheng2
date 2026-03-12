package com.jiazheng.mapper;

import com.jiazheng.entity.Order;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByUserId(Long userId);
    List<Order> findByWorkerId(Long workerId);
    List<Order> findByOrderStatus(String orderStatus);
    Page<Order> findByUserId(Long userId, Pageable pageable);
    Page<Order> findByOrderStatus(String orderStatus, Pageable pageable);
    Page<Order> findByUserIdAndOrderStatus(Long userId, String orderStatus, Pageable pageable);
    Page<Order> findByUserIdAndOrderStatusAndPaymentStatus(Long userId, String orderStatus, String paymentStatus, Pageable pageable);

    @Query("SELECT COUNT(o) FROM Order o WHERE o.orderStatus = :orderStatus AND o.createdAt >= CURRENT_DATE")
    Long countTodayOrders(@Param("orderStatus") String orderStatus);
}

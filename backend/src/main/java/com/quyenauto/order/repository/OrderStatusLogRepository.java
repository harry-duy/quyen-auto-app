package com.quyenauto.order.repository;

import com.quyenauto.order.entity.OrderStatusLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderStatusLogRepository extends JpaRepository<OrderStatusLog, Long> {

    List<OrderStatusLog> findByOrderIdOrderByCreatedAtDesc(Long orderId);
}

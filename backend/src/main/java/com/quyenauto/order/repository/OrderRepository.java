package com.quyenauto.order.repository;

import com.quyenauto.order.entity.Order;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {

    Optional<Order> findByOrderCode(String orderCode);

    Page<Order> findByCustomerId(Long customerId, Pageable pageable);

    Page<Order> findByStatus(Order.OrderStatus status, Pageable pageable);

    Page<Order> findByAssignedStaffId(Long staffId, Pageable pageable);

    long countByStatus(Order.OrderStatus status);

    @Query("SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o WHERE o.status = :status")
    BigDecimal sumRevenueByStatus(Order.OrderStatus status);

    @Query("SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o WHERE o.status = :status " +
           "AND MONTH(o.createdAt) = :month AND YEAR(o.createdAt) = :year")
    BigDecimal sumMonthlyRevenueByStatus(Order.OrderStatus status, int month, int year);
}

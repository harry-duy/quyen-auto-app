package com.quyenauto.order.service;

import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.order.dto.OrderResponse;
import com.quyenauto.order.dto.UpdateOrderStatusRequest;
import com.quyenauto.order.entity.Order;
import com.quyenauto.order.entity.OrderStatusLog;
import com.quyenauto.order.repository.OrderRepository;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;

    public Page<OrderResponse> getByCustomer(Long customerId, Pageable pageable) {
        return orderRepository.findByCustomerId(customerId, pageable).map(OrderResponse::from);
    }

    public Page<OrderResponse> getByStatus(String status, Pageable pageable) {
        Order.OrderStatus os = Order.OrderStatus.valueOf(status.toUpperCase());
        return orderRepository.findByStatus(os, pageable).map(OrderResponse::from);
    }

    public Page<OrderResponse> getAll(Pageable pageable) {
        return orderRepository.findAll(pageable).map(OrderResponse::from);
    }

    public OrderResponse getById(Long id) {
        return OrderResponse.from(findById(id));
    }

    public OrderResponse getByCode(String code) {
        Order order = orderRepository.findByOrderCode(code)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng"));
        return OrderResponse.from(order);
    }

    @Transactional
    public OrderResponse updateStatus(Long id, Long staffId, UpdateOrderStatusRequest request) {
        Order order = findById(id);
        String newProductionStatus = productionStatusFromRequest(request.getStatus().toUpperCase());
        Order.OrderStatus newStatus = orderStatusForProductionStatus(newProductionStatus);

        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));

        OrderStatusLog log = OrderStatusLog.builder()
                .order(order)
                .status(newStatus.name())
                .note(request.getNote())
                .changedBy(staff)
                .build();

        order.setStatus(newStatus);
        order.setProductionStatus(newProductionStatus);
        order.getStatusLogs().add(log);

        return OrderResponse.from(orderRepository.save(order));
    }

    private Order findById(Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng"));
    }

    private String productionStatusFromRequest(String status) {
        return switch (status) {
            case "PENDING", "RECEIVED" -> "RECEIVED";
            case "INFO_CONFIRMED" -> "INFO_CONFIRMED";
            case "QUOTED_DEPOSITED" -> "QUOTED_DEPOSITED";
            case "CONFIRMED", "ORDER_CONFIRMED", "NOT_STARTED" -> "ORDER_CONFIRMED";
            case "IN_PRODUCTION", "PRODUCTION_STARTED", "IN_PROGRESS" -> "PRODUCTION_STARTED";
            case "QUALITY_CHECKING" -> "QUALITY_CHECKING";
            case "DELIVERING" -> "QUALITY_CHECKING";
            case "COMPLETED" -> "COMPLETED";
            case "CANCELLED" -> "CANCELLED";
            default -> throw new BusinessException(HttpStatus.BAD_REQUEST, "Tráº¡ng thÃ¡i Ä‘Æ¡n hÃ ng khÃ´ng há»£p lá»‡");
        };
    }

    private Order.OrderStatus orderStatusForProductionStatus(String productionStatus) {
        return switch (productionStatus) {
            case "RECEIVED", "INFO_CONFIRMED" -> Order.OrderStatus.PENDING;
            case "QUOTED_DEPOSITED", "ORDER_CONFIRMED" -> Order.OrderStatus.CONFIRMED;
            case "PRODUCTION_STARTED", "QUALITY_CHECKING" -> Order.OrderStatus.IN_PRODUCTION;
            case "COMPLETED" -> Order.OrderStatus.COMPLETED;
            case "CANCELLED" -> Order.OrderStatus.CANCELLED;
            default -> Order.OrderStatus.PENDING;
        };
    }

    public String generateOrderCode() {
        String prefix = "QA" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyMM"));
        long count = orderRepository.count() + 1;
        String code;
        do {
            code = prefix + String.format("%04d", count++);
        } while (orderRepository.existsByOrderCode(code));
        return code;
    }
}

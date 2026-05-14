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
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public Page<OrderResponse> getByCustomer(Long customerId, Pageable pageable) {
        return orderRepository.findByCustomerId(customerId, pageable).map(OrderResponse::from);
    }

    @Transactional(readOnly = true)
    public Page<OrderResponse> getByStatus(String status, Pageable pageable) {
        Order.OrderStatus os = Order.OrderStatus.valueOf(status.toUpperCase());
        return orderRepository.findByStatus(os, pageable).map(OrderResponse::from);
    }

    @Transactional(readOnly = true)
    public Page<OrderResponse> getAll(Pageable pageable) {
        return orderRepository.findAll(pageable).map(OrderResponse::from);
    }

    @Transactional(readOnly = true)
    public OrderResponse getById(Long id) {
        return OrderResponse.from(findById(id));
    }

    @Transactional(readOnly = true)
    public OrderResponse getByCode(String code) {
        Order order = orderRepository.findByOrderCode(code)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng"));
        return OrderResponse.from(order);
    }

    @Transactional
    public OrderResponse updateStatus(Long id, Long staffId, UpdateOrderStatusRequest request) {
        Order order = findById(id);
        Order.OrderStatus newStatus = Order.OrderStatus.valueOf(request.getStatus().toUpperCase());

        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));

        OrderStatusLog log = OrderStatusLog.builder()
                .order(order)
                .status(newStatus.name())
                .note(request.getNote())
                .changedBy(staff)
                .build();

        order.setStatus(newStatus);
        order.getStatusLogs().add(log);

        return OrderResponse.from(orderRepository.save(order));
    }

    /**
     * Khach hang gui yeu cau huy don hang.
     * Don hang chuyen sang CANCEL_REQUESTED (cho staff phe duyet).
     * Chi duoc phep khi status la PENDING hoac CONFIRMED.
     */
    @Transactional
    public OrderResponse cancelOrder(Long customerId, Long orderId) {
        Order order = findById(orderId);

        if (!order.getCustomer().getId().equals(customerId)) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "Bạn không có quyền hủy đơn hàng này");
        }

        Order.OrderStatus current = order.getStatus();
        if (current != Order.OrderStatus.PENDING && current != Order.OrderStatus.CONFIRMED) {
            throw new BusinessException(HttpStatus.BAD_REQUEST,
                    "Chỉ có thể yêu cầu hủy đơn khi đơn đang chờ xác nhận hoặc đã xác nhận");
        }

        User customer = userRepository.findById(customerId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));

        OrderStatusLog log = OrderStatusLog.builder()
                .order(order)
                .status(Order.OrderStatus.CANCEL_REQUESTED.name())
                .note("Khách hàng gửi yêu cầu hủy đơn — chờ nhân viên xác nhận")
                .changedBy(customer)
                .build();

        order.setStatus(Order.OrderStatus.CANCEL_REQUESTED);
        order.getStatusLogs().add(log);

        return OrderResponse.from(orderRepository.save(order));
    }

    /**
     * Staff phe duyet yeu cau huy don hang => CANCELLED.
     */
    @Transactional
    public OrderResponse approveCancel(Long orderId, Long staffId, String note) {
        Order order = findById(orderId);

        if (order.getStatus() != Order.OrderStatus.CANCEL_REQUESTED) {
            throw new BusinessException(HttpStatus.BAD_REQUEST,
                    "Đơn hàng không ở trạng thái yêu cầu hủy");
        }

        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));

        OrderStatusLog log = OrderStatusLog.builder()
                .order(order)
                .status(Order.OrderStatus.CANCELLED.name())
                .note(note != null && !note.isBlank() ? note : "Nhân viên đã duyệt hủy đơn")
                .changedBy(staff)
                .build();

        order.setStatus(Order.OrderStatus.CANCELLED);
        order.getStatusLogs().add(log);

        return OrderResponse.from(orderRepository.save(order));
    }

    /**
     * Staff tu choi yeu cau huy don hang => ve lai PENDING.
     */
    @Transactional
    public OrderResponse rejectCancel(Long orderId, Long staffId, String note) {
        Order order = findById(orderId);

        if (order.getStatus() != Order.OrderStatus.CANCEL_REQUESTED) {
            throw new BusinessException(HttpStatus.BAD_REQUEST,
                    "Đơn hàng không ở trạng thái yêu cầu hủy");
        }

        User staff = userRepository.findById(staffId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy nhân viên"));

        OrderStatusLog log = OrderStatusLog.builder()
                .order(order)
                .status(Order.OrderStatus.PENDING.name())
                .note(note != null && !note.isBlank() ? note : "Nhân viên từ chối yêu cầu hủy đơn")
                .changedBy(staff)
                .build();

        order.setStatus(Order.OrderStatus.PENDING);
        order.getStatusLogs().add(log);

        return OrderResponse.from(orderRepository.save(order));
    }

    private Order findById(Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy đơn hàng"));
    }

    /**
     * Tao ma don hang an toan, khong co race condition.
     * Format: QA{yyMM}{8-hex-chars} — e.g. "QA2605A3F8B12C"
     * Dung UUID.randomUUID() thay vi count()+1 (race condition cu).
     */
    public String generateOrderCode() {
        String prefix = "QA" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyMM"));
        String uniquePart = UUID.randomUUID().toString()
                .replace("-", "").substring(0, 8).toUpperCase();
        return prefix + uniquePart;
    }
}

package com.quyenauto.order.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.common.dto.PageResponse;
import com.quyenauto.order.dto.OrderResponse;
import com.quyenauto.order.dto.UpdateOrderStatusRequest;
import com.quyenauto.order.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Tag(name = "Orders", description = "Đơn hàng")
public class OrderController {

    private final OrderService orderService;

    @GetMapping("/orders")
    @Operation(summary = "Đơn hàng của khách hàng hiện tại")
    public ResponseEntity<ApiResponse<PageResponse<OrderResponse>>> myOrders(
            Authentication auth, @PageableDefault(size = 20) Pageable pageable) {
        Long userId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(orderService.getByCustomer(userId, pageable))));
    }

    @GetMapping("/orders/{id}")
    @Operation(summary = "Chi tiết đơn hàng")
    public ResponseEntity<ApiResponse<OrderResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(orderService.getById(id)));
    }

    @GetMapping("/orders/code/{code}")
    @Operation(summary = "Tra cứu đơn hàng theo mã")
    public ResponseEntity<ApiResponse<OrderResponse>> getByCode(@PathVariable String code) {
        return ResponseEntity.ok(ApiResponse.ok(orderService.getByCode(code)));
    }

    @PatchMapping("/orders/{id}/cancel")
    @Operation(summary = "Khách hàng hủy đơn hàng (chỉ khi PENDING)")
    public ResponseEntity<ApiResponse<OrderResponse>> cancelOrder(
            @PathVariable Long id, Authentication auth) {
        Long customerId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(orderService.cancelOrder(customerId, id)));
    }

    @GetMapping("/staff/orders")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "Tất cả đơn hàng (staff)")
    public ResponseEntity<ApiResponse<PageResponse<OrderResponse>>> allOrders(
            @RequestParam(required = false) String status,
            @PageableDefault(size = 20) Pageable pageable) {
        if (status != null) {
            return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(orderService.getByStatus(status, pageable))));
        }
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(orderService.getAll(pageable))));
    }

    @PatchMapping("/staff/orders/{id}/status")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "Cập nhật trạng thái đơn hàng")
    public ResponseEntity<ApiResponse<OrderResponse>> updateStatus(
            @PathVariable Long id, Authentication auth,
            @Valid @RequestBody UpdateOrderStatusRequest request) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(orderService.updateStatus(id, staffId, request)));
    }

    @PatchMapping("/staff/orders/{id}/cancel/approve")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "Duyệt yêu cầu hủy đơn của khách hàng => CANCELLED")
    public ResponseEntity<ApiResponse<OrderResponse>> approveCancel(
            @PathVariable Long id, Authentication auth,
            @RequestParam(required = false) String note) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(orderService.approveCancel(id, staffId, note)));
    }

    @PatchMapping("/staff/orders/{id}/cancel/reject")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "Từ chối yêu cầu hủy đơn, trả về PENDING")
    public ResponseEntity<ApiResponse<OrderResponse>> rejectCancel(
            @PathVariable Long id, Authentication auth,
            @RequestParam(required = false) String note) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(orderService.rejectCancel(id, staffId, note)));
    }
}

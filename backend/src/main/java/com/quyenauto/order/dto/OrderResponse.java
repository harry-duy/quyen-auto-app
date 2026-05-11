package com.quyenauto.order.dto;

import com.quyenauto.order.entity.Order;
import com.quyenauto.order.entity.OrderStatusLog;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
@AllArgsConstructor
public class OrderResponse {
    private Long id;
    private String orderCode;
    private Long quotationId;
    private Long customerId;
    private String customerName;
    private String customerPhone;
    private Long productId;
    private String productName;
    private BigDecimal totalAmount;
    private BigDecimal depositAmount;
    private String status;
    private String productionStatus;
    private String note;
    private LocalDate estimatedDate;
    private Long assignedStaffId;
    private String assignedStaffName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<StatusLogDto> statusLogs;

    @Data
    @Builder
    @AllArgsConstructor
    public static class StatusLogDto {
        private Long id;
        private String status;
        private String note;
        private LocalDateTime createdAt;

        public static StatusLogDto from(OrderStatusLog log) {
            return StatusLogDto.builder()
                    .id(log.getId())
                    .status(log.getStatus())
                    .note(log.getNote())
                    .createdAt(log.getCreatedAt())
                    .build();
        }
    }

    public static OrderResponse from(Order o) {
        return OrderResponse.builder()
                .id(o.getId())
                .orderCode(o.getOrderCode())
                .quotationId(o.getQuotation() != null ? o.getQuotation().getId() : null)
                .customerId(o.getCustomer().getId())
                .customerName(o.getCustomer().getFullName())
                .customerPhone(o.getCustomer().getPhone())
                .productId(o.getProduct() != null ? o.getProduct().getId() : null)
                .productName(o.getProductName())
                .totalAmount(o.getTotalAmount())
                .depositAmount(o.getDepositAmount())
                .status(o.getStatus().name())
                .productionStatus(o.getProductionStatus())
                .note(o.getNote())
                .estimatedDate(o.getEstimatedDate())
                .assignedStaffId(o.getAssignedStaff() != null ? o.getAssignedStaff().getId() : null)
                .assignedStaffName(o.getAssignedStaff() != null ? o.getAssignedStaff().getFullName() : null)
                .createdAt(o.getCreatedAt())
                .updatedAt(o.getUpdatedAt())
                .statusLogs(o.getStatusLogs().stream()
                        .map(StatusLogDto::from)
                        .collect(Collectors.toList()))
                .build();
    }
}

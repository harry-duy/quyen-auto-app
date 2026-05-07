package com.quyenauto.order.dto;

import com.quyenauto.order.entity.Quotation;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
public class QuotationResponse {
    private Long id;
    private Long customerId;
    private String customerName;
    private Long productId;
    private String productName;
    private String weightRange;
    private String cargoType;
    private String note;
    private BigDecimal quotedPrice;
    private String status;
    private Long staffId;
    private String staffName;
    private String staffNote;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static QuotationResponse from(Quotation q) {
        return QuotationResponse.builder()
                .id(q.getId())
                .customerId(q.getCustomer().getId())
                .customerName(q.getCustomer().getFullName())
                .productId(q.getProduct() != null ? q.getProduct().getId() : null)
                .productName(q.getProduct() != null ? q.getProduct().getName() : null)
                .weightRange(q.getWeightRange())
                .cargoType(q.getCargoType())
                .note(q.getNote())
                .quotedPrice(q.getQuotedPrice())
                .status(q.getStatus().name())
                .staffId(q.getStaff() != null ? q.getStaff().getId() : null)
                .staffName(q.getStaff() != null ? q.getStaff().getFullName() : null)
                .staffNote(q.getStaffNote())
                .createdAt(q.getCreatedAt())
                .updatedAt(q.getUpdatedAt())
                .build();
    }
}

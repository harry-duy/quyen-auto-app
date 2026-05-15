package com.quyenauto.order.dto;

import com.quyenauto.order.entity.Quotation;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
public class QuotationResponse {
    private Long id;
    private Long customerId;
    private String customerName;
    private String customerPhone;
    private Long productId;
    private String productName;
    private String weightRange;
    private String cargoType;
    private String note;

    private String vehicleBrand;
    private String bodyType;
    private String bodySize;
    private Double lengthCm;
    private Double widthCm;
    private Double heightCm;
    private List<String> options;

    private BigDecimal quotedPrice;
    private String status;
    private Long staffId;
    private String staffName;
    private String staffNote;

    private Boolean contacted;
    private Long contactedById;
    private String contactedByName;
    private LocalDateTime contactedAt;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private Boolean isGuest;

    public static QuotationResponse from(Quotation q) {
        boolean guest = q.getCustomer() == null;
        return QuotationResponse.builder()
                .id(q.getId())
                .customerId(guest ? null : q.getCustomer().getId())
                .customerName(guest ? q.getGuestName() : q.getCustomer().getFullName())
                .customerPhone(guest ? q.getGuestPhone() : q.getCustomer().getPhone())
                .isGuest(guest)
                .productId(q.getProduct() != null ? q.getProduct().getId() : null)
                .productName(q.getProduct() != null ? q.getProduct().getName() : null)
                .weightRange(q.getWeightRange())
                .cargoType(q.getCargoType())
                .note(q.getNote())
                .vehicleBrand(q.getVehicleBrand())
                .bodyType(q.getBodyType())
                .bodySize(q.getBodySize())
                .lengthCm(q.getLengthCm())
                .widthCm(q.getWidthCm())
                .heightCm(q.getHeightCm())
                .options(q.getOptions() != null
                        ? Arrays.asList(q.getOptions().split(","))
                        : null)
                .quotedPrice(q.getQuotedPrice())
                .status(q.getStatus().name())
                .staffId(q.getStaff() != null ? q.getStaff().getId() : null)
                .staffName(q.getStaff() != null ? q.getStaff().getFullName() : null)
                .staffNote(q.getStaffNote())
                .contacted(q.getContacted())
                .contactedById(q.getContactedBy() != null ? q.getContactedBy().getId() : null)
                .contactedByName(q.getContactedBy() != null ? q.getContactedBy().getFullName() : null)
                .contactedAt(q.getContactedAt())
                .createdAt(q.getCreatedAt())
                .updatedAt(q.getUpdatedAt())
                .build();
    }
}

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
    private String customerPhone;
    private Long productId;
    private String productName;

    // Thông tin cơ bản theo mẫu báo giá
    private String vehicleModel;
    private Integer quantity;
    private Integer chassisWidth;
    private String boxCode;
    private String boxType;
    private String acType;
    private String acModel;
    private Boolean innerWallInsulated;
    private String specifications;

    // Field cũ giữ lại
    private String weightRange;
    private String cargoType;
    private String note;

    private BigDecimal quotedPrice;
    private String status;
    private Long staffId;
    private String staffName;
    private String staffNote;

    // Theo dõi liên hệ KH
    private Long contactedById;
    private String contactedByName;
    private LocalDateTime contactedAt;

    // Staff-created flow
    private Boolean isStaffCreated;
    private Boolean isNewProductRequest;
    private String newProductDescription;
    private Long approvedById;
    private String approvedByName;
    private LocalDateTime approvedAt;
    private LocalDateTime sentAt;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static QuotationResponse from(Quotation q) {
        return QuotationResponse.builder()
                .id(q.getId())
                .customerId(q.getCustomer().getId())
                .customerName(q.getCustomer().getFullName())
                .customerPhone(q.getCustomer().getPhone())
                .productId(q.getProduct() != null ? q.getProduct().getId() : null)
                .productName(q.getProduct() != null ? q.getProduct().getName() : null)
                .vehicleModel(q.getVehicleModel())
                .quantity(q.getQuantity())
                .chassisWidth(q.getChassisWidth())
                .boxCode(q.getBoxCode())
                .boxType(q.getBoxType())
                .acType(q.getAcType())
                .acModel(q.getAcModel())
                .innerWallInsulated(q.getInnerWallInsulated())
                .specifications(q.getSpecifications())
                .weightRange(q.getWeightRange())
                .cargoType(q.getCargoType())
                .note(q.getNote())
                .quotedPrice(q.getQuotedPrice())
                .status(q.getStatus().name())
                .staffId(q.getStaff() != null ? q.getStaff().getId() : null)
                .staffName(q.getStaff() != null ? q.getStaff().getFullName() : null)
                .staffNote(q.getStaffNote())
                .contactedById(q.getContactedBy() != null ? q.getContactedBy().getId() : null)
                .contactedByName(q.getContactedBy() != null ? q.getContactedBy().getFullName() : null)
                .contactedAt(q.getContactedAt())
                .isStaffCreated(q.getIsStaffCreated())
                .isNewProductRequest(q.getIsNewProductRequest())
                .newProductDescription(q.getNewProductDescription())
                .approvedById(q.getApprovedBy() != null ? q.getApprovedBy().getId() : null)
                .approvedByName(q.getApprovedBy() != null ? q.getApprovedBy().getFullName() : null)
                .approvedAt(q.getApprovedAt())
                .sentAt(q.getSentAt())
                .createdAt(q.getCreatedAt())
                .updatedAt(q.getUpdatedAt())
                .build();
    }
}

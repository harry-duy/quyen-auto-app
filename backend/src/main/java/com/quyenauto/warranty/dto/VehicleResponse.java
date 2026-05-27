package com.quyenauto.warranty.dto;

import com.quyenauto.warranty.entity.Vehicle;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VehicleResponse {
    private Long id;
    private Long ownerId;
    private String ownerName;
    private Long productId;
    private String productName;
    private String plateNumber;
    private String chassisNumber;
    private LocalDate purchaseDate;
    private String contractCode;
    private LocalDate warrantyExpiryDate;
    private LocalDateTime createdAt;

    public static VehicleResponse from(Vehicle v) {
        return VehicleResponse.builder()
                .id(v.getId())
                .ownerId(v.getOwner().getId())
                .ownerName(v.getOwner().getFullName())
                .productId(v.getProduct() != null ? v.getProduct().getId() : null)
                .productName(v.getProduct() != null ? v.getProduct().getName() : null)
                .plateNumber(v.getPlateNumber())
                .chassisNumber(v.getChassisNumber())
                .purchaseDate(v.getPurchaseDate())
                .contractCode(v.getContractCode())
                .warrantyExpiryDate(v.getWarrantyExpiryDate())
                .createdAt(v.getCreatedAt())
                .build();
    }
}

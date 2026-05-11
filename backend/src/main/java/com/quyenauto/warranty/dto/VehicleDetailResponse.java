package com.quyenauto.warranty.dto;

import com.quyenauto.warranty.entity.Vehicle;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
@AllArgsConstructor
public class VehicleDetailResponse {
    private Long id;
    private String plateNumber;
    private String chassisNumber;
    private LocalDate purchaseDate;
    private String productName;

    public static VehicleDetailResponse from(Vehicle v) {
        return VehicleDetailResponse.builder()
                .id(v.getId())
                .plateNumber(v.getPlateNumber())
                .chassisNumber(v.getChassisNumber())
                .purchaseDate(v.getPurchaseDate())
                .productName(v.getProduct() != null ? v.getProduct().getName() : null)
                .build();
    }
}

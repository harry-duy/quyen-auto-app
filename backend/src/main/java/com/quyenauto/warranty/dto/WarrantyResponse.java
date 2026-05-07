package com.quyenauto.warranty.dto;

import com.quyenauto.warranty.entity.WarrantyRequest;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
public class WarrantyResponse {
    private Long id;
    private Long vehicleId;
    private String plateNumber;
    private String chassisNumber;
    private Long customerId;
    private String customerName;
    private String issueDescription;
    private String status;
    private LocalDate scheduledDate;
    private Long technicianId;
    private String technicianName;
    private String result;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static WarrantyResponse from(WarrantyRequest w) {
        return WarrantyResponse.builder()
                .id(w.getId())
                .vehicleId(w.getVehicle().getId())
                .plateNumber(w.getVehicle().getPlateNumber())
                .chassisNumber(w.getVehicle().getChassisNumber())
                .customerId(w.getCustomer().getId())
                .customerName(w.getCustomer().getFullName())
                .issueDescription(w.getIssueDescription())
                .status(w.getStatus().name())
                .scheduledDate(w.getScheduledDate())
                .technicianId(w.getTechnician() != null ? w.getTechnician().getId() : null)
                .technicianName(w.getTechnicianName())
                .result(w.getResult())
                .createdAt(w.getCreatedAt())
                .updatedAt(w.getUpdatedAt())
                .build();
    }
}

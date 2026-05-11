package com.quyenauto.warranty.dto;

import com.quyenauto.warranty.entity.WarrantyLog;
import com.quyenauto.warranty.entity.WarrantyRequest;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
@AllArgsConstructor
public class WarrantyResponse {
    private Long id;
    private VehicleInfo vehicle;
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
    private List<LogDto> logs;

    @Data
    @Builder
    @AllArgsConstructor
    public static class VehicleInfo {
        private Long id;
        private String plateNumber;
        private String chassisNumber;
        private LocalDate purchaseDate;
    }

    @Data
    @Builder
    @AllArgsConstructor
    public static class LogDto {
        private Long id;
        private String action;
        private String note;
        private LocalDateTime createdAt;

        public static LogDto from(WarrantyLog log) {
            return LogDto.builder()
                    .id(log.getId())
                    .action(log.getAction())
                    .note(log.getNote())
                    .createdAt(log.getCreatedAt())
                    .build();
        }
    }

    public static WarrantyResponse from(WarrantyRequest w) {
        return WarrantyResponse.builder()
                .id(w.getId())
                .vehicle(VehicleInfo.builder()
                        .id(w.getVehicle().getId())
                        .plateNumber(w.getVehicle().getPlateNumber())
                        .chassisNumber(w.getVehicle().getChassisNumber())
                        .purchaseDate(w.getVehicle().getPurchaseDate())
                        .build())
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
                .logs(w.getLogs().stream()
                        .map(LogDto::from)
                        .collect(Collectors.toList()))
                .build();
    }
}

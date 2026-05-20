package com.quyenauto.warranty.dto;

import com.quyenauto.warranty.entity.WarrantyLog;
import com.quyenauto.warranty.entity.WarrantyRequest;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WarrantyResponse {
    private Long id;
    private Long vehicleId;
    private String plateNumber;
    private String chassisNumber;
    private String contractCode;
    private LocalDate warrantyExpiryDate;
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
    private List<LogItem> logs;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LogItem {
        private Long id;
        private String action;
        private String note;
        private String performedBy;
        private LocalDateTime createdAt;

        public static LogItem from(WarrantyLog log) {
            return LogItem.builder()
                    .id(log.getId())
                    .action(log.getAction())
                    .note(log.getNote())
                    .performedBy(log.getPerformedBy() != null ? log.getPerformedBy().getFullName() : null)
                    .createdAt(log.getCreatedAt())
                    .build();
        }
    }

    public static WarrantyResponse from(WarrantyRequest w) {
        return WarrantyResponse.builder()
                .id(w.getId())
                .vehicleId(w.getVehicle().getId())
                .plateNumber(w.getVehicle().getPlateNumber())
                .chassisNumber(w.getVehicle().getChassisNumber())
                .contractCode(w.getVehicle().getContractCode())
                .warrantyExpiryDate(w.getVehicle().getWarrantyExpiryDate())
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
                .logs(w.getLogs().stream().map(LogItem::from).toList())
                .build();
    }
}

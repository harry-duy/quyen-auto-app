package com.quyenauto.sparepart.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
public class SparePartAuditLogResponse {
    private Long id;
    private Long sparePartId;
    private String partNumber;
    private String action;
    private String performedBy;
    private String detail;
    private LocalDateTime createdAt;
}

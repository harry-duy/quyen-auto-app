package com.quyenauto.lead.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class LeadResponse {
    private Long id;
    private String phone;
    private String name;
    private Long productId;
    private String productName;
    private String note;
    private String specifications;
    private boolean contacted;
    private LocalDateTime createdAt;
}

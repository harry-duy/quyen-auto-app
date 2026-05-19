package com.quyenauto.lead.dto;

import lombok.Data;

@Data
public class LeadRequest {
    private String phone;
    private String name;
    private Long productId;
    private String productName;
    private String note;
}

package com.quyenauto.order.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class SelectedQuotationOptionRequest {
    private Long optionId;
    private String name;
    private String position;
    private String unit;
    private BigDecimal unitPrice;
    private Integer quantity = 1;
    private String note;
    private Boolean isCustom = false;
}

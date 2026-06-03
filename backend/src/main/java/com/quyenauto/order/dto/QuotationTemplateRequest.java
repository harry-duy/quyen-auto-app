package com.quyenauto.order.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class QuotationTemplateRequest {
    private Long categoryId;
    private Long productId;

    @NotBlank(message = "Tên mẫu không được để trống")
    private String name;

    private String description;
    private String vehicleModel;
    private Integer chassisWidth;
    private String boxType;
    private String acType;
    private String acModel;
    private String specifications;

    @DecimalMin(value = "0", message = "Giá nền không hợp lệ")
    private BigDecimal basePrice = BigDecimal.ZERO;

    private String optionPrices;
    private String managerNote;
    private Boolean isActive = true;
}

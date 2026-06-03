package com.quyenauto.order.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class QuotationOptionRequest {
    @NotBlank
    private String name;

    @NotBlank
    private String position;

    private String unit;

    @NotNull
    private BigDecimal defaultPrice;

    private String description;
    private String internalNote;
    private Boolean isActive = true;
}

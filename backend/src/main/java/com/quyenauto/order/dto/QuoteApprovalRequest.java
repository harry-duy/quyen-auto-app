package com.quyenauto.order.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class QuoteApprovalRequest {

    @NotNull(message = "Giá báo không được để trống")
    private BigDecimal quotedPrice;

    private String staffNote;
}

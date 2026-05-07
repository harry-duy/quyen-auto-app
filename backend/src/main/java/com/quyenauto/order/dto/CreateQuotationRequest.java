package com.quyenauto.order.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateQuotationRequest {

    @NotNull(message = "Sản phẩm không được để trống")
    private Long productId;

    private String weightRange;
    private String cargoType;
    private String note;
}

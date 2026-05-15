package com.quyenauto.order.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class CreateQuotationRequest {

    @NotNull(message = "Sản phẩm không được để trống")
    private Long productId;

    private String weightRange;
    private String cargoType;
    private String note;

    private String vehicleBrand;
    private String bodyType;
    private String bodySize;
    private Double lengthCm;
    private Double widthCm;
    private Double heightCm;
    private List<String> options;
}

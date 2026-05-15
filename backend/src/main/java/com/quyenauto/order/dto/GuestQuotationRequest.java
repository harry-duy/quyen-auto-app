package com.quyenauto.order.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

@Data
public class GuestQuotationRequest {

    @NotBlank(message = "Số điện thoại không được để trống")
    @Size(max = 15)
    private String phone;

    private String fullName;

    private Long productId;
    private String vehicleBrand;
    private String bodyType;
    private String bodySize;
    private Double lengthCm;
    private Double widthCm;
    private Double heightCm;
    private List<String> options;
    private String note;
}

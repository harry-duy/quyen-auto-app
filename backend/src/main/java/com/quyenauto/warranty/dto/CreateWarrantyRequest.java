package com.quyenauto.warranty.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateWarrantyRequest {

    @NotNull(message = "Xe không được để trống")
    private Long vehicleId;

    @NotBlank(message = "Mô tả sự cố không được để trống")
    private String issueDescription;
}

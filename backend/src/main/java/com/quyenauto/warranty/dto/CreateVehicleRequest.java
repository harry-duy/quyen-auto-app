package com.quyenauto.warranty.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class CreateVehicleRequest {

    @NotNull(message = "ID khách hàng không được để trống")
    private Long ownerId;

    private Long productId;

    @NotBlank(message = "Biển số xe không được để trống")
    private String plateNumber;

    @NotBlank(message = "Số khung không được để trống")
    private String chassisNumber;

    @NotNull(message = "Ngày mua không được để trống")
    private LocalDate purchaseDate;

    private String contractCode;

    private LocalDate warrantyExpiryDate;
}

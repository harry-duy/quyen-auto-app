package com.quyenauto.warranty.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UpdateWarrantyResultRequest {

    @NotBlank(message = "Trạng thái không được để trống")
    private String status;

    private String result;
    private String note;
}

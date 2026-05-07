package com.quyenauto.order.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UpdateOrderStatusRequest {

    @NotBlank(message = "Trạng thái không được để trống")
    private String status;

    private String note;
}

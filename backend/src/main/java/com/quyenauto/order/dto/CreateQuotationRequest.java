package com.quyenauto.order.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Min;
import lombok.Data;

@Data
public class CreateQuotationRequest {

    @NotNull(message = "Sản phẩm không được để trống")
    private Long productId;

    @NotBlank(message = "Kiểu loại xe không được để trống")
    private String vehicleModel;

    @Min(value = 1, message = "Số lượng tối thiểu là 1")
    private Integer quantity = 1;

    private Integer chassisWidth;
    private String boxCode;
    private String boxType;
    private String acType;
    private String acModel;
    private Boolean innerWallInsulated;

    // JSON string chứa toàn bộ thông số kỹ thuật (phụ kiện, foam, option)
    private String specifications;

    // Giữ lại các field cũ để tương thích
    private String weightRange;
    private String cargoType;
    private String note;
}

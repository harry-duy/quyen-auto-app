package com.quyenauto.dealer.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateDealerRequest {

    @NotBlank(message = "Tên đại lý không được để trống")
    private String name;

    @NotBlank(message = "Địa chỉ không được để trống")
    private String address;

    @NotBlank(message = "Tỉnh/thành không được để trống")
    private String province;

    @NotBlank(message = "Số điện thoại không được để trống")
    private String phone;

    @NotNull(message = "Vĩ độ không được để trống")
    private Double lat;

    @NotNull(message = "Kinh độ không được để trống")
    private Double lng;
}

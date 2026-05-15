package com.quyenauto.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CreateCustomerRequest {

    @NotBlank(message = "Họ tên không được để trống")
    @Size(max = 100)
    private String fullName;

    @NotBlank(message = "Số điện thoại không được để trống")
    @Size(max = 15)
    private String phone;

    @NotBlank(message = "Mật khẩu không được để trống")
    @Size(min = 6)
    private String password;

    private String email;
}

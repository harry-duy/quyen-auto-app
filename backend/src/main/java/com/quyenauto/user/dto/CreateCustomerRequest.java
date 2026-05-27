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
    @Size(min = 6, message = "Mật khẩu phải ít nhất 6 ký tự")
    private String password;

    private String email;

    /** Ghi chú nội bộ (nhân viên tạo TK ghi lại, VD: "Hợp đồng #123") */
    private String note;
}

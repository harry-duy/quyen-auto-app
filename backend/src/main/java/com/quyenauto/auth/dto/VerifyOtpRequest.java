package com.quyenauto.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class VerifyOtpRequest {

    @NotBlank(message = "Ma OTP khong duoc de trong")
    @Size(min = 6, max = 6, message = "Ma OTP phai co dung 6 chu so")
    private String code;
}

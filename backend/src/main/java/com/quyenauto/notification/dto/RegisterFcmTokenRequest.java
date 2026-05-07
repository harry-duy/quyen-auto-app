package com.quyenauto.notification.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RegisterFcmTokenRequest {

    @NotBlank(message = "FCM token không được để trống")
    private String token;

    private String deviceType;
}

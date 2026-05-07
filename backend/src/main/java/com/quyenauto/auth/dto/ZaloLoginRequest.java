package com.quyenauto.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ZaloLoginRequest {

    @NotBlank(message = "Zalo access token không được để trống")
    private String accessToken;
}

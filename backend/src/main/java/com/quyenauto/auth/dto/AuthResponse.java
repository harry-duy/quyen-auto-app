package com.quyenauto.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private UserInfo user;

    @Data
    @Builder
    @AllArgsConstructor
    public static class UserInfo {
        private Long id;
        private String fullName;
        private String phone;
        private String email;
        private String avatarUrl;
        private String role;
        private Boolean isActive;
        private Boolean emailVerified;
        private Long departmentId;
        private String departmentName;
        private String position;
        private String employeeCode;
    }
}

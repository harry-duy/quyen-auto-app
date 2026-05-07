package com.quyenauto.user.dto;

import com.quyenauto.user.entity.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
public class UserResponse {
    private Long id;
    private String fullName;
    private String phone;
    private String email;
    private String avatarUrl;
    private String role;
    private Boolean isActive;
    private Long departmentId;
    private String position;
    private String employeeCode;
    private LocalDateTime createdAt;

    public static UserResponse from(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .email(user.getEmail())
                .avatarUrl(user.getAvatarUrl())
                .role(user.getRole().name())
                .isActive(user.getIsActive())
                .departmentId(user.getDepartmentId())
                .position(user.getPosition())
                .employeeCode(user.getEmployeeCode())
                .createdAt(user.getCreatedAt())
                .build();
    }
}

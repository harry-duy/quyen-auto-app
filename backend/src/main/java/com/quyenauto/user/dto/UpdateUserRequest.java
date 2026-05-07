package com.quyenauto.user.dto;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateUserRequest {

    @Size(max = 100)
    private String fullName;

    private String email;
    private String avatarUrl;
    private Long departmentId;
    private String position;
    private String role;
}

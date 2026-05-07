package com.quyenauto.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CreateDepartmentRequest {

    @NotBlank(message = "Tên phòng ban không được để trống")
    @Size(max = 100)
    private String name;

    @Size(max = 500)
    private String description;

    private Long managerId;
}

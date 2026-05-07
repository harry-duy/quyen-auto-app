package com.quyenauto.user.dto;

import com.quyenauto.user.entity.Department;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class DepartmentResponse {
    private Long id;
    private String name;
    private String description;
    private Long managerId;
    private String managerName;
    private Boolean isActive;
    private Long staffCount;

    public static DepartmentResponse from(Department d, String managerName, Long staffCount) {
        return DepartmentResponse.builder()
                .id(d.getId())
                .name(d.getName())
                .description(d.getDescription())
                .managerId(d.getManagerId())
                .managerName(managerName)
                .isActive(d.getIsActive())
                .staffCount(staffCount != null ? staffCount : 0L)
                .build();
    }
}

package com.quyenauto.warranty.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class AssignTechnicianRequest {

    @NotNull(message = "Kỹ thuật viên không được để trống")
    private Long technicianId;

    private LocalDate scheduledDate;
}

package com.quyenauto.report.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.report.dto.DashboardResponse;
import com.quyenauto.report.service.ReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/staff/dashboard")
@PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
@RequiredArgsConstructor
@Tag(name = "Reports", description = "Dashboard & báo cáo")
public class ReportController {

    private final ReportService reportService;

    @GetMapping
    @Operation(summary = "Dashboard tổng quan (staff+)")
    public ResponseEntity<ApiResponse<DashboardResponse>> getDashboard() {
        return ResponseEntity.ok(ApiResponse.ok(reportService.getDashboard()));
    }
}

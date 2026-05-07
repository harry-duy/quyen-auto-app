package com.quyenauto.user.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.user.dto.CreateDepartmentRequest;
import com.quyenauto.user.dto.DepartmentResponse;
import com.quyenauto.user.service.DepartmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/departments")
@PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
@RequiredArgsConstructor
@Tag(name = "Departments", description = "Quản lý phòng ban")
public class DepartmentController {

    private final DepartmentService departmentService;

    @GetMapping
    @Operation(summary = "Danh sách phòng ban")
    public ResponseEntity<ApiResponse<List<DepartmentResponse>>> getAll() {
        return ResponseEntity.ok(ApiResponse.ok(departmentService.getAll()));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Chi tiết phòng ban")
    public ResponseEntity<ApiResponse<DepartmentResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(departmentService.getById(id)));
    }

    @PostMapping
    @Operation(summary = "Tạo phòng ban mới")
    public ResponseEntity<ApiResponse<DepartmentResponse>> create(@Valid @RequestBody CreateDepartmentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created(departmentService.create(request)));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Cập nhật phòng ban")
    public ResponseEntity<ApiResponse<DepartmentResponse>> update(
            @PathVariable Long id, @Valid @RequestBody CreateDepartmentRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(departmentService.update(id, request)));
    }
}

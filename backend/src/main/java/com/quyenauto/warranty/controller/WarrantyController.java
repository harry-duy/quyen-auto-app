package com.quyenauto.warranty.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.common.dto.PageResponse;
import com.quyenauto.warranty.dto.*;

import java.util.List;
import com.quyenauto.warranty.service.WarrantyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@Tag(name = "Warranty", description = "Bảo hành")
public class WarrantyController {

    private final WarrantyService warrantyService;

    @GetMapping("/warranty/vehicles")
    @Operation(summary = "Danh sách xe của khách hàng")
    public ResponseEntity<ApiResponse<List<VehicleDetailResponse>>> getMyVehicles(Authentication auth) {
        Long userId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(warrantyService.getMyVehicles(userId)));
    }

    @PostMapping("/warranty")
    @Operation(summary = "Tạo yêu cầu bảo hành (khách hàng)")
    public ResponseEntity<ApiResponse<WarrantyResponse>> create(
            Authentication auth, @Valid @RequestBody CreateWarrantyRequest request) {
        Long userId = Long.parseLong(auth.getName());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created(warrantyService.create(userId, request)));
    }

    @GetMapping("/warranty")
    @Operation(summary = "Danh sách bảo hành của khách hàng")
    public ResponseEntity<ApiResponse<PageResponse<WarrantyResponse>>> myWarranties(
            Authentication auth, @PageableDefault(size = 20) Pageable pageable) {
        Long userId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(warrantyService.getByCustomer(userId, pageable))));
    }

    @GetMapping("/warranty/{id}")
    @Operation(summary = "Chi tiết bảo hành")
    public ResponseEntity<ApiResponse<WarrantyResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(warrantyService.getById(id)));
    }

    @GetMapping("/staff/warranty")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "Tất cả yêu cầu bảo hành (staff)")
    public ResponseEntity<ApiResponse<PageResponse<WarrantyResponse>>> allWarranties(
            @RequestParam(required = false) String status,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(warrantyService.getAll(status, pageable))));
    }

    @PatchMapping("/staff/warranty/{id}/assign")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "Phân công kỹ thuật viên")
    public ResponseEntity<ApiResponse<WarrantyResponse>> assignTechnician(
            @PathVariable Long id, Authentication auth,
            @Valid @RequestBody AssignTechnicianRequest request) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(warrantyService.assignTechnician(id, staffId, request)));
    }

    @PatchMapping("/staff/warranty/{id}/result")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "Cập nhật kết quả bảo hành")
    public ResponseEntity<ApiResponse<WarrantyResponse>> updateResult(
            @PathVariable Long id, Authentication auth,
            @Valid @RequestBody UpdateWarrantyResultRequest request) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(warrantyService.updateResult(id, staffId, request)));
    }
}

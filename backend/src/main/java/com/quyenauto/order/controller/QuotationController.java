package com.quyenauto.order.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.common.dto.PageResponse;
import com.quyenauto.order.dto.*;
import com.quyenauto.order.service.QuotationService;
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
@Tag(name = "Quotations", description = "Yêu cầu báo giá")
public class QuotationController {

    private final QuotationService quotationService;

    @PostMapping("/quotations")
    @Operation(summary = "Tạo yêu cầu báo giá (khách hàng)")
    public ResponseEntity<ApiResponse<QuotationResponse>> create(
            Authentication auth, @Valid @RequestBody CreateQuotationRequest request) {
        Long userId = Long.parseLong(auth.getName());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created(quotationService.create(userId, request)));
    }

    @GetMapping("/quotations")
    @Operation(summary = "Danh sách báo giá của khách hàng hiện tại")
    public ResponseEntity<ApiResponse<PageResponse<QuotationResponse>>> myQuotations(
            Authentication auth, @PageableDefault(size = 20) Pageable pageable) {
        Long userId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(quotationService.getByCustomer(userId, pageable))));
    }

    @GetMapping("/quotations/{id}")
    @Operation(summary = "Chi tiết báo giá")
    public ResponseEntity<ApiResponse<QuotationResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(quotationService.getById(id)));
    }

    @GetMapping("/staff/quotations")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "Tất cả báo giá (staff)")
    public ResponseEntity<ApiResponse<PageResponse<QuotationResponse>>> allQuotations(
            @RequestParam(required = false) String status,
            @PageableDefault(size = 20) Pageable pageable) {
        if (status != null) {
            return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(quotationService.getByStatus(status, pageable))));
        }
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(quotationService.getAll(pageable))));
    }

    @PatchMapping("/staff/quotations/{id}/approve")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "Duyệt và báo giá")
    public ResponseEntity<ApiResponse<QuotationResponse>> approve(
            @PathVariable Long id, Authentication auth,
            @Valid @RequestBody QuoteApprovalRequest request) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(quotationService.approve(id, staffId, request)));
    }
}

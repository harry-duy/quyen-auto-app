package com.quyenauto.order.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.common.dto.PageResponse;
import com.quyenauto.order.dto.QuotationTemplateRequest;
import com.quyenauto.order.dto.QuotationTemplateResponse;
import com.quyenauto.order.service.QuotationTemplateService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "Quotation Templates", description = "Mẫu báo giá nội bộ")
public class QuotationTemplateController {

    private final QuotationTemplateService templateService;

    @GetMapping("/quotation-templates")
    @Operation(summary = "Danh sách mẫu báo giá đang dùng")
    public ResponseEntity<ApiResponse<PageResponse<QuotationTemplateResponse>>> list(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long productId,
            @PageableDefault(size = 50) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(
                templateService.getTemplates(categoryId, productId, true, pageable))));
    }

    @GetMapping("/manager/quotation-templates")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    @Operation(summary = "Manager xem toàn bộ mẫu báo giá")
    public ResponseEntity<ApiResponse<PageResponse<QuotationTemplateResponse>>> managerList(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long productId,
            @RequestParam(required = false) Boolean activeOnly,
            @PageableDefault(size = 100) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(
                templateService.getTemplates(categoryId, productId, activeOnly, pageable))));
    }

    @GetMapping("/manager/quotation-templates/{id}")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    @Operation(summary = "Chi tiết mẫu báo giá")
    public ResponseEntity<ApiResponse<QuotationTemplateResponse>> detail(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(templateService.getTemplate(id)));
    }

    @PostMapping("/manager/quotation-templates")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    @Operation(summary = "Tạo mẫu báo giá")
    public ResponseEntity<ApiResponse<QuotationTemplateResponse>> create(
            @Valid @RequestBody QuotationTemplateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created(templateService.create(request)));
    }

    @PutMapping("/manager/quotation-templates/{id}")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    @Operation(summary = "Cập nhật mẫu báo giá")
    public ResponseEntity<ApiResponse<QuotationTemplateResponse>> update(
            @PathVariable Long id, @Valid @RequestBody QuotationTemplateRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(templateService.update(id, request)));
    }

    @PatchMapping("/manager/quotation-templates/{id}/toggle-active")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    @Operation(summary = "Bật/tắt mẫu báo giá")
    public ResponseEntity<ApiResponse<QuotationTemplateResponse>> toggle(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(templateService.toggleActive(id)));
    }
}

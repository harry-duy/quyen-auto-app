package com.quyenauto.order.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.common.dto.PageResponse;
import com.quyenauto.order.dto.QuotationOptionRequest;
import com.quyenauto.order.dto.QuotationOptionResponse;
import com.quyenauto.order.service.QuotationOptionService;
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
public class QuotationOptionController {
    private final QuotationOptionService optionService;

    @GetMapping("/quotation-options")
    public ResponseEntity<ApiResponse<PageResponse<QuotationOptionResponse>>> activeOptions(
            @RequestParam(required = false) String position,
            @PageableDefault(size = 100) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(
                optionService.getOptions(position, true, pageable))));
    }

    @GetMapping("/manager/quotation-options")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<PageResponse<QuotationOptionResponse>>> managerOptions(
            @RequestParam(required = false) String position,
            @RequestParam(required = false) Boolean activeOnly,
            @PageableDefault(size = 200) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(
                optionService.getOptions(position, activeOnly, pageable))));
    }

    @PostMapping("/manager/quotation-options")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<QuotationOptionResponse>> create(
            @Valid @RequestBody QuotationOptionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created(optionService.create(request)));
    }

    @PutMapping("/manager/quotation-options/{id}")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<QuotationOptionResponse>> update(
            @PathVariable Long id,
            @Valid @RequestBody QuotationOptionRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(optionService.update(id, request)));
    }

    @PatchMapping("/manager/quotation-options/{id}/toggle-active")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    public ResponseEntity<ApiResponse<QuotationOptionResponse>> toggle(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(optionService.toggleActive(id)));
    }
}

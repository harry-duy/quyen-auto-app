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
            @PageableDefault(size = 20) Pageable pageable,
            Authentication auth) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(
                PageResponse.of(quotationService.getVisibleForStaff(staffId, status, pageable))));
    }

    @PatchMapping("/staff/quotations/{id}/contact")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "Đánh dấu đã liên hệ khách hàng")
    public ResponseEntity<ApiResponse<QuotationResponse>> markContacted(
            @PathVariable Long id, Authentication auth) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(quotationService.markContacted(id, staffId)));
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

    @PatchMapping("/staff/quotations/{id}/confirm-order")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "Chot bao gia va tao don hang")
    public ResponseEntity<ApiResponse<OrderResponse>> confirmOrder(
            @PathVariable Long id, Authentication auth,
            @Valid @RequestBody ConfirmQuotationOrderRequest request) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(quotationService.confirmOrder(id, staffId, request)));
    }

    // ─── Flow mới: NV tạo BG → Manager duyệt → NV gửi KH ────────────────────

    @PostMapping("/staff/quotations/create")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "NV tạo báo giá cho khách hàng (flow mới)")
    public ResponseEntity<ApiResponse<QuotationResponse>> staffCreate(
            Authentication auth, @Valid @RequestBody StaffCreateQuotationRequest request) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created(quotationService.staffCreateQuotation(staffId, request)));
    }

    @PatchMapping("/staff/quotations/{id}/submit-approval")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "NV gửi BG chờ Manager duyệt (DRAFT → PENDING_APPROVAL)")
    public ResponseEntity<ApiResponse<QuotationResponse>> submitForApproval(
            @PathVariable Long id, Authentication auth) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(quotationService.submitForApproval(id, staffId)));
    }

    @GetMapping("/manager/quotations/pending-approval")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    @Operation(summary = "Danh sách BG chờ Manager duyệt")
    public ResponseEntity<ApiResponse<PageResponse<QuotationResponse>>> pendingApproval(
            @PageableDefault(size = 50) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(quotationService.getPendingApproval(pageable))));
    }

    @PatchMapping("/manager/quotations/{id}/approve")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    @Operation(summary = "Manager duyệt báo giá (PENDING_APPROVAL → APPROVED)")
    public ResponseEntity<ApiResponse<QuotationResponse>> managerApprove(
            @PathVariable Long id, Authentication auth,
            @RequestBody ManagerApprovalRequest request) {
        Long managerId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(quotationService.managerApproveQuotation(id, managerId, request)));
    }

    @PatchMapping("/manager/quotations/{id}/reject")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    @Operation(summary = "Manager từ chối báo giá (PENDING_APPROVAL → REJECTED)")
    public ResponseEntity<ApiResponse<QuotationResponse>> managerReject(
            @PathVariable Long id, Authentication auth,
            @RequestBody ManagerApprovalRequest request) {
        Long managerId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(quotationService.managerRejectQuotation(id, managerId, request)));
    }

    @PatchMapping("/staff/quotations/{id}/send")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "NV gửi BG cho KH sau khi Manager duyệt (APPROVED → SENT)")
    public ResponseEntity<ApiResponse<QuotationResponse>> sendToCustomer(
            @PathVariable Long id, Authentication auth) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(quotationService.staffSendToCustomer(id, staffId)));
    }

    @PatchMapping("/staff/quotations/{id}/customer-confirm")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "NV xác nhận KH đồng ý báo giá (SENT → CONTRACT_PENDING)")
    public ResponseEntity<ApiResponse<QuotationResponse>> customerConfirm(
            @PathVariable Long id, Authentication auth) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(quotationService.staffConfirmCustomerAgreed(id, staffId)));
    }

    @PatchMapping("/staff/quotations/{id}/customer-reject")
    @PreAuthorize("hasAnyRole('STAFF', 'MANAGER', 'ADMIN')")
    @Operation(summary = "NV ghi nhận KH từ chối báo giá (SENT → CUSTOMER_REJECTED)")
    public ResponseEntity<ApiResponse<QuotationResponse>> customerReject(
            @PathVariable Long id, Authentication auth) {
        Long staffId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(quotationService.staffMarkCustomerRejected(id, staffId)));
    }
}

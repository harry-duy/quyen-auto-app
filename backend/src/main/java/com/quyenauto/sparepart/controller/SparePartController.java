package com.quyenauto.sparepart.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.common.dto.PageResponse;
import com.quyenauto.sparepart.dto.CreateSparePartRequest;
import com.quyenauto.sparepart.dto.SparePartAuditLogResponse;
import com.quyenauto.sparepart.dto.SparePartResponse;
import com.quyenauto.sparepart.dto.UpdateSparePartRequest;
import com.quyenauto.sparepart.service.SparePartAuditService;
import com.quyenauto.sparepart.service.SparePartService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/staff/spare-parts")
@RequiredArgsConstructor
@Tag(name = "Spare Parts", description = "Quản lý phụ tùng xe")
public class SparePartController {

    private final SparePartService sparePartService;
    private final SparePartAuditService auditService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Thêm phụ tùng mới (kèm hình ảnh)")
    public ResponseEntity<ApiResponse<SparePartResponse>> create(
            @RequestPart("data") @Valid CreateSparePartRequest request,
            @RequestPart("image") MultipartFile image) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created(sparePartService.create(request, image)));
    }

    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Cập nhật phụ tùng")
    public ResponseEntity<ApiResponse<SparePartResponse>> update(
            @PathVariable Long id,
            @RequestPart("data") @Valid UpdateSparePartRequest request,
            @RequestPart(value = "image", required = false) MultipartFile image) {
        return ResponseEntity.ok(ApiResponse.ok(sparePartService.update(id, request, image)));
    }

    @GetMapping
    @Operation(summary = "Danh sách phụ tùng (phân trang, tìm kiếm)")
    public ResponseEntity<ApiResponse<PageResponse<SparePartResponse>>> getAll(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String category,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(sparePartService.getAll(keyword, category, pageable)));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Chi tiết phụ tùng")
    public ResponseEntity<ApiResponse<SparePartResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(sparePartService.getById(id)));
    }

    @GetMapping("/export/excel")
    @Operation(summary = "Xuất danh sách phụ tùng ra Excel")
    public ResponseEntity<byte[]> exportExcel() {
        byte[] data = sparePartService.exportToExcel();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
        headers.setContentDisposition(
                org.springframework.http.ContentDisposition.attachment()
                        .filename("spare-parts.xlsx")
                        .build());
        return ResponseEntity.ok().headers(headers).body(data);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    @Operation(summary = "Xoá phụ tùng (soft delete) — chỉ MANAGER/ADMIN")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Long id) {
        sparePartService.delete(id);
        return ResponseEntity.ok(ApiResponse.noContent());
    }

    @GetMapping("/audit-logs")
    @Operation(summary = "Nhật ký thao tác phụ tùng (ai thêm/sửa/xoá, khi nào)")
    public ResponseEntity<ApiResponse<PageResponse<SparePartAuditLogResponse>>> auditLogs(
            @RequestParam(required = false) Long sparePartId,
            @PageableDefault(size = 20) Pageable pageable) {
        PageResponse<SparePartAuditLogResponse> logs = (sparePartId != null)
                ? auditService.getByPartId(sparePartId, pageable)
                : auditService.getAll(pageable);
        return ResponseEntity.ok(ApiResponse.ok(logs));
    }
}

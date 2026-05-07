package com.quyenauto.dealer.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.dealer.dto.CreateDealerRequest;
import com.quyenauto.dealer.dto.DealerResponse;
import com.quyenauto.dealer.service.DealerService;
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
@RequiredArgsConstructor
@Tag(name = "Dealers", description = "Đại lý / showroom")
public class DealerController {

    private final DealerService dealerService;

    @GetMapping("/dealers")
    @Operation(summary = "Danh sách đại lý (public)")
    public ResponseEntity<ApiResponse<List<DealerResponse>>> getAll(
            @RequestParam(required = false) String province) {
        return ResponseEntity.ok(ApiResponse.ok(dealerService.getAll(province)));
    }

    @GetMapping("/dealers/{id}")
    @Operation(summary = "Chi tiết đại lý")
    public ResponseEntity<ApiResponse<DealerResponse>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(dealerService.getById(id)));
    }

    @PostMapping("/admin/dealers")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    @Operation(summary = "Tạo đại lý mới")
    public ResponseEntity<ApiResponse<DealerResponse>> create(@Valid @RequestBody CreateDealerRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created(dealerService.create(request)));
    }

    @PutMapping("/admin/dealers/{id}")
    @PreAuthorize("hasAnyRole('MANAGER', 'ADMIN')")
    @Operation(summary = "Cập nhật đại lý")
    public ResponseEntity<ApiResponse<DealerResponse>> update(
            @PathVariable Long id, @Valid @RequestBody CreateDealerRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(dealerService.update(id, request)));
    }
}

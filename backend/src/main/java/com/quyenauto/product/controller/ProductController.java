package com.quyenauto.product.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.common.dto.PageResponse;
import com.quyenauto.product.dto.*;
import com.quyenauto.product.service.ProductService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@Tag(name = "Products", description = "Sản phẩm và danh mục")
public class ProductController {

    private final ProductService productService;

    @GetMapping("/products/categories")
    @Operation(summary = "Danh sách danh mục sản phẩm")
    public ResponseEntity<ApiResponse<List<CategoryResponse>>> getCategories() {
        return ResponseEntity.ok(ApiResponse.ok(productService.getAllCategories()));
    }

    @GetMapping("/products")
    @Operation(summary = "Danh sách sản phẩm (phân trang, lọc theo danh mục / tìm kiếm)")
    public ResponseEntity<ApiResponse<PageResponse<ProductResponse>>> getProducts(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String keyword,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(productService.getProducts(categoryId, keyword, pageable))));
    }

    @GetMapping("/products/{id}")
    @Operation(summary = "Chi tiết sản phẩm")
    public ResponseEntity<ApiResponse<ProductResponse>> getProduct(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(productService.getProductById(id)));
    }

    @PostMapping("/admin/products")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Tạo sản phẩm mới")
    public ResponseEntity<ApiResponse<ProductResponse>> createProduct(@Valid @RequestBody CreateProductRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created(productService.createProduct(request)));
    }

    @PutMapping("/admin/products/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Cập nhật sản phẩm")
    public ResponseEntity<ApiResponse<ProductResponse>> updateProduct(
            @PathVariable Long id, @Valid @RequestBody CreateProductRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(productService.updateProduct(id, request)));
    }

    @DeleteMapping("/admin/products/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Xoá sản phẩm (soft delete)")
    public ResponseEntity<ApiResponse<Void>> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.ok(ApiResponse.noContent());
    }
}

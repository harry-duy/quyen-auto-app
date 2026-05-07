package com.quyenauto.product.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class CreateProductRequest {

    @NotNull(message = "Danh mục không được để trống")
    private Long categoryId;

    @NotBlank(message = "Tên sản phẩm không được để trống")
    private String name;

    private String description;
    private String specifications;

    @NotNull(message = "Giá không được để trống")
    private BigDecimal basePrice;

    private List<String> imageUrls;
}

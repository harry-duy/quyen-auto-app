package com.quyenauto.sparepart.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class CreateSparePartRequest {
    @NotBlank(message = "Tên phụ tùng là bắt buộc")
    private String name;
    @NotBlank(message = "Mã phụ tùng là bắt buộc")
    private String partNumber;
    @NotBlank(message = "Danh mục là bắt buộc")
    private String category;
    private String brand;
    private String description;
    private String unit;
    @NotNull(message = "Số lượng tồn kho là bắt buộc")
    @Min(value = 0, message = "Số lượng tồn kho phải ≥ 0")
    private Integer quantityInStock;
    @DecimalMin(value = "0.00", inclusive = true, message = "Giá phải ≥ 0")
    private BigDecimal price;
}

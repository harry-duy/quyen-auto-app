package com.quyenauto.sparepart.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
public class SparePartResponse {
    private Long id;
    private String name;
    private String partNumber;
    private String category;
    private String brand;
    private String description;
    private String unit;
    private Integer quantityInStock;
    private BigDecimal price;
    private String imageUrl;
    private String qrCodeUrl;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

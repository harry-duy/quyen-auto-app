package com.quyenauto.product.dto;

import com.quyenauto.product.entity.Product;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
public class ProductResponse {
    private Long id;
    private Long categoryId;
    private String categoryName;
    private String name;
    private String description;
    private String specifications;
    private BigDecimal basePrice;
    private Boolean isActive;
    private List<String> imageUrls;

    public static ProductResponse from(Product p) {
        return ProductResponse.builder()
                .id(p.getId())
                .categoryId(p.getCategory() != null ? p.getCategory().getId() : null)
                .categoryName(p.getCategory() != null ? p.getCategory().getName() : null)
                .name(p.getName())
                .description(p.getDescription())
                .specifications(p.getSpecifications())
                .basePrice(p.getBasePrice())
                .isActive(p.getIsActive())
                .imageUrls(p.getImages().stream().map(img -> img.getImageUrl()).toList())
                .build();
    }
}

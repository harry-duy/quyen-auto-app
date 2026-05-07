package com.quyenauto.product.dto;

import com.quyenauto.product.entity.ProductCategory;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@AllArgsConstructor
public class CategoryResponse {
    private Long id;
    private String name;
    private String description;
    private String imageUrl;
    private Integer sortOrder;
    private Boolean isActive;

    public static CategoryResponse from(ProductCategory c) {
        return CategoryResponse.builder()
                .id(c.getId())
                .name(c.getName())
                .description(c.getDescription())
                .imageUrl(c.getImageUrl())
                .sortOrder(c.getSortOrder())
                .isActive(c.getIsActive())
                .build();
    }
}

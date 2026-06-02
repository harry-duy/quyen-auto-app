package com.quyenauto.sparepart.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class UpdateSparePartRequest {
    private String name;
    private String partNumber;
    private String category;
    private String brand;
    private String description;
    private String unit;
    private Integer quantityInStock;
    private BigDecimal price;
}

package com.quyenauto.order.dto;

import com.quyenauto.order.entity.QuotationTemplate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
public class QuotationTemplateResponse {
    private Long id;
    private Long categoryId;
    private String categoryName;
    private Long productId;
    private String productName;
    private String name;
    private String description;
    private String vehicleModel;
    private Integer chassisWidth;
    private String boxType;
    private String acType;
    private String acModel;
    private String specifications;
    private BigDecimal basePrice;
    private String optionPrices;
    private String managerNote;
    private Boolean isActive;

    public static QuotationTemplateResponse from(QuotationTemplate template) {
        return QuotationTemplateResponse.builder()
                .id(template.getId())
                .categoryId(template.getCategory() != null ? template.getCategory().getId() : null)
                .categoryName(template.getCategory() != null ? template.getCategory().getName() : null)
                .productId(template.getProduct() != null ? template.getProduct().getId() : null)
                .productName(template.getProduct() != null ? template.getProduct().getName() : null)
                .name(template.getName())
                .description(template.getDescription())
                .vehicleModel(template.getVehicleModel())
                .chassisWidth(template.getChassisWidth())
                .boxType(template.getBoxType())
                .acType(template.getAcType())
                .acModel(template.getAcModel())
                .specifications(template.getSpecifications())
                .basePrice(template.getBasePrice())
                .optionPrices(template.getOptionPrices())
                .managerNote(template.getManagerNote())
                .isActive(template.getIsActive())
                .build();
    }
}

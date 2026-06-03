package com.quyenauto.order.dto;

import com.quyenauto.order.entity.QuotationOption;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
public class QuotationOptionResponse {
    private Long id;
    private String name;
    private String position;
    private String unit;
    private BigDecimal defaultPrice;
    private String description;
    private String internalNote;
    private Boolean isActive;

    public static QuotationOptionResponse from(QuotationOption option) {
        return QuotationOptionResponse.builder()
                .id(option.getId())
                .name(option.getName())
                .position(option.getPosition())
                .unit(option.getUnit())
                .defaultPrice(option.getDefaultPrice())
                .description(option.getDescription())
                .internalNote(option.getInternalNote())
                .isActive(option.getIsActive())
                .build();
    }
}

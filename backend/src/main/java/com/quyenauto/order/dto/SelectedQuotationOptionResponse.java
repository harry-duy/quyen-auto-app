package com.quyenauto.order.dto;

import com.quyenauto.order.entity.QuotationSelectedOption;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
public class SelectedQuotationOptionResponse {
    private Long id;
    private Long optionId;
    private String name;
    private String position;
    private String unit;
    private BigDecimal unitPrice;
    private Integer quantity;
    private BigDecimal totalPrice;
    private BigDecimal managerOverridePrice;
    private String note;
    private Boolean isCustom;

    public static SelectedQuotationOptionResponse from(QuotationSelectedOption option) {
        return SelectedQuotationOptionResponse.builder()
                .id(option.getId())
                .optionId(option.getOption() != null ? option.getOption().getId() : null)
                .name(option.getNameSnapshot())
                .position(option.getPositionSnapshot())
                .unit(option.getUnitSnapshot())
                .unitPrice(option.getUnitPriceSnapshot())
                .quantity(option.getQuantity())
                .totalPrice(option.getTotalPrice())
                .managerOverridePrice(option.getManagerOverridePrice())
                .note(option.getNote())
                .isCustom(option.getIsCustom())
                .build();
    }
}

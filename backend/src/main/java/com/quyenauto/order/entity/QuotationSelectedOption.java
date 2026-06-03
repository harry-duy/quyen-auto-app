package com.quyenauto.order.entity;

import com.quyenauto.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "quotation_selected_options")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuotationSelectedOption extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quotation_id", nullable = false)
    private Quotation quotation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "option_id")
    private QuotationOption option;

    @Column(name = "name_snapshot", nullable = false, length = 200)
    private String nameSnapshot;

    @Column(name = "position_snapshot", nullable = false, length = 50)
    private String positionSnapshot;

    @Builder.Default
    @Column(name = "unit_snapshot", nullable = false, length = 30)
    private String unitSnapshot = "cai";

    @Builder.Default
    @Column(name = "unit_price_snapshot", nullable = false, precision = 15, scale = 2)
    private BigDecimal unitPriceSnapshot = BigDecimal.ZERO;

    @Builder.Default
    @Column(nullable = false)
    private Integer quantity = 1;

    @Builder.Default
    @Column(name = "total_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal totalPrice = BigDecimal.ZERO;

    @Column(name = "manager_override_price", precision = 15, scale = 2)
    private BigDecimal managerOverridePrice;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Builder.Default
    @Column(name = "is_custom", nullable = false)
    private Boolean isCustom = false;
}

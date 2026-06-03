package com.quyenauto.order.entity;

import com.quyenauto.common.entity.BaseEntity;
import com.quyenauto.product.entity.Product;
import com.quyenauto.product.entity.ProductCategory;
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
@Table(name = "quotation_templates")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuotationTemplate extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private ProductCategory category;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "vehicle_model", length = 100)
    private String vehicleModel;

    @Column(name = "chassis_width")
    private Integer chassisWidth;

    @Column(name = "box_type", length = 30)
    private String boxType;

    @Column(name = "ac_type", length = 20)
    private String acType;

    @Column(name = "ac_model", length = 100)
    private String acModel;

    @Column(columnDefinition = "JSON")
    private String specifications;

    @Builder.Default
    @Column(name = "base_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal basePrice = BigDecimal.ZERO;

    @Column(name = "option_prices", columnDefinition = "JSON")
    private String optionPrices;

    @Column(name = "manager_note", columnDefinition = "TEXT")
    private String managerNote;

    @Builder.Default
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;
}

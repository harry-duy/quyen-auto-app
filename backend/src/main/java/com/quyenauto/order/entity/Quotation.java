package com.quyenauto.order.entity;

import com.quyenauto.common.entity.BaseEntity;
import com.quyenauto.product.entity.Product;
import com.quyenauto.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "quotations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Quotation extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(name = "weight_range", length = 50)
    private String weightRange;

    @Column(name = "cargo_type", length = 100)
    private String cargoType;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name = "quoted_price", precision = 15, scale = 2)
    private BigDecimal quotedPrice;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private QuotationStatus status = QuotationStatus.PENDING;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "staff_id")
    private User staff;

    @Column(name = "staff_note", columnDefinition = "TEXT")
    private String staffNote;

    public enum QuotationStatus {
        PENDING, QUOTED, ACCEPTED, REJECTED, EXPIRED
    }
}

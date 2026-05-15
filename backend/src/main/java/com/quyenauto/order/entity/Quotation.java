package com.quyenauto.order.entity;

import com.quyenauto.common.entity.BaseEntity;
import com.quyenauto.product.entity.Product;
import com.quyenauto.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "quotations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Quotation extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id")
    private User customer;

    @Column(name = "guest_phone", length = 15)
    private String guestPhone;

    @Column(name = "guest_name", length = 100)
    private String guestName;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(name = "weight_range", length = 50)
    private String weightRange;

    @Column(name = "cargo_type", length = 100)
    private String cargoType;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name = "vehicle_brand", length = 50)
    private String vehicleBrand;

    @Column(name = "body_type", length = 20)
    private String bodyType;

    @Column(name = "body_size", length = 10)
    private String bodySize;

    @Column(name = "length_cm")
    private Double lengthCm;

    @Column(name = "width_cm")
    private Double widthCm;

    @Column(name = "height_cm")
    private Double heightCm;

    @Column(name = "options", length = 500)
    private String options;

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

    @Builder.Default
    @Column(name = "contacted", nullable = false)
    private Boolean contacted = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "contacted_by")
    private User contactedBy;

    @Column(name = "contacted_at")
    private LocalDateTime contactedAt;

    public enum QuotationStatus {
        PENDING, QUOTED, ACCEPTED, REJECTED, EXPIRED
    }
}

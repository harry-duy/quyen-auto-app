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
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(name = "weight_range", length = 50)
    private String weightRange;

    @Column(name = "cargo_type", length = 100)
    private String cargoType;

    @Column(name = "vehicle_model", length = 100)
    private String vehicleModel;

    @Column(name = "quantity")
    private Integer quantity;

    @Column(name = "chassis_width")
    private Integer chassisWidth;

    @Column(name = "box_code", length = 20)
    private String boxCode;

    @Column(name = "box_type", length = 30)
    private String boxType;

    @Column(name = "ac_type", length = 20)
    private String acType;

    @Column(name = "ac_model", length = 100)
    private String acModel;

    @Column(name = "inner_wall_insulated")
    private Boolean innerWallInsulated;

    @Column(name = "specifications", columnDefinition = "JSON")
    private String specifications;

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

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "contacted_by")
    private User contactedBy;

    @Column(name = "contacted_at")
    private LocalDateTime contactedAt;

    public enum QuotationStatus {
        PENDING, QUOTED, ACCEPTED, REJECTED, EXPIRED
    }
}

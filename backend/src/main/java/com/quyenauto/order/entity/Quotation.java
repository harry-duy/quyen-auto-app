package com.quyenauto.order.entity;

import com.quyenauto.common.entity.BaseEntity;
import com.quyenauto.product.entity.Product;
import com.quyenauto.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "quotations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Quotation extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = true)
    private User customer;

    /** Tên khách vãng lai (khi customer == null) */
    @Column(name = "guest_name", length = 100)
    private String guestName;

    /** SĐT khách vãng lai */
    @Column(name = "guest_phone", length = 20)
    private String guestPhone;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quotation_template_id")
    private QuotationTemplate quotationTemplate;

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
    @Column(name = "base_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal basePrice = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "option_total", nullable = false, precision = 15, scale = 2)
    private BigDecimal optionTotal = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "estimated_total", nullable = false, precision = 15, scale = 2)
    private BigDecimal estimatedTotal = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "adjustment_fee", nullable = false, precision = 15, scale = 2)
    private BigDecimal adjustmentFee = BigDecimal.ZERO;

    @Builder.Default
    @Column(name = "discount_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Column(name = "approved_total", precision = 15, scale = 2)
    private BigDecimal approvedTotal;

    @Column(name = "price_note", columnDefinition = "TEXT")
    private String priceNote;

    @Column(name = "technical_note", columnDefinition = "TEXT")
    private String technicalNote;

    @Column(name = "revision_note", columnDefinition = "TEXT")
    private String revisionNote;

    @Builder.Default
    @OneToMany(mappedBy = "quotation", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<QuotationSelectedOption> selectedOptions = new ArrayList<>();

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

    // ── Staff-created quotation flow ──────────────────────────────────────────

    /** true = NV tạo BG (flow mới); false = KH tự gửi yêu cầu (flow cũ) */
    @Builder.Default
    @Column(name = "is_staff_created")
    private Boolean isStaffCreated = false;

    /** Khi NV chọn "Sản phẩm mới" thay vì chọn SP có sẵn */
    @Builder.Default
    @Column(name = "is_new_product_request")
    private Boolean isNewProductRequest = false;

    /** Mô tả dự án khi is_new_product_request = true */
    @Column(name = "new_product_description", columnDefinition = "TEXT")
    private String newProductDescription;

    /** Manager đã duyệt BG */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "approved_by")
    private User approvedBy;

    @Column(name = "approved_at")
    private LocalDateTime approvedAt;

    /** Thời điểm NV gửi BG cho KH */
    @Column(name = "sent_at")
    private LocalDateTime sentAt;

    public enum QuotationStatus {
        // ── Flow cũ (KH tự gửi) ──
        PENDING, QUOTED, ACCEPTED, REJECTED, EXPIRED,
        // ── Flow mới (NV tạo) ────
        DRAFT, PENDING_APPROVAL, WAITING_TECHNICAL_REVIEW, NEED_REVISION,
        APPROVED, SENT, CONTRACT_PENDING, CUSTOMER_REJECTED
    }
}

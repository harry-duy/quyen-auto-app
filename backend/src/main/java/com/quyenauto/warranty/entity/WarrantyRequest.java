package com.quyenauto.warranty.entity;

import com.quyenauto.common.entity.BaseEntity;
import com.quyenauto.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "warranty_requests")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WarrantyRequest extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @Column(name = "issue_description", nullable = false, columnDefinition = "TEXT")
    private String issueDescription;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private WarrantyStatus status = WarrantyStatus.PENDING;

    @Column(name = "scheduled_date")
    private LocalDate scheduledDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "technician_id")
    private User technician;

    @Column(name = "technician_name", length = 100)
    private String technicianName;

    @Column(columnDefinition = "TEXT")
    private String result;

    @OneToMany(mappedBy = "warrantyRequest", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("createdAt DESC")
    @Builder.Default
    private List<WarrantyLog> logs = new ArrayList<>();

    public enum WarrantyStatus {
        PENDING, IN_PROGRESS, RESOLVED, REJECTED
    }
}

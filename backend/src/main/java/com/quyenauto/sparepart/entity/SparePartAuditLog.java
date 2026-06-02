package com.quyenauto.sparepart.entity;

import com.quyenauto.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "spare_part_audit_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SparePartAuditLog extends BaseEntity {

    @Column(name = "spare_part_id")
    private Long sparePartId;

    @Column(name = "part_number", length = 100)
    private String partNumber;

    /** CREATE | UPDATE | DELETE */
    @Column(nullable = false, length = 20)
    private String action;

    @Column(name = "performed_by", length = 200)
    private String performedBy;

    @Column(name = "performed_by_id")
    private Long performedById;

    @Column(columnDefinition = "TEXT")
    private String detail;
}

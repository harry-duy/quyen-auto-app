package com.quyenauto.lead.entity;

import com.quyenauto.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "leads")
@Getter
@Setter
public class Lead extends BaseEntity {

    @Column(nullable = false, length = 20)
    private String phone;

    @Column(length = 100)
    private String name;

    @Column(name = "product_id")
    private Long productId;

    @Column(name = "product_name", length = 255)
    private String productName;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(columnDefinition = "TEXT")
    private String specifications;

    @Column(name = "is_contacted", nullable = false)
    private boolean contacted = false;
}

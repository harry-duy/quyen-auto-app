package com.quyenauto.user.entity;

import com.quyenauto.common.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User extends BaseEntity {

    @Column(name = "full_name", nullable = false, length = 100)
    private String fullName;

    @Column(nullable = false, unique = true, length = 15)
    private String phone;

    @Column(unique = true, length = 150)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(name = "avatar_url", length = 500)
    private String avatarUrl;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role;

    @Builder.Default
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "department_id")
    private Long departmentId;

    @Column(length = 100)
    private String position;

    @Column(name = "employee_code", unique = true, length = 20)
    private String employeeCode;

    @Column(name = "zalo_id", unique = true, length = 100)
    private String zaloId;

    @Builder.Default
    @Column(name = "email_verified", nullable = false)
    private Boolean emailVerified = true;
}

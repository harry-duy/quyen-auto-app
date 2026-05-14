package com.quyenauto.auth.repository;

import com.quyenauto.auth.entity.OtpCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

public interface OtpCodeRepository extends JpaRepository<OtpCode, Long> {

    /** Lay OTP moi nhat chua het han cua user theo muc dich */
    @Query("SELECT o FROM OtpCode o WHERE o.user.id = :userId AND o.purpose = :purpose " +
           "ORDER BY o.createdAt DESC LIMIT 1")
    Optional<OtpCode> findLatestByUserIdAndPurpose(Long userId, String purpose);

    /** Xoa tat ca OTP cu cua user (truoc khi tao moi) */
    @Modifying
    @Transactional
    @Query("DELETE FROM OtpCode o WHERE o.user.id = :userId AND o.purpose = :purpose")
    void deleteByUserIdAndPurpose(Long userId, String purpose);
}

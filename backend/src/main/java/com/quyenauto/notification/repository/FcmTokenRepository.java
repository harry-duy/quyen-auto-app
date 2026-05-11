package com.quyenauto.notification.repository;

import com.quyenauto.notification.entity.FcmToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FcmTokenRepository extends JpaRepository<FcmToken, Long> {

    List<FcmToken> findByUserId(Long userId);

    Optional<FcmToken> findByToken(String token);

    void deleteByToken(String token);

    void deleteByUserIdAndToken(Long userId, String token);
}

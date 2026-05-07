package com.quyenauto.notification.service;

import com.quyenauto.notification.dto.NotificationResponse;
import com.quyenauto.notification.dto.RegisterFcmTokenRequest;
import com.quyenauto.notification.entity.FcmToken;
import com.quyenauto.notification.entity.Notification;
import com.quyenauto.notification.repository.FcmTokenRepository;
import com.quyenauto.notification.repository.NotificationRepository;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.repository.UserRepository;
import com.quyenauto.common.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final FcmTokenRepository fcmTokenRepository;
    private final UserRepository userRepository;

    public Page<NotificationResponse> getByUser(Long userId, Pageable pageable) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(NotificationResponse::from);
    }

    public long countUnread(Long userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }

    @Transactional
    public void markAllRead(Long userId) {
        notificationRepository.markAllReadByUserId(userId);
    }

    @Transactional
    public void createNotification(Long userId, String title, String body, String type, String refId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));

        Notification notification = Notification.builder()
                .user(user)
                .title(title)
                .body(body)
                .type(type)
                .refId(refId)
                .isRead(false)
                .build();

        notificationRepository.save(notification);
    }

    @Transactional
    public void registerFcmToken(Long userId, RegisterFcmTokenRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));

        if (fcmTokenRepository.findByToken(request.getToken()).isEmpty()) {
            FcmToken fcmToken = FcmToken.builder()
                    .user(user)
                    .token(request.getToken())
                    .deviceType(request.getDeviceType())
                    .build();
            fcmTokenRepository.save(fcmToken);
        }
    }

    @Transactional
    public void removeFcmToken(String token) {
        fcmTokenRepository.deleteByToken(token);
    }
}

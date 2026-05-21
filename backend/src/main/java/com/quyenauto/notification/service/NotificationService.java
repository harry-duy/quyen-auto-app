package com.quyenauto.notification.service;

import com.quyenauto.notification.dto.NotificationResponse;
import com.quyenauto.notification.dto.RegisterFcmTokenRequest;
import com.quyenauto.notification.entity.FcmToken;
import com.quyenauto.notification.entity.Notification;
import com.quyenauto.notification.repository.FcmTokenRepository;
import com.quyenauto.notification.repository.NotificationRepository;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.entity.UserRole;
import com.quyenauto.user.repository.UserRepository;
import com.quyenauto.common.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final FcmTokenRepository fcmTokenRepository;
    private final UserRepository userRepository;
    private final FirebasePushService firebasePushService;
    private final SimpMessagingTemplate messagingTemplate;

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

    @Transactional
    public void notifyAllStaff(String title, String body, String type, String refId) {
        List<UserRole> staffRoles = List.of(UserRole.STAFF, UserRole.MANAGER);
        List<Long> staffIds = new ArrayList<>();

        Pageable pageable = PageRequest.of(0, 200);
        Page<User> page;
        do {
            page = userRepository.findByRoleIn(staffRoles, pageable);
            for (User staff : page.getContent()) {
                if (!staff.getIsActive()) continue;

                Notification notification = Notification.builder()
                        .user(staff)
                        .title(title)
                        .body(body)
                        .type(type)
                        .refId(refId)
                        .isRead(false)
                        .build();
                Notification saved = notificationRepository.save(notification);
                staffIds.add(staff.getId());

                // WebSocket: push real-time to each staff user's personal queue
                messagingTemplate.convertAndSendToUser(
                        String.valueOf(staff.getId()),
                        "/queue/notifications",
                        Map.of(
                                "id", saved.getId(),
                                "title", title,
                                "body", body,
                                "type", type,
                                "refId", refId,
                                "isRead", false
                        )
                );
            }
            pageable = pageable.next();
        } while (page.hasNext());

        // FCM: push notification to all staff devices (async, non-blocking)
        if (!staffIds.isEmpty()) {
            firebasePushService.sendToUsers(staffIds, title, body, type, refId);
            log.info("Notified {} staff via DB + WebSocket + FCM: {}", staffIds.size(), type);
        }
    }
}

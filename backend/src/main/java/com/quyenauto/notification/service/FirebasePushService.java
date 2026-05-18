package com.quyenauto.notification.service;

import com.google.firebase.messaging.*;
import com.quyenauto.notification.entity.FcmToken;
import com.quyenauto.notification.repository.FcmTokenRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class FirebasePushService {

    private final FirebaseMessaging firebaseMessaging;
    private final FcmTokenRepository fcmTokenRepository;

    @Async
    public void sendToUser(Long userId, String title, String body, String type, String refId) {
        if (firebaseMessaging == null) {
            log.debug("FCM disabled — skipping push for user {}", userId);
            return;
        }

        List<FcmToken> tokens = fcmTokenRepository.findByUserId(userId);
        if (tokens.isEmpty()) {
            return;
        }

        for (FcmToken fcmToken : tokens) {
            try {
                Message message = Message.builder()
                        .setToken(fcmToken.getToken())
                        .setNotification(Notification.builder()
                                .setTitle(title)
                                .setBody(body)
                                .build())
                        .putAllData(Map.of(
                                "type", type,
                                "refId", refId
                        ))
                        .setAndroidConfig(AndroidConfig.builder()
                                .setPriority(AndroidConfig.Priority.HIGH)
                                .setNotification(AndroidNotification.builder()
                                        .setSound("default")
                                        .setClickAction("FLUTTER_NOTIFICATION_CLICK")
                                        .build())
                                .build())
                        .setApnsConfig(ApnsConfig.builder()
                                .setAps(Aps.builder()
                                        .setSound("default")
                                        .setBadge(1)
                                        .build())
                                .build())
                        .build();

                firebaseMessaging.send(message);
                log.debug("FCM sent to user {} device {}", userId, fcmToken.getDeviceType());
            } catch (FirebaseMessagingException e) {
                if (e.getMessagingErrorCode() == MessagingErrorCode.UNREGISTERED
                        || e.getMessagingErrorCode() == MessagingErrorCode.INVALID_ARGUMENT) {
                    log.warn("Removing stale FCM token for user {}", userId);
                    fcmTokenRepository.delete(fcmToken);
                } else {
                    log.error("FCM send failed for user {}: {}", userId, e.getMessage());
                }
            }
        }
    }

    @Async
    public void sendToUsers(List<Long> userIds, String title, String body, String type, String refId) {
        for (Long userId : userIds) {
            sendToUser(userId, title, body, type, refId);
        }
    }
}

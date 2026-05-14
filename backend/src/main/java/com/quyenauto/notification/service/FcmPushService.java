package com.quyenauto.notification.service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.MulticastMessage;
import com.google.firebase.messaging.Notification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Gui FCM push notification thong qua Firebase Admin SDK.
 * - Neu firebaseApp == null (chua cau hinh), bo qua va log WARN.
 * - Max 500 tokens / multicast message (gioi han cua FCM).
 */
@Service
public class FcmPushService {

    private static final Logger log = LoggerFactory.getLogger(FcmPushService.class);
    private static final int FCM_MULTICAST_LIMIT = 500;

    private final FirebaseApp firebaseApp;

    /**
     * Dung @Autowired(required=false) de Spring khong fail khi firebaseApp bean la null.
     */
    @Autowired
    public FcmPushService(@Nullable FirebaseApp firebaseApp) {
        this.firebaseApp = firebaseApp;
    }

    /**
     * Gui thong bao den danh sach FCM token.
     *
     * @param tokens danh sach FCM token cua nguoi dung
     * @param title  tieu de thong bao
     * @param body   noi dung thong bao
     */
    public void send(List<String> tokens, String title, String body) {
        if (firebaseApp == null) {
            log.debug("FCM not configured — skipping push notification: {}", title);
            return;
        }
        if (tokens == null || tokens.isEmpty()) {
            return;
        }

        // Chia thanh nhom <= 500 token (gioi han FCM multicast)
        for (int i = 0; i < tokens.size(); i += FCM_MULTICAST_LIMIT) {
            List<String> batch = tokens.subList(i, Math.min(i + FCM_MULTICAST_LIMIT, tokens.size()));
            sendBatch(batch, title, body);
        }
    }

    private void sendBatch(List<String> tokens, String title, String body) {
        try {
            MulticastMessage message = MulticastMessage.builder()
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .addAllTokens(tokens)
                    .build();

            var response = FirebaseMessaging.getInstance(firebaseApp)
                    .sendEachForMulticast(message);

            log.info("FCM multicast: {} success / {} failure (title='{}')",
                    response.getSuccessCount(), response.getFailureCount(), title);

            // Log chi tiet token that bai (token het han can xoa)
            if (response.getFailureCount() > 0) {
                response.getResponses().stream()
                        .filter(r -> !r.isSuccessful())
                        .forEach(r -> log.debug("FCM token failed: {}", r.getException().getMessage()));
            }

        } catch (FirebaseMessagingException e) {
            log.error("FCM send error: {}", e.getMessage());
        }
    }
}

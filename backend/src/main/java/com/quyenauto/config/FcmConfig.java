package com.quyenauto.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

/**
 * Khoi tao Firebase Admin SDK.
 * - Doc service-account JSON tu env var FIREBASE_SERVICE_ACCOUNT_JSON.
 * - Neu bien nay trong hoac chua set, app van khoi dong binh thuong
 *   va push notification se bi bo qua (log WARN).
 * - Trong production: set bien FIREBASE_SERVICE_ACCOUNT_JSON = noi dung file
 *   google-services-service-account.json (1 dong, chua escape quotes).
 */
@Configuration
public class FcmConfig {

    private static final Logger log = LoggerFactory.getLogger(FcmConfig.class);

    @Value("${firebase.service-account-json:}")
    private String serviceAccountJson;

    @Bean
    public FirebaseApp firebaseApp() {
        if (serviceAccountJson == null || serviceAccountJson.isBlank()) {
            log.warn("Firebase not configured (FIREBASE_SERVICE_ACCOUNT_JSON is empty). " +
                     "Push notifications will be disabled.");
            return null;
        }

        // Neu da co instance roi (e.g. dev hot-reload), tra ve instance cu
        if (!FirebaseApp.getApps().isEmpty()) {
            return FirebaseApp.getInstance();
        }

        try {
            InputStream stream = new ByteArrayInputStream(
                    serviceAccountJson.getBytes(StandardCharsets.UTF_8));

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(stream))
                    .build();

            FirebaseApp app = FirebaseApp.initializeApp(options);
            log.info("Firebase Admin SDK initialized successfully");
            return app;
        } catch (IOException e) {
            log.error("Failed to initialize Firebase Admin SDK: {}", e.getMessage());
            return null;
        }
    }
}

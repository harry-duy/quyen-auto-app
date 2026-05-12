package com.quyenauto.auth.service;

import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class LoginAttemptService {

    private static final int MAX_ATTEMPTS = 5;
    private static final int LOCK_DURATION_MINUTES = 15;

    private final Map<String, AttemptInfo> attempts = new ConcurrentHashMap<>();

    public void loginFailed(String phone) {
        AttemptInfo info = attempts.computeIfAbsent(phone, k -> new AttemptInfo());

        if (info.lockUntil != null && info.lockUntil.isBefore(LocalDateTime.now())) {
            info.count = 0;
            info.lockUntil = null;
        }

        info.count++;
        if (info.count >= MAX_ATTEMPTS) {
            info.lockUntil = LocalDateTime.now().plusMinutes(LOCK_DURATION_MINUTES);
        }
    }

    public void loginSucceeded(String phone) {
        attempts.remove(phone);
    }

    public boolean isBlocked(String phone) {
        AttemptInfo info = attempts.get(phone);
        if (info == null) return false;

        if (info.lockUntil == null) return false;

        if (info.lockUntil.isBefore(LocalDateTime.now())) {
            attempts.remove(phone);
            return false;
        }

        return true;
    }

    public int getRemainingLockMinutes(String phone) {
        AttemptInfo info = attempts.get(phone);
        if (info == null || info.lockUntil == null) return 0;
        long minutes = java.time.Duration.between(LocalDateTime.now(), info.lockUntil).toMinutes();
        return (int) Math.max(0, minutes + 1);
    }

    private static class AttemptInfo {
        int count = 0;
        LocalDateTime lockUntil;
    }
}

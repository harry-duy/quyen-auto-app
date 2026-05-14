package com.quyenauto.notification.controller;

import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.common.dto.PageResponse;
import com.quyenauto.notification.dto.NotificationResponse;
import com.quyenauto.notification.dto.RegisterFcmTokenRequest;
import com.quyenauto.notification.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
@Tag(name = "Notifications", description = "Thông báo")
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    @Operation(summary = "Danh sách thông báo")
    public ResponseEntity<ApiResponse<PageResponse<NotificationResponse>>> getNotifications(
            Authentication auth, @PageableDefault(size = 20) Pageable pageable) {
        Long userId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(PageResponse.of(notificationService.getByUser(userId, pageable))));
    }

    @GetMapping("/unread-count")
    @Operation(summary = "Số thông báo chưa đọc")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(Authentication auth) {
        Long userId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(notificationService.countUnread(userId)));
    }

    @PostMapping("/mark-read")
    @Operation(summary = "Đánh dấu tất cả đã đọc")
    public ResponseEntity<ApiResponse<Void>> markAllRead(Authentication auth) {
        Long userId = Long.parseLong(auth.getName());
        notificationService.markAllRead(userId);
        return ResponseEntity.ok(ApiResponse.noContent());
    }

    @PostMapping("/{id}/read")
    @Operation(summary = "Đánh dấu một thông báo đã đọc")
    public ResponseEntity<ApiResponse<Void>> markOneRead(
            Authentication auth, @PathVariable Long id) {
        Long userId = Long.parseLong(auth.getName());
        notificationService.markOneRead(userId, id);
        return ResponseEntity.ok(ApiResponse.noContent());
    }

    @PostMapping("/fcm-token")
    @Operation(summary = "Đăng ký FCM token")
    public ResponseEntity<ApiResponse<Void>> registerFcmToken(
            Authentication auth, @Valid @RequestBody RegisterFcmTokenRequest request) {
        Long userId = Long.parseLong(auth.getName());
        notificationService.registerFcmToken(userId, request);
        return ResponseEntity.ok(ApiResponse.noContent());
    }

    @DeleteMapping("/fcm-token/{token}")
    @Operation(summary = "Xoá FCM token")
    public ResponseEntity<ApiResponse<Void>> removeFcmToken(
            Authentication auth, @PathVariable String token) {
        Long userId = Long.parseLong(auth.getName());
        notificationService.removeFcmToken(userId, token);
        return ResponseEntity.ok(ApiResponse.noContent());
    }
}

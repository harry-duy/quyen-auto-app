package com.quyenauto.auth.controller;

import com.quyenauto.auth.dto.*;
import com.quyenauto.auth.service.AuthService;
import com.quyenauto.common.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Đăng nhập, đăng ký, refresh token")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "Đăng nhập bằng SĐT và mật khẩu")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(authService.login(request)));
    }

    @PostMapping("/register")
    @Operation(summary = "Đăng ký tài khoản khách hàng")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.created(authService.register(request)));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Lấy access token mới từ refresh token")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(@Valid @RequestBody RefreshRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(authService.refresh(request)));
    }

    @PostMapping("/logout")
    @Operation(summary = "Đăng xuất — xoá refresh token")
    public ResponseEntity<ApiResponse<Void>> logout(Authentication auth) {
        Long userId = Long.parseLong(auth.getName());
        authService.logout(userId);
        return ResponseEntity.ok(ApiResponse.noContent());
    }

    @GetMapping("/me")
    @Operation(summary = "Lấy thông tin người dùng hiện tại")
    public ResponseEntity<ApiResponse<AuthResponse.UserInfo>> me(Authentication auth) {
        Long userId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(authService.getProfile(userId)));
    }
}

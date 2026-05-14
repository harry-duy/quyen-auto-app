package com.quyenauto.auth.controller;

import com.quyenauto.auth.dto.*;
import com.quyenauto.auth.service.AuthService;
import com.quyenauto.auth.service.OtpService;
import com.quyenauto.common.dto.ApiResponse;
import com.quyenauto.common.exception.BusinessException;
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
    private final OtpService otpService;

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

    @PutMapping("/me")
    @Operation(summary = "Cập nhật thông tin cá nhân")
    public ResponseEntity<ApiResponse<AuthResponse.UserInfo>> updateProfile(
            Authentication auth, @Valid @RequestBody UpdateProfileRequest request) {
        Long userId = Long.parseLong(auth.getName());
        return ResponseEntity.ok(ApiResponse.ok(authService.updateProfile(userId, request)));
    }

    @PostMapping("/change-password")
    @Operation(summary = "Đổi mật khẩu")
    public ResponseEntity<ApiResponse<Void>> changePassword(
            Authentication auth, @Valid @RequestBody ChangePasswordRequest request) {
        Long userId = Long.parseLong(auth.getName());
        authService.changePassword(userId, request);
        return ResponseEntity.ok(ApiResponse.noContent());
    }

    @PostMapping("/otp/send")
    @Operation(summary = "Gửi lại OTP xác minh email")
    public ResponseEntity<ApiResponse<Void>> sendOtp(Authentication auth) {
        Long userId = Long.parseLong(auth.getName());
        AuthResponse.UserInfo profile = authService.getProfile(userId);
        if (profile.getEmail() == null || profile.getEmail().isBlank()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Tài khoản chưa có email để xác minh");
        }
        if (Boolean.TRUE.equals(profile.getEmailVerified())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Email đã được xác minh trước đó");
        }
        otpService.sendEmailVerificationOtp(userId, profile.getEmail());
        return ResponseEntity.ok(ApiResponse.noContent());
    }

    @PostMapping("/otp/verify")
    @Operation(summary = "Xác minh email bằng mã OTP")
    public ResponseEntity<ApiResponse<AuthResponse.UserInfo>> verifyOtp(
            Authentication auth, @Valid @RequestBody VerifyOtpRequest request) {
        Long userId = Long.parseLong(auth.getName());
        otpService.verifyEmailOtp(userId, request.getCode());
        // Tra ve profile moi nhat (emailVerified = true)
        return ResponseEntity.ok(ApiResponse.ok(authService.getProfile(userId)));
    }
}

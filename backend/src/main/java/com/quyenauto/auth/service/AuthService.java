package com.quyenauto.auth.service;

import com.quyenauto.auth.dto.*;
import com.quyenauto.auth.entity.RefreshToken;
import com.quyenauto.auth.repository.RefreshTokenRepository;
import com.quyenauto.auth.security.JwtService;
import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.user.entity.Department;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.entity.UserRole;
import com.quyenauto.user.repository.DepartmentRepository;
import com.quyenauto.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final UserRepository userRepository;
    private final DepartmentRepository departmentRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final OtpService otpService;

    @Transactional
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByPhone(request.getPhone())
                .orElseThrow(() -> new BusinessException(HttpStatus.UNAUTHORIZED, "Số điện thoại hoặc mật khẩu không đúng"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new BusinessException(HttpStatus.UNAUTHORIZED, "Số điện thoại hoặc mật khẩu không đúng");
        }

        if (!user.getIsActive()) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "Tài khoản đã bị vô hiệu hóa");
        }

        return generateAuthResponse(user);
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new BusinessException("Số điện thoại đã được sử dụng");
        }

        if (request.getEmail() != null && userRepository.existsByEmail(request.getEmail())) {
            throw new BusinessException("Email đã được sử dụng");
        }

        boolean hasEmail = request.getEmail() != null && !request.getEmail().isBlank();

        User user = User.builder()
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .email(hasEmail ? request.getEmail() : null)
                .role(UserRole.CUSTOMER)
                .isActive(true)
                // Co email thi can xac minh; khong co email thi mac dinh da xac minh
                .emailVerified(!hasEmail)
                .build();

        user = userRepository.save(user);

        // Gui OTP neu co email (bat dong bo — loi gui mail khong anh huong dang ky)
        if (hasEmail) {
            try {
                otpService.sendEmailVerificationOtp(user.getId(), request.getEmail());
            } catch (Exception e) {
                log.warn("Could not send OTP after register for user {}: {}", user.getId(), e.getMessage());
            }
        }

        return generateAuthResponse(user);
    }

    @Transactional
    public AuthResponse refresh(RefreshRequest request) {
        if (!jwtService.validateToken(request.getRefreshToken())) {
            throw new BusinessException(HttpStatus.UNAUTHORIZED, "Refresh token không hợp lệ");
        }

        RefreshToken stored = refreshTokenRepository.findByToken(request.getRefreshToken())
                .orElseThrow(() -> new BusinessException(HttpStatus.UNAUTHORIZED, "Refresh token không tồn tại"));

        if (stored.getExpiresAt().isBefore(LocalDateTime.now())) {
            refreshTokenRepository.delete(stored);
            throw new BusinessException(HttpStatus.UNAUTHORIZED, "Refresh token đã hết hạn");
        }

        User user = stored.getUser();
        refreshTokenRepository.delete(stored);
        return generateAuthResponse(user);
    }

    @Transactional
    public void logout(Long userId) {
        refreshTokenRepository.deleteByUserId(userId);
    }

    @Transactional(readOnly = true)
    public AuthResponse.UserInfo getProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));
        return toUserInfo(user);
    }

    @Transactional
    public AuthResponse.UserInfo updateProfile(Long userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));

        if (request.getFullName() != null && !request.getFullName().isBlank()) {
            user.setFullName(request.getFullName());
        }
        if (request.getEmail() != null) {
            if (!request.getEmail().isBlank() && !request.getEmail().equals(user.getEmail())) {
                if (userRepository.existsByEmail(request.getEmail())) {
                    throw new BusinessException("Email đã được sử dụng");
                }
            }
            user.setEmail(request.getEmail().isBlank() ? null : request.getEmail());
        }
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl().isBlank() ? null : request.getAvatarUrl());
        }

        user = userRepository.save(user);
        return toUserInfo(user);
    }

    @Transactional
    public void changePassword(Long userId, ChangePasswordRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Không tìm thấy người dùng"));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new BusinessException(HttpStatus.UNAUTHORIZED, "Mật khẩu hiện tại không đúng");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    private AuthResponse generateAuthResponse(User user) {
        String accessToken = jwtService.generateAccessToken(user.getId(), user.getRole().name());
        String refreshTokenStr = jwtService.generateRefreshToken(user.getId());

        long expirationMs = jwtService.getRefreshTokenExpiration();
        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .token(refreshTokenStr)
                .expiresAt(LocalDateTime.now().plusSeconds(expirationMs / 1000))
                .build();
        refreshTokenRepository.save(refreshToken);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshTokenStr)
                .user(toUserInfo(user))
                .build();
    }

    private AuthResponse.UserInfo toUserInfo(User user) {
        String departmentName = null;
        if (user.getDepartmentId() != null) {
            departmentName = departmentRepository.findById(user.getDepartmentId())
                    .map(Department::getName).orElse(null);
        }

        return AuthResponse.UserInfo.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .email(user.getEmail())
                .avatarUrl(user.getAvatarUrl())
                .role(user.getRole().name())
                .isActive(user.getIsActive())
                .emailVerified(user.getEmailVerified())
                .departmentId(user.getDepartmentId())
                .departmentName(departmentName)
                .position(user.getPosition())
                .employeeCode(user.getEmployeeCode())
                .build();
    }
}

package com.quyenauto.auth.service;

import com.quyenauto.auth.entity.OtpCode;
import com.quyenauto.auth.repository.OtpCodeRepository;
import com.quyenauto.common.exception.BusinessException;
import com.quyenauto.common.service.EmailService;
import com.quyenauto.user.entity.User;
import com.quyenauto.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;

/**
 * Quan ly OTP xac minh email.
 * <p>
 * Quy trinh:
 * 1. Sau dang ky co email → goi {@link #sendEmailVerificationOtp(Long, String)}
 * 2. User nhap ma 6 chu so → goi {@link #verifyEmailOtp(Long, String)}
 * 3. Neu dung → user.emailVerified = true
 */
@Service
@RequiredArgsConstructor
public class OtpService {

    private static final String PURPOSE = "EMAIL_VERIFY";
    private static final int OTP_VALID_MINUTES = 5;
    private static final int MAX_ATTEMPTS = 5;
    private static final SecureRandom RANDOM = new SecureRandom();

    private final OtpCodeRepository otpCodeRepository;
    private final UserRepository userRepository;
    private final EmailService emailService;

    /**
     * Tao va gui OTP xac minh email.
     * Xoa tat ca OTP cu truoc khi tao moi (moi lan chi co 1 OTP hop le).
     *
     * @param userId id nguoi dung
     * @param email  dia chi email nhan OTP
     */
    @Transactional
    public void sendEmailVerificationOtp(Long userId, String email) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Khong tim thay nguoi dung"));

        if (Boolean.TRUE.equals(user.getEmailVerified())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "Email da duoc xac minh");
        }

        // Xoa OTP cu
        otpCodeRepository.deleteByUserIdAndPurpose(userId, PURPOSE);

        // Tao ma moi
        String code = generateCode();
        OtpCode otpCode = OtpCode.builder()
                .user(user)
                .code(code)
                .purpose(PURPOSE)
                .expiresAt(LocalDateTime.now().plusMinutes(OTP_VALID_MINUTES))
                .build();
        otpCodeRepository.save(otpCode);

        // Gui email (neu mail chua cau hinh, OTP duoc log ra console)
        emailService.sendOtpEmail(email, code);
    }

    /**
     * Xac minh ma OTP nguoi dung nhap.
     *
     * @param userId id nguoi dung (lay tu JWT trong request)
     * @param code   ma 6 chu so nguoi dung nhap
     * @throws BusinessException neu sai ma, het han, or vuot so lan thu
     */
    @Transactional
    public void verifyEmailOtp(Long userId, String code) {
        OtpCode otp = otpCodeRepository.findLatestByUserIdAndPurpose(userId, PURPOSE)
                .orElseThrow(() -> new BusinessException(HttpStatus.BAD_REQUEST,
                        "Khong tim thay ma OTP. Vui long yeu cau gui lai."));

        if (otp.getAttempts() >= MAX_ATTEMPTS) {
            throw new BusinessException(HttpStatus.TOO_MANY_REQUESTS,
                    "Qua nhieu lan nhap sai. Vui long yeu cau gui lai ma moi.");
        }

        if (otp.isExpired()) {
            throw new BusinessException(HttpStatus.BAD_REQUEST,
                    "Ma OTP da het han. Vui long yeu cau gui lai.");
        }

        if (!otp.getCode().equals(code.trim())) {
            otp.setAttempts(otp.getAttempts() + 1);
            otpCodeRepository.save(otp);
            int remaining = MAX_ATTEMPTS - otp.getAttempts();
            throw new BusinessException(HttpStatus.BAD_REQUEST,
                    "Ma OTP khong dung. Con " + remaining + " lan thu.");
        }

        // Xac minh thanh cong
        otpCodeRepository.deleteByUserIdAndPurpose(userId, PURPOSE);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(HttpStatus.NOT_FOUND, "Khong tim thay nguoi dung"));
        user.setEmailVerified(true);
        userRepository.save(user);
    }

    private String generateCode() {
        int num = 100_000 + RANDOM.nextInt(900_000);
        return String.valueOf(num);
    }
}

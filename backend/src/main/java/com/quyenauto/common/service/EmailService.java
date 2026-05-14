package com.quyenauto.common.service;

import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

/**
 * Gui email don gian qua Spring Mail.
 * - Neu MAIL_USERNAME chua duoc cau hinh, log OTP ra console thay vi gui email
 *   (phu hop cho moi truong dev khong co mail server).
 */
@Service
@RequiredArgsConstructor
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username:}")
    private String fromEmail;

    /**
     * Gui OTP xac minh email.
     *
     * @param toEmail  email nguoi nhan
     * @param otp      ma 6 chu so
     */
    public void sendOtpEmail(String toEmail, String otp) {
        if (fromEmail == null || fromEmail.isBlank()) {
            // Dev mode: in OTP ra log thay vi gui email that
            log.warn("Mail not configured — OTP for {} is: {}", toEmail, otp);
            return;
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(toEmail);
            message.setSubject("Quyen Auto — Ma xac minh email cua ban");
            message.setText(
                "Xin chao!\n\n" +
                "Ma xac minh email cua ban la:\n\n" +
                "    " + otp + "\n\n" +
                "Ma co hieu luc trong 5 phut.\n" +
                "Neu ban khong yeu cau xac minh, hay bo qua email nay.\n\n" +
                "Tran trong,\n" +
                "Doi ngu Quyen Auto"
            );
            mailSender.send(message);
            log.info("OTP email sent to {}", toEmail);
        } catch (Exception e) {
            log.error("Failed to send OTP email to {}: {}", toEmail, e.getMessage());
            // Nem exception de caller biet gui that bai
            throw new RuntimeException("Khong the gui email xac minh. Vui long thu lai sau.");
        }
    }
}

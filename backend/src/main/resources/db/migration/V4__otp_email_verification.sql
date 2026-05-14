-- V4: OTP xac minh email sau dang ky
-- email_verified = TRUE mac dinh cho tat ca user cu (da dang ky truoc tinh nang nay)
-- User moi co email se bat dau voi email_verified = FALSE cho den khi nhap OTP hop le

ALTER TABLE users
    ADD COLUMN email_verified BOOLEAN NOT NULL DEFAULT TRUE;

CREATE TABLE otp_codes (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT       NOT NULL,
    code        VARCHAR(6)   NOT NULL,
    purpose     VARCHAR(30)  NOT NULL DEFAULT 'EMAIL_VERIFY',
    attempts    INT          NOT NULL DEFAULT 0,
    expires_at  DATETIME     NOT NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_otp_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    INDEX idx_otp_user_id (user_id)
);

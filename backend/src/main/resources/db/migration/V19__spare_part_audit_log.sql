CREATE TABLE spare_part_audit_logs (
    id              BIGINT NOT NULL AUTO_INCREMENT,
    spare_part_id   BIGINT,
    part_number     VARCHAR(100),
    action          VARCHAR(20) NOT NULL,
    performed_by    VARCHAR(200),
    performed_by_id BIGINT,
    detail          TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_spal_part (spare_part_id),
    INDEX idx_spal_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

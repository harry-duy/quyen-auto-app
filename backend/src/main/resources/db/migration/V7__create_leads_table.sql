CREATE TABLE IF NOT EXISTS leads (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone       VARCHAR(20)  NOT NULL,
    name        VARCHAR(100),
    product_id  BIGINT,
    product_name VARCHAR(255),
    note        TEXT,
    is_contacted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at  DATETIME(6)
);

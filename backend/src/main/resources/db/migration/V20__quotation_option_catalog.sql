CREATE TABLE IF NOT EXISTS quotation_options (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    position VARCHAR(50) NOT NULL,
    unit VARCHAR(30) NOT NULL DEFAULT 'cai',
    default_price DECIMAL(15,2) NOT NULL DEFAULT 0,
    description TEXT NULL,
    internal_note TEXT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_quotation_options_position (position),
    INDEX idx_quotation_options_active (is_active)
);

CREATE TABLE IF NOT EXISTS quotation_selected_options (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    quotation_id BIGINT NOT NULL,
    option_id BIGINT NULL,
    name_snapshot VARCHAR(200) NOT NULL,
    position_snapshot VARCHAR(50) NOT NULL,
    unit_snapshot VARCHAR(30) NOT NULL DEFAULT 'cai',
    unit_price_snapshot DECIMAL(15,2) NOT NULL DEFAULT 0,
    quantity INT NOT NULL DEFAULT 1,
    total_price DECIMAL(15,2) NOT NULL DEFAULT 0,
    manager_override_price DECIMAL(15,2) NULL,
    note TEXT NULL,
    is_custom TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_selected_options_quotation
        FOREIGN KEY (quotation_id) REFERENCES quotations(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_selected_options_option
        FOREIGN KEY (option_id) REFERENCES quotation_options(id)
        ON DELETE SET NULL,
    INDEX idx_selected_options_quotation (quotation_id),
    INDEX idx_selected_options_position (position_snapshot)
);

ALTER TABLE quotations
    ADD COLUMN base_price DECIMAL(15,2) NOT NULL DEFAULT 0 AFTER quoted_price,
    ADD COLUMN option_total DECIMAL(15,2) NOT NULL DEFAULT 0 AFTER base_price,
    ADD COLUMN estimated_total DECIMAL(15,2) NOT NULL DEFAULT 0 AFTER option_total,
    ADD COLUMN adjustment_fee DECIMAL(15,2) NOT NULL DEFAULT 0 AFTER estimated_total,
    ADD COLUMN discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0 AFTER adjustment_fee,
    ADD COLUMN approved_total DECIMAL(15,2) NULL AFTER discount_amount,
    ADD COLUMN price_note TEXT NULL AFTER approved_total,
    ADD COLUMN technical_note TEXT NULL AFTER price_note,
    ADD COLUMN revision_note TEXT NULL AFTER technical_note;

INSERT INTO quotation_options (name, position, unit, default_price, description)
VALUES
    ('San Inox 304', 'FLOOR', 'bo', 3000000, 'Option san inox dung chung'),
    ('San nhom chong truot', 'FLOOR', 'bo', 2500000, 'Option san nhom chong truot'),
    ('Cua hong ben phu', 'DOOR', 'cai', 1500000, 'Cua hong phia phu'),
    ('Cua hong ben tai', 'DOOR', 'cai', 1500000, 'Cua hong phia tai'),
    ('Baga cabin', 'ACCESSORY', 'cai', 200000, 'Baga cabin'),
    ('Thang leo', 'ACCESSORY', 'cai', 150000, 'Thang leo'),
    ('Cum can sau', 'ACCESSORY', 'bo', 500000, 'Cum can sau'),
    ('Cum can hong', 'ACCESSORY', 'bo', 0, 'Cum can hong'),
    ('Den hong', 'LIGHT', 'cai', 200000, 'Den hong tinh theo so luong');

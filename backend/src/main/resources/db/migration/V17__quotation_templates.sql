CREATE TABLE IF NOT EXISTS quotation_templates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT NULL,
    product_id BIGINT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT NULL,
    vehicle_model VARCHAR(100) NULL,
    chassis_width INT NULL,
    box_type VARCHAR(30) NULL,
    ac_type VARCHAR(20) NULL,
    ac_model VARCHAR(100) NULL,
    specifications JSON NULL,
    base_price DECIMAL(15,2) NOT NULL DEFAULT 0,
    option_prices JSON NULL,
    manager_note TEXT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_quotation_templates_category
        FOREIGN KEY (category_id) REFERENCES product_categories(id)
        ON DELETE SET NULL,
    CONSTRAINT fk_quotation_templates_product
        FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE SET NULL
);

ALTER TABLE quotations
    ADD COLUMN quotation_template_id BIGINT NULL AFTER product_id;

ALTER TABLE quotations
    ADD CONSTRAINT fk_quotations_template
        FOREIGN KEY (quotation_template_id) REFERENCES quotation_templates(id)
        ON DELETE SET NULL;


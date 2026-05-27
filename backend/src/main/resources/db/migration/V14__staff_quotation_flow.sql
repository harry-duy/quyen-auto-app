-- V14: Hỗ trợ flow mới — NV tạo BG → Manager duyệt → NV gửi KH
-- Thêm các cột mới vào bảng quotations

ALTER TABLE quotations
    ADD COLUMN is_staff_created       BOOLEAN     NOT NULL DEFAULT FALSE  AFTER contacted_at,
    ADD COLUMN is_new_product_request BOOLEAN     NOT NULL DEFAULT FALSE  AFTER is_staff_created,
    ADD COLUMN new_product_description TEXT                                AFTER is_new_product_request,
    ADD COLUMN approved_by            BIGINT                              AFTER new_product_description,
    ADD COLUMN approved_at            TIMESTAMP                           AFTER approved_by,
    ADD COLUMN sent_at                TIMESTAMP                           AFTER approved_at;

-- FK: người duyệt (Manager)
ALTER TABLE quotations
    ADD CONSTRAINT fk_quotation_approved_by
        FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL;

-- Index để tìm BG chờ duyệt nhanh
CREATE INDEX idx_quotation_staff_created ON quotations(is_staff_created);
CREATE INDEX idx_quotation_approved_by   ON quotations(approved_by);

-- Cập nhật ENUM status — MySQL cần ALTER COLUMN
-- Thêm các giá trị mới: DRAFT, PENDING_APPROVAL, APPROVED, SENT
ALTER TABLE quotations
    MODIFY COLUMN status ENUM(
        'PENDING', 'QUOTED', 'ACCEPTED', 'REJECTED', 'EXPIRED',
        'DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'SENT'
    ) NOT NULL DEFAULT 'PENDING';

-- V15: Hỗ trợ khách vãng lai (guest customer) trong báo giá do NV tạo
-- customer_id có thể null khi là khách chưa có tài khoản

-- Cho phép customer_id null
ALTER TABLE quotations
    MODIFY COLUMN customer_id BIGINT NULL;

-- Thêm cột thông tin khách vãng lai
ALTER TABLE quotations
    ADD COLUMN guest_name  VARCHAR(100) NULL AFTER customer_id,
    ADD COLUMN guest_phone VARCHAR(20)  NULL AFTER guest_name;

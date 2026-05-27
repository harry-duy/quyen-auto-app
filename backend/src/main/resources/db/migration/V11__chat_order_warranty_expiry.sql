-- V11: Chat rooms get an optional order reference; vehicles get warranty expiry

-- chat_rooms: store the order/contract code that triggered this chat (nullable)
ALTER TABLE chat_rooms
    ADD COLUMN order_code VARCHAR(50) NULL COMMENT 'Mã hợp đồng/đơn hàng đính kèm khi khách mở chat';

-- chat_rooms: track whether a staff has claimed the room (NULL staff = waiting)
-- staff_id is already nullable in the existing schema — no change needed.

-- vehicles: link to the contract code and track warranty expiry date
ALTER TABLE vehicles
    ADD COLUMN contract_code     VARCHAR(50)  NULL COMMENT 'Mã hợp đồng mua xe',
    ADD COLUMN warranty_expiry_date DATE       NULL COMMENT 'Ngày hết hạn bảo hành';

-- Index for efficient expiry queries (scheduler, customer view)
CREATE INDEX idx_vehicles_warranty_expiry ON vehicles (warranty_expiry_date);

-- V2: Them trang thai CANCEL_REQUESTED vao don hang
-- Khi khach hang yeu cau huy, don hang chuyen sang CANCEL_REQUESTED.
-- Staff duyet -> CANCELLED, Staff tu choi -> ve lai PENDING.

ALTER TABLE orders
    MODIFY COLUMN status
        ENUM('PENDING','CONFIRMED','IN_PRODUCTION','COMPLETED','CANCELLED','CANCEL_REQUESTED')
        NOT NULL DEFAULT 'PENDING';

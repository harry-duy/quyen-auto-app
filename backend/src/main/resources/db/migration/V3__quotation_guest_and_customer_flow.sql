-- =====================================================================
-- V3: Support guest quotations + staff creates customer accounts
-- =====================================================================

-- Allow customer_id to be NULL (guest quotations have no account)
ALTER TABLE quotations MODIFY COLUMN customer_id BIGINT NULL;

-- Guest contact info (for users without accounts)
ALTER TABLE quotations ADD COLUMN guest_phone VARCHAR(15)  AFTER customer_id;
ALTER TABLE quotations ADD COLUMN guest_name  VARCHAR(100) AFTER guest_phone;

CREATE INDEX idx_quotation_guest_phone ON quotations(guest_phone);

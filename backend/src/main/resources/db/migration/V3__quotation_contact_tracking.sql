-- V3: Theo dõi việc staff đã liên hệ khách hàng
ALTER TABLE quotations
    ADD COLUMN contacted_by  BIGINT     AFTER staff_note,
    ADD COLUMN contacted_at  TIMESTAMP  AFTER contacted_by,
    ADD CONSTRAINT fk_quotation_contacted FOREIGN KEY (contacted_by)
        REFERENCES users(id) ON DELETE SET NULL;

CREATE INDEX idx_quotation_contacted ON quotations(contacted_by);

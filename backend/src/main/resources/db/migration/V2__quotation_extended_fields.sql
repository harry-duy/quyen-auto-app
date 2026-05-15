-- =====================================================================
-- V2: Add extended quotation fields + staff contact tracking
-- =====================================================================

-- ─── New spec fields from whiteboard design ─────────────────────────
ALTER TABLE quotations ADD COLUMN vehicle_brand VARCHAR(50)  AFTER note;
ALTER TABLE quotations ADD COLUMN body_type    VARCHAR(20)  AFTER vehicle_brand;
ALTER TABLE quotations ADD COLUMN body_size    VARCHAR(10)  AFTER body_type;
ALTER TABLE quotations ADD COLUMN length_cm    DOUBLE       AFTER body_size;
ALTER TABLE quotations ADD COLUMN width_cm     DOUBLE       AFTER length_cm;
ALTER TABLE quotations ADD COLUMN height_cm    DOUBLE       AFTER width_cm;
ALTER TABLE quotations ADD COLUMN options      VARCHAR(500) AFTER height_cm;

-- ─── Staff contact tracking ─────────────────────────────────────────
ALTER TABLE quotations ADD COLUMN contacted    BOOLEAN   NOT NULL DEFAULT FALSE AFTER staff_note;
ALTER TABLE quotations ADD COLUMN contacted_by BIGINT    AFTER contacted;
ALTER TABLE quotations ADD COLUMN contacted_at TIMESTAMP AFTER contacted_by;

ALTER TABLE quotations ADD CONSTRAINT fk_quotation_contacted_by
    FOREIGN KEY (contacted_by) REFERENCES users(id) ON DELETE SET NULL;

CREATE INDEX idx_quotation_contacted ON quotations(contacted);

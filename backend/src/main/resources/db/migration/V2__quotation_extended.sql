-- V2: Mở rộng bảng quotations theo mẫu báo giá thùng xe
ALTER TABLE quotations
    ADD COLUMN vehicle_model     VARCHAR(100)  AFTER cargo_type,
    ADD COLUMN quantity          INT           NOT NULL DEFAULT 1 AFTER vehicle_model,
    ADD COLUMN chassis_width     INT           AFTER quantity,
    ADD COLUMN box_code          VARCHAR(20)   AFTER chassis_width,
    ADD COLUMN box_type          VARCHAR(30)   AFTER box_code,
    ADD COLUMN ac_type           VARCHAR(20)   AFTER box_type,
    ADD COLUMN ac_model          VARCHAR(100)  AFTER ac_type,
    ADD COLUMN inner_wall_insulated BOOLEAN    AFTER ac_model,
    ADD COLUMN specifications    JSON          AFTER inner_wall_insulated;

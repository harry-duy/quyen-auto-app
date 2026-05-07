-- =====================================================================
-- Quyen Auto — Initial Database Schema
-- =====================================================================

-- ─── Departments ─────────────────────────────────────────────────────
CREATE TABLE departments (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)  NOT NULL UNIQUE,
    description VARCHAR(500),
    manager_id  BIGINT,
    is_active   BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Users ───────────────────────────────────────────────────────────
CREATE TABLE users (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100)  NOT NULL,
    phone           VARCHAR(15)   NOT NULL UNIQUE,
    email           VARCHAR(150)  UNIQUE,
    password_hash   VARCHAR(255)  NOT NULL,
    avatar_url      VARCHAR(500),
    role            ENUM('CUSTOMER','STAFF','MANAGER','ADMIN') NOT NULL DEFAULT 'CUSTOMER',
    is_active       BOOLEAN       NOT NULL DEFAULT TRUE,
    department_id   BIGINT,
    position        VARCHAR(100),
    employee_code   VARCHAR(20)   UNIQUE,
    zalo_id         VARCHAR(100)  UNIQUE,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_department FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_department ON users(department_id);
CREATE INDEX idx_users_phone ON users(phone);

-- FK department.manager_id → users.id (circular, add after users created)
ALTER TABLE departments ADD CONSTRAINT fk_dept_manager FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE SET NULL;

-- ─── Refresh Tokens ──────────────────────────────────────────────────
CREATE TABLE refresh_tokens (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT        NOT NULL,
    token       VARCHAR(500)  NOT NULL UNIQUE,
    expires_at  TIMESTAMP     NOT NULL,
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_refresh_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_refresh_token ON refresh_tokens(token);
CREATE INDEX idx_refresh_user ON refresh_tokens(user_id);

-- ─── Product Categories ──────────────────────────────────────────────
CREATE TABLE product_categories (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)  NOT NULL UNIQUE,
    description VARCHAR(500),
    image_url   VARCHAR(500),
    sort_order  INT           NOT NULL DEFAULT 0,
    is_active   BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Products ────────────────────────────────────────────────────────
CREATE TABLE products (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id     BIGINT,
    name            VARCHAR(200)    NOT NULL,
    description     TEXT,
    specifications  JSON,
    base_price      DECIMAL(15,2)   NOT NULL DEFAULT 0,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES product_categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_product_category ON products(category_id);
CREATE INDEX idx_product_active ON products(is_active);

-- ─── Product Images ──────────────────────────────────────────────────
CREATE TABLE product_images (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id  BIGINT        NOT NULL,
    image_url   VARCHAR(500)  NOT NULL,
    sort_order  INT           NOT NULL DEFAULT 0,

    CONSTRAINT fk_image_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Quotations (yêu cầu báo giá) ───────────────────────────────────
CREATE TABLE quotations (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id     BIGINT          NOT NULL,
    product_id      BIGINT,
    weight_range    VARCHAR(50),
    cargo_type      VARCHAR(100),
    note            TEXT,
    quoted_price    DECIMAL(15,2),
    status          ENUM('PENDING','QUOTED','ACCEPTED','REJECTED','EXPIRED') NOT NULL DEFAULT 'PENDING',
    staff_id        BIGINT,
    staff_note      TEXT,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_quotation_customer FOREIGN KEY (customer_id) REFERENCES users(id),
    CONSTRAINT fk_quotation_product  FOREIGN KEY (product_id)  REFERENCES products(id) ON DELETE SET NULL,
    CONSTRAINT fk_quotation_staff    FOREIGN KEY (staff_id)    REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_quotation_customer ON quotations(customer_id);
CREATE INDEX idx_quotation_status ON quotations(status);

-- ─── Orders ──────────────────────────────────────────────────────────
CREATE TABLE orders (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_code          VARCHAR(30)     NOT NULL UNIQUE,
    quotation_id        BIGINT,
    customer_id         BIGINT          NOT NULL,
    product_id          BIGINT,
    product_name        VARCHAR(200),
    total_amount        DECIMAL(15,2)   NOT NULL DEFAULT 0,
    deposit_amount      DECIMAL(15,2)   NOT NULL DEFAULT 0,
    status              ENUM('PENDING','CONFIRMED','IN_PRODUCTION','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    production_status   VARCHAR(50)     NOT NULL DEFAULT 'NOT_STARTED',
    note                TEXT,
    estimated_date      DATE,
    assigned_staff_id   BIGINT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_order_quotation FOREIGN KEY (quotation_id)    REFERENCES quotations(id) ON DELETE SET NULL,
    CONSTRAINT fk_order_customer  FOREIGN KEY (customer_id)     REFERENCES users(id),
    CONSTRAINT fk_order_product   FOREIGN KEY (product_id)      REFERENCES products(id) ON DELETE SET NULL,
    CONSTRAINT fk_order_staff     FOREIGN KEY (assigned_staff_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_order_customer ON orders(customer_id);
CREATE INDEX idx_order_status ON orders(status);
CREATE INDEX idx_order_code ON orders(order_code);

-- ─── Order Status Logs ───────────────────────────────────────────────
CREATE TABLE order_status_logs (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id    BIGINT        NOT NULL,
    status      VARCHAR(30)   NOT NULL,
    note        TEXT,
    changed_by  BIGINT,
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_log_order   FOREIGN KEY (order_id)   REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_log_user    FOREIGN KEY (changed_by)  REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_status_log_order ON order_status_logs(order_id);

-- ─── Vehicles (xe đã mua, dùng cho bảo hành) ────────────────────────
CREATE TABLE vehicles (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    owner_id        BIGINT        NOT NULL,
    product_id      BIGINT,
    plate_number    VARCHAR(20)   NOT NULL,
    chassis_number  VARCHAR(50)   NOT NULL UNIQUE,
    purchase_date   DATE          NOT NULL,
    created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_vehicle_owner   FOREIGN KEY (owner_id)   REFERENCES users(id),
    CONSTRAINT fk_vehicle_product FOREIGN KEY (product_id)  REFERENCES products(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_vehicle_owner ON vehicles(owner_id);

-- ─── Warranty Requests ───────────────────────────────────────────────
CREATE TABLE warranty_requests (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id          BIGINT        NOT NULL,
    customer_id         BIGINT        NOT NULL,
    issue_description   TEXT          NOT NULL,
    status              ENUM('PENDING','IN_PROGRESS','RESOLVED','REJECTED') NOT NULL DEFAULT 'PENDING',
    scheduled_date      DATE,
    technician_id       BIGINT,
    technician_name     VARCHAR(100),
    result              TEXT,
    created_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_warranty_vehicle   FOREIGN KEY (vehicle_id)    REFERENCES vehicles(id),
    CONSTRAINT fk_warranty_customer  FOREIGN KEY (customer_id)   REFERENCES users(id),
    CONSTRAINT fk_warranty_tech      FOREIGN KEY (technician_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_warranty_customer ON warranty_requests(customer_id);
CREATE INDEX idx_warranty_status ON warranty_requests(status);

-- ─── Warranty Logs ───────────────────────────────────────────────────
CREATE TABLE warranty_logs (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    warranty_request_id BIGINT        NOT NULL,
    action              VARCHAR(100)  NOT NULL,
    note                TEXT,
    performed_by        BIGINT,
    created_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_wlog_request FOREIGN KEY (warranty_request_id) REFERENCES warranty_requests(id) ON DELETE CASCADE,
    CONSTRAINT fk_wlog_user    FOREIGN KEY (performed_by)         REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Dealers ─────────────────────────────────────────────────────────
CREATE TABLE dealers (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(200)    NOT NULL,
    address     VARCHAR(500)    NOT NULL,
    province    VARCHAR(100)    NOT NULL,
    phone       VARCHAR(20)     NOT NULL,
    lat         DOUBLE          NOT NULL,
    lng         DOUBLE          NOT NULL,
    is_active   BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_dealer_province ON dealers(province);

-- ─── Chat Rooms ──────────────────────────────────────────────────────
CREATE TABLE chat_rooms (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT        NOT NULL,
    staff_id    BIGINT,
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_chatroom_customer FOREIGN KEY (customer_id) REFERENCES users(id),
    CONSTRAINT fk_chatroom_staff    FOREIGN KEY (staff_id)    REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY uq_room_customer_staff (customer_id, staff_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Chat Messages ───────────────────────────────────────────────────
CREATE TABLE chat_messages (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_id     BIGINT          NOT NULL,
    sender_id   BIGINT          NOT NULL,
    content     TEXT            NOT NULL,
    type        ENUM('TEXT','IMAGE','FILE') NOT NULL DEFAULT 'TEXT',
    is_read     BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_msg_room   FOREIGN KEY (room_id)   REFERENCES chat_rooms(id) ON DELETE CASCADE,
    CONSTRAINT fk_msg_sender FOREIGN KEY (sender_id)  REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_msg_room ON chat_messages(room_id);
CREATE INDEX idx_msg_created ON chat_messages(room_id, created_at);

-- ─── Notifications ───────────────────────────────────────────────────
CREATE TABLE notifications (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT          NOT NULL,
    title       VARCHAR(200)    NOT NULL,
    body        TEXT            NOT NULL,
    type        VARCHAR(50)     NOT NULL DEFAULT 'GENERAL',
    ref_id      VARCHAR(50),
    is_read     BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_notif_user ON notifications(user_id);
CREATE INDEX idx_notif_unread ON notifications(user_id, is_read);

-- ─── FCM Tokens ──────────────────────────────────────────────────────
CREATE TABLE fcm_tokens (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT        NOT NULL,
    token       VARCHAR(500)  NOT NULL,
    device_type VARCHAR(20),
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fcm_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uq_fcm_token (token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Seed: Default Admin ─────────────────────────────────────────────
INSERT INTO departments (name, description) VALUES ('Ban Giám Đốc', 'Ban lãnh đạo Quyen Auto');

INSERT INTO users (full_name, phone, password_hash, role, department_id, position, employee_code)
VALUES ('Admin', '0908109929', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN', 1, 'Giám đốc', 'QA001');
-- Default password: admin123 (BCrypt hash)

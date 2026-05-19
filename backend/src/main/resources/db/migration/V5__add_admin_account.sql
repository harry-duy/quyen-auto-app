-- =====================================================================
-- Thêm tài khoản ADMIN hệ thống
-- SĐT: 0909000000  |  Mật khẩu: admin123
-- =====================================================================

INSERT INTO users (full_name, phone, password_hash, role, position, employee_code, is_active, created_at, updated_at)
SELECT 'Nguyễn Quản Trị', '0909000000',
       '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
       'ADMIN', 'Quản trị viên hệ thống', 'AD001', true, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM users WHERE phone = '0909000000');

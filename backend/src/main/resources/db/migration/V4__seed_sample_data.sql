-- =====================================================================
-- Quyen Auto — Sample / Test Data
-- Tất cả tài khoản dùng password: admin123
-- =====================================================================

-- ─── Hash dùng chung cho password "admin123" ─────────────────────────
-- $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy

-- ─── Departments ─────────────────────────────────────────────────────
INSERT INTO departments (name, description) VALUES
    ('Kinh Doanh',              'Bộ phận tiếp thị, tư vấn và bán hàng'),
    ('Kỹ Thuật Sản Xuất',       'Sản xuất và lắp ráp thùng xe'),
    ('Chăm Sóc Khách Hàng',     'Hỗ trợ, bảo hành và after-sales'),
    ('Kế Toán - Tài Chính',     'Quản lý tài chính và kế toán');

-- ─── Staff & Manager accounts ────────────────────────────────────────

-- Tài khoản Tuần — MANAGER (Trưởng phòng Kinh Doanh)
-- SĐT: 0909000001  |  Mật khẩu: admin123
INSERT INTO users (full_name, phone, password_hash, role, department_id, position, employee_code)
SELECT 'Nguyễn Đức Tuần', '0909000001',
       '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
       'MANAGER',
       (SELECT id FROM departments WHERE name = 'Kinh Doanh'),
       'Trưởng phòng Kinh Doanh', 'QA002';

-- Nhân viên Kinh Doanh
INSERT INTO users (full_name, phone, password_hash, role, department_id, position, employee_code)
SELECT 'Nguyễn Văn Hùng', '0909000002',
       '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
       'STAFF',
       (SELECT id FROM departments WHERE name = 'Kinh Doanh'),
       'Nhân viên Kinh Doanh', 'QA003';

INSERT INTO users (full_name, phone, password_hash, role, department_id, position, employee_code)
SELECT 'Phạm Thị Lan', '0909000003',
       '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
       'STAFF',
       (SELECT id FROM departments WHERE name = 'Kinh Doanh'),
       'Nhân viên Kinh Doanh', 'QA004';

-- Nhân viên Kỹ Thuật
INSERT INTO users (full_name, phone, password_hash, role, department_id, position, employee_code)
SELECT 'Lê Quốc Bảo', '0909000004',
       '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
       'STAFF',
       (SELECT id FROM departments WHERE name = 'Kỹ Thuật Sản Xuất'),
       'Kỹ thuật viên', 'QA005';

INSERT INTO users (full_name, phone, password_hash, role, department_id, position, employee_code)
SELECT 'Trần Minh Đức', '0909000005',
       '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
       'STAFF',
       (SELECT id FROM departments WHERE name = 'Kỹ Thuật Sản Xuất'),
       'Kỹ thuật viên trưởng', 'QA006';

-- Nhân viên CSKH
INSERT INTO users (full_name, phone, password_hash, role, department_id, position, employee_code)
SELECT 'Võ Thị Mai', '0909000006',
       '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
       'STAFF',
       (SELECT id FROM departments WHERE name = 'Chăm Sóc Khách Hàng'),
       'Nhân viên CSKH', 'QA007';

-- Cập nhật manager_id cho phòng Kinh Doanh
UPDATE departments
SET manager_id = (SELECT id FROM users WHERE phone = '0909000001')
WHERE name = 'Kinh Doanh';

-- ─── Khách hàng (CUSTOMER) ────────────────────────────────────────────
INSERT INTO users (full_name, phone, email, password_hash, role) VALUES
    ('Nguyễn Thành Long',  '0901111001', 'long.nguyen@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'CUSTOMER'),
    ('Trần Minh Khoa',     '0901111002', 'khoa.tran@gmail.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'CUSTOMER'),
    ('Lê Thị Hoa',         '0901111003', 'hoa.le@yahoo.com',
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'CUSTOMER'),
    ('Phạm Văn Tài',       '0901111004', NULL,
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'CUSTOMER'),
    ('Hoàng Thị Ngọc',     '0901111005', NULL,
     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'CUSTOMER');

-- ─── Product Categories ───────────────────────────────────────────────
INSERT INTO product_categories (name, description, sort_order) VALUES
    ('Thùng Bảo Ôn',   'Thùng xe tải cách nhiệt bảo ôn, giữ nhiệt hàng hóa',  1),
    ('Thùng Đông Lạnh', 'Thùng xe lắp máy lạnh chuyên chở thực phẩm đông lạnh', 2),
    ('Thùng Composite', 'Thùng vật liệu composite nhẹ, bền, chống ăn mòn',       3);

-- ─── Products ─────────────────────────────────────────────────────────
INSERT INTO products (category_id, name, description, base_price) VALUES
    -- Thùng Bảo Ôn
    ((SELECT id FROM product_categories WHERE name = 'Thùng Bảo Ôn'),
     'Thùng Bảo Ôn 3.5 Tấn',
     'Thùng bảo ôn tiêu chuẩn cho xe tải 3.5 tấn, foam PU 75mm, inox 304',
     85000000),
    ((SELECT id FROM product_categories WHERE name = 'Thùng Bảo Ôn'),
     'Thùng Bảo Ôn 5 Tấn',
     'Thùng bảo ôn khổ lớn cho xe tải 5 tấn, foam PU 100mm',
     110000000),
    -- Thùng Đông Lạnh
    ((SELECT id FROM product_categories WHERE name = 'Thùng Đông Lạnh'),
     'Thùng Đông Lạnh 2.5 Tấn + Máy Lạnh Carrier',
     'Thùng đông lạnh kèm máy lạnh Carrier Vector 1550, giữ -20°C',
     195000000),
    ((SELECT id FROM product_categories WHERE name = 'Thùng Đông Lạnh'),
     'Thùng Đông Lạnh 3.5 Tấn + Máy Lạnh Thermo King',
     'Thùng đông lạnh kèm máy lạnh Thermo King V-300MAX, đạt -25°C',
     245000000),
    -- Thùng Composite
    ((SELECT id FROM product_categories WHERE name = 'Thùng Composite'),
     'Thùng Composite 1.5 Tấn',
     'Thùng composite siêu nhẹ cho xe tải nhẹ 1.5 tấn',
     55000000);

-- ─── Dealers (đại lý) ─────────────────────────────────────────────────
INSERT INTO dealers (name, address, province, phone, lat, lng) VALUES
    ('Quyen Auto HCM',       '123 Quang Trung, Gò Vấp, TP.HCM',                    'TP.HCM',    '0283000001',  10.8373,  106.6780),
    ('Quyen Auto Bình Dương','456 ĐT743, An Phú, Thuận An, Bình Dương',             'Bình Dương','0274000001',  10.9378,  106.7114),
    ('Quyen Auto Đồng Nai',  '789 Nguyễn Ái Quốc, Biên Hòa, Đồng Nai',            'Đồng Nai',  '0251000001',  10.9573,  106.8429),
    ('Quyen Auto Long An',   '321 QL1A, Tân An, Long An',                            'Long An',   '0272000001',  10.5320,  106.4118),
    ('Quyen Auto Cần Thơ',   '654 3 Tháng 2, Ninh Kiều, Cần Thơ',                  'Cần Thơ',   '0292000001',  10.0452,  105.7469);

-- ─── Quotations (yêu cầu báo giá) ────────────────────────────────────

-- PENDING — chưa xử lý
INSERT INTO quotations (customer_id, product_id, vehicle_model, weight_range, cargo_type, note, status)
SELECT
    (SELECT id FROM users WHERE phone = '0901111001'),
    (SELECT id FROM products WHERE name LIKE '%3.5 Tấn%' AND category_id = (SELECT id FROM product_categories WHERE name = 'Thùng Bảo Ôn')),
    'Isuzu NQR 75LE', '3.5 tấn', 'Thực phẩm tươi sống',
    'Cần thùng inox bên trong, có đèn led', 'PENDING';

INSERT INTO quotations (customer_id, product_id, vehicle_model, weight_range, cargo_type, note, status)
SELECT
    (SELECT id FROM users WHERE phone = '0901111002'),
    (SELECT id FROM products WHERE name LIKE '%Carrier%'),
    'Hino 500 FC9J', '5 tấn', 'Thủy sản đông lạnh',
    'Cần đạt -18°C, có 2 ngăn phân loại', 'PENDING';

INSERT INTO quotations (customer_id, product_id, vehicle_model, weight_range, cargo_type, note, status)
SELECT
    (SELECT id FROM users WHERE phone = '0901111003'),
    (SELECT id FROM products WHERE name LIKE '%Composite%'),
    'Kia K200', '1.5 tấn', 'Bánh kẹo, thực phẩm khô',
    'Giao hàng siêu thị, cần thùng nhẹ tiết kiệm nhiên liệu', 'PENDING';

-- QUOTED — đã báo giá
INSERT INTO quotations (customer_id, product_id, vehicle_model, weight_range, cargo_type, note,
                        quoted_price, status, staff_id, staff_note,
                        contacted_by, contacted_at)
SELECT
    (SELECT id FROM users WHERE phone = '0901111004'),
    (SELECT id FROM products WHERE name LIKE '%5 Tấn%' AND category_id = (SELECT id FROM product_categories WHERE name = 'Thùng Bảo Ôn')),
    'Hyundai HD72', '5 tấn', 'Rau củ quả',
    'Cần thùng 2 ngăn có lỗ thông hơi',
    108000000, 'QUOTED',
    (SELECT id FROM users WHERE phone = '0909000002'),
    'Đã tư vấn thùng 2 ngăn foam 75mm. Giá bao gồm lắp đặt và bảo hành 2 năm.',
    (SELECT id FROM users WHERE phone = '0909000001'),
    DATE_SUB(NOW(), INTERVAL 1 DAY);

-- ACCEPTED — khách đồng ý
INSERT INTO quotations (customer_id, product_id, vehicle_model, weight_range, cargo_type,
                        quoted_price, status, staff_id, staff_note,
                        contacted_by, contacted_at)
SELECT
    (SELECT id FROM users WHERE phone = '0901111005'),
    (SELECT id FROM products WHERE name LIKE '%Thermo King%'),
    'JAC N900', '7 tấn', 'Thực phẩm đông lạnh',
    242000000, 'ACCEPTED',
    (SELECT id FROM users WHERE phone = '0909000001'),
    'KH đã xác nhận đặt cọc 30%.',
    (SELECT id FROM users WHERE phone = '0909000001'),
    DATE_SUB(NOW(), INTERVAL 3 DAY);

-- ─── Orders ───────────────────────────────────────────────────────────

-- Đơn từ quotation ACCEPTED
INSERT INTO orders (order_code, quotation_id, customer_id, product_id, product_name,
                    total_amount, deposit_amount, status, production_status,
                    note, estimated_date, assigned_staff_id)
SELECT
    'QA-2025-001',
    (SELECT id FROM quotations WHERE status = 'ACCEPTED'),
    (SELECT id FROM users WHERE phone = '0901111005'),
    (SELECT id FROM products WHERE name LIKE '%Thermo King%'),
    'Thùng Đông Lạnh 3.5 Tấn + Máy Lạnh Thermo King',
    242000000, 72600000, 'CONFIRMED', 'IN_PROGRESS',
    'Đã đặt cọc 30%. Dự kiến hoàn thành 15 ngày.',
    DATE_ADD(CURDATE(), INTERVAL 12 DAY),
    (SELECT id FROM users WHERE phone = '0909000004');

-- Đơn đang sản xuất
INSERT INTO orders (order_code, customer_id, product_id, product_name,
                    total_amount, deposit_amount, status, production_status,
                    estimated_date, assigned_staff_id)
SELECT
    'QA-2025-002',
    (SELECT id FROM users WHERE phone = '0901111001'),
    (SELECT id FROM products WHERE name LIKE '%3.5 Tấn%' AND category_id = (SELECT id FROM product_categories WHERE name = 'Thùng Bảo Ôn')),
    'Thùng Bảo Ôn 3.5 Tấn',
    87000000, 26100000, 'IN_PRODUCTION', 'IN_PROGRESS',
    DATE_ADD(CURDATE(), INTERVAL 7 DAY),
    (SELECT id FROM users WHERE phone = '0909000005');

-- Đơn hoàn thành
INSERT INTO orders (order_code, customer_id, product_id, product_name,
                    total_amount, deposit_amount, status, production_status,
                    estimated_date, assigned_staff_id)
SELECT
    'QA-2025-003',
    (SELECT id FROM users WHERE phone = '0901111002'),
    (SELECT id FROM products WHERE name LIKE '%Carrier%'),
    'Thùng Đông Lạnh 2.5 Tấn + Máy Lạnh Carrier',
    193000000, 193000000, 'COMPLETED', 'COMPLETED',
    DATE_SUB(CURDATE(), INTERVAL 5 DAY),
    (SELECT id FROM users WHERE phone = '0909000004');

-- ─── Order Status Logs ────────────────────────────────────────────────
INSERT INTO order_status_logs (order_id, status, note, changed_by)
SELECT id, 'CONFIRMED',
       'Khách hàng xác nhận đặt cọc 30%. Bắt đầu lên kế hoạch sản xuất.',
       (SELECT id FROM users WHERE phone = '0909000001')
FROM orders WHERE order_code = 'QA-2025-001';

INSERT INTO order_status_logs (order_id, status, note, changed_by)
SELECT id, 'IN_PRODUCTION',
       'Bắt đầu sản xuất thùng xe.',
       (SELECT id FROM users WHERE phone = '0909000004')
FROM orders WHERE order_code = 'QA-2025-001';

INSERT INTO order_status_logs (order_id, status, note, changed_by)
SELECT id, 'COMPLETED',
       'Giao xe và lắp đặt thành công. Khách hàng nghiệm thu đạt yêu cầu.',
       (SELECT id FROM users WHERE phone = '0909000004')
FROM orders WHERE order_code = 'QA-2025-003';

-- ─── Vehicles ─────────────────────────────────────────────────────────
INSERT INTO vehicles (owner_id, product_id, plate_number, chassis_number, purchase_date)
SELECT
    (SELECT id FROM users WHERE phone = '0901111002'),
    (SELECT id FROM products WHERE name LIKE '%Carrier%'),
    '51C-123.45', 'VIN2025HINO001',
    DATE_SUB(CURDATE(), INTERVAL 5 DAY);

INSERT INTO vehicles (owner_id, plate_number, chassis_number, purchase_date)
SELECT
    (SELECT id FROM users WHERE phone = '0901111001'),
    '51G-456.78', 'VIN2024ISUZU002',
    DATE_SUB(CURDATE(), INTERVAL 180 DAY);

-- ─── Warranty Requests ────────────────────────────────────────────────
INSERT INTO warranty_requests (vehicle_id, customer_id, issue_description, status, scheduled_date, technician_id)
SELECT
    (SELECT id FROM vehicles WHERE chassis_number = 'VIN2024ISUZU002'),
    (SELECT id FROM users WHERE phone = '0901111001'),
    'Lớp foam bên hông phải xuất hiện vết nứt nhỏ sau 6 tháng sử dụng. Cần kiểm tra và xử lý.',
    'PENDING',
    DATE_ADD(CURDATE(), INTERVAL 3 DAY),
    (SELECT id FROM users WHERE phone = '0909000004');

-- ─── Notifications mẫu ────────────────────────────────────────────────
INSERT INTO notifications (user_id, title, body, type, ref_id, is_read)
SELECT
    (SELECT id FROM users WHERE phone = '0909000001'),
    'Báo giá mới từ khách hàng',
    'Nguyễn Thành Long vừa gửi yêu cầu báo giá thùng bảo ôn 3.5 tấn.',
    'QUOTATION_NEW', NULL, FALSE;

INSERT INTO notifications (user_id, title, body, type, ref_id, is_read)
SELECT
    (SELECT id FROM users WHERE phone = '0909000001'),
    'Khách hàng chấp nhận báo giá',
    'Hoàng Thị Ngọc đã xác nhận đồng ý báo giá đơn QA-2025-001.',
    'ORDER_STATUS', NULL, TRUE;

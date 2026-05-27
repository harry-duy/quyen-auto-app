-- =====================================================================
-- V12: Dữ liệu mẫu test chức năng Chat & Warranty
-- Mật khẩu tất cả tài khoản: admin123
-- =====================================================================

-- ─── 1. Cập nhật xe hiện có thêm contract_code + warranty_expiry_date ─

-- VIN2024ISUZU002 (khách 0901111001 — Long): hết hạn bảo hành
UPDATE vehicles
SET contract_code        = 'HD-2024-0042',
    warranty_expiry_date = DATE_SUB(CURDATE(), INTERVAL 15 DAY)   -- đã hết hạn 15 ngày
WHERE chassis_number = 'VIN2024ISUZU002';

-- VIN2025HINO001 (khách 0901111002 — Khoa): còn bảo hành nhiều
UPDATE vehicles
SET contract_code        = 'HD-2025-0018',
    warranty_expiry_date = DATE_ADD(CURDATE(), INTERVAL 180 DAY)  -- còn 6 tháng
WHERE chassis_number = 'VIN2025HINO001';

-- ─── 2. Thêm xe mới cho các khách hàng ───────────────────────────────

-- Xe cho Long (0901111001): sắp hết hạn (25 ngày nữa)
INSERT INTO vehicles (owner_id, product_id, plate_number, chassis_number,
                      purchase_date, contract_code, warranty_expiry_date)
SELECT
    (SELECT id FROM users WHERE phone = '0901111001'),
    (SELECT id FROM products WHERE name LIKE '%Bảo Ôn 3.5%' LIMIT 1),
    '51H-789.00', 'VIN2024HINO003',
    DATE_SUB(CURDATE(), INTERVAL 335 DAY),
    'HD-2024-0055',
    DATE_ADD(CURDATE(), INTERVAL 25 DAY);   -- sắp hết hạn

-- Xe cho Khoa (0901111002): không có bảo hành (mua cũ)
INSERT INTO vehicles (owner_id, plate_number, chassis_number, purchase_date)
SELECT
    (SELECT id FROM users WHERE phone = '0901111002'),
    '50K-321.11', 'VIN2022MITSU010',
    DATE_SUB(CURDATE(), INTERVAL 730 DAY);

-- Xe cho khách Hoa (0901111003): đang còn bảo hành dài
INSERT INTO vehicles (owner_id, product_id, plate_number, chassis_number,
                      purchase_date, contract_code, warranty_expiry_date)
SELECT
    (SELECT id FROM users WHERE phone = '0901111003'),
    (SELECT id FROM products WHERE name LIKE '%Composite%' LIMIT 1),
    '51A-456.77', 'VIN2025KIA007',
    DATE_SUB(CURDATE(), INTERVAL 10 DAY),
    'HD-2025-0031',
    DATE_ADD(CURDATE(), INTERVAL 355 DAY);  -- gần 1 năm còn bảo hành

-- Xe cho khách Tài (0901111004): hết hạn hôm nay
INSERT INTO vehicles (owner_id, plate_number, chassis_number,
                      purchase_date, contract_code, warranty_expiry_date)
SELECT
    (SELECT id FROM users WHERE phone = '0901111004'),
    '79C-111.22', 'VIN2024JAC004',
    DATE_SUB(CURDATE(), INTERVAL 365 DAY),
    'HD-2024-0010',
    CURDATE();                              -- hết hạn đúng hôm nay

-- ─── 3. Yêu cầu bảo hành bổ sung ─────────────────────────────────────

-- BH cho VIN2025HINO001 (Khoa) — đang xử lý, đã phân công KTV
INSERT INTO warranty_requests
    (vehicle_id, customer_id, issue_description, status, scheduled_date, technician_id, technician_name)
SELECT
    (SELECT id FROM vehicles WHERE chassis_number = 'VIN2025HINO001'),
    (SELECT id FROM users WHERE phone = '0901111002'),
    'Cửa hông bên trái bị lỏng bản lề, đóng không kín. Nghe tiếng kêu khi di chuyển tốc độ cao.',
    'IN_PROGRESS',
    DATE_ADD(CURDATE(), INTERVAL 2 DAY),
    (SELECT id FROM users WHERE phone = '0909000004'),
    'Lê Quốc Bảo';

-- BH cho VIN2025KIA007 (Hoa) — đã xử lý xong
INSERT INTO warranty_requests
    (vehicle_id, customer_id, issue_description, status, technician_id, technician_name, result)
SELECT
    (SELECT id FROM vehicles WHERE chassis_number = 'VIN2025KIA007'),
    (SELECT id FROM users WHERE phone = '0901111003'),
    'Lớp sơn mặt ngoài thùng bị bong tróc ở vị trí góc trái phía trước.',
    'RESOLVED',
    (SELECT id FROM users WHERE phone = '0909000005'),
    'Trần Minh Đức',
    CONCAT('Đã sơn lại và xử lý chống rỉ. Hoàn thành ngày ', CURDATE());

-- BH cho VIN2024ISUZU002 (Long) — đã có sẵn, thêm log
-- (warranty request này đã có trong V4, chỉ thêm log bên dưới)

-- ─── 4. Warranty Logs ─────────────────────────────────────────────────

-- Log cho yêu cầu PENDING (VIN2024ISUZU002 — Long)
INSERT INTO warranty_logs (warranty_request_id, action, note, performed_by)
SELECT
    wr.id,
    'Tiếp nhận yêu cầu',
    'Nhân viên CSKH đã xác nhận nhận được yêu cầu bảo hành. Sẽ phân công kỹ thuật viên trong 24h.',
    (SELECT id FROM users WHERE phone = '0909000006')
FROM warranty_requests wr
WHERE wr.vehicle_id = (SELECT id FROM vehicles WHERE chassis_number = 'VIN2024ISUZU002')
  AND wr.status = 'PENDING'
LIMIT 1;

-- Log cho yêu cầu IN_PROGRESS (VIN2025HINO001 — Khoa)
INSERT INTO warranty_logs (warranty_request_id, action, note, performed_by)
SELECT
    wr.id,
    'Tiếp nhận yêu cầu',
    'Đã ghi nhận yêu cầu bảo hành.',
    (SELECT id FROM users WHERE phone = '0909000006')
FROM warranty_requests wr
WHERE wr.vehicle_id = (SELECT id FROM vehicles WHERE chassis_number = 'VIN2025HINO001')
LIMIT 1;

INSERT INTO warranty_logs (warranty_request_id, action, note, performed_by)
SELECT
    wr.id,
    'Phân công kỹ thuật viên',
    'Phân công cho KTV Lê Quốc Bảo. Lịch hẹn sửa chữa tại xưởng Gò Vấp.',
    (SELECT id FROM users WHERE phone = '0909000001')
FROM warranty_requests wr
WHERE wr.vehicle_id = (SELECT id FROM vehicles WHERE chassis_number = 'VIN2025HINO001')
LIMIT 1;

-- Log cho yêu cầu RESOLVED (VIN2025KIA007 — Hoa)
INSERT INTO warranty_logs (warranty_request_id, action, note, performed_by)
SELECT
    wr.id,
    'Tiếp nhận yêu cầu',
    'Khách hàng gửi ảnh minh chứng qua zalo.',
    (SELECT id FROM users WHERE phone = '0909000006')
FROM warranty_requests wr
WHERE wr.vehicle_id = (SELECT id FROM vehicles WHERE chassis_number = 'VIN2025KIA007')
LIMIT 1;

INSERT INTO warranty_logs (warranty_request_id, action, note, performed_by)
SELECT
    wr.id,
    'Bắt đầu xử lý',
    'KTV Trần Minh Đức đã đến tận nơi kiểm tra và tiến hành sơn lại.',
    (SELECT id FROM users WHERE phone = '0909000005')
FROM warranty_requests wr
WHERE wr.vehicle_id = (SELECT id FROM vehicles WHERE chassis_number = 'VIN2025KIA007')
LIMIT 1;

INSERT INTO warranty_logs (warranty_request_id, action, note, performed_by)
SELECT
    wr.id,
    'Hoàn thành bảo hành',
    'Sơn lại hoàn chỉnh, khách hàng đã kiểm tra và xác nhận đạt yêu cầu.',
    (SELECT id FROM users WHERE phone = '0909000005')
FROM warranty_requests wr
WHERE wr.vehicle_id = (SELECT id FROM vehicles WHERE chassis_number = 'VIN2025KIA007')
LIMIT 1;

-- ─── 5. Chat Rooms & Messages ─────────────────────────────────────────

-- Room 1: Long (0901111001) đang chat với staff Hùng (0909000002) — đã tiếp nhận
INSERT INTO chat_rooms (customer_id, staff_id, order_code)
SELECT
    (SELECT id FROM users WHERE phone = '0901111001'),
    (SELECT id FROM users WHERE phone = '0909000002'),
    'QA-2025-002';

-- Tin nhắn trong room 1
INSERT INTO chat_messages (room_id, sender_id, content, is_read)
SELECT
    (SELECT cr.id FROM chat_rooms cr
     JOIN users cu ON cu.id = cr.customer_id
     JOIN users su ON su.id = cr.staff_id
     WHERE cu.phone = '0901111001' AND su.phone = '0909000002'),
    (SELECT id FROM users WHERE phone = '0901111001'),
    'Chào anh/chị, tôi muốn hỏi về tiến độ đơn hàng QA-2025-002 ạ.',
    TRUE;

INSERT INTO chat_messages (room_id, sender_id, content, is_read)
SELECT
    (SELECT cr.id FROM chat_rooms cr
     JOIN users cu ON cu.id = cr.customer_id
     JOIN users su ON su.id = cr.staff_id
     WHERE cu.phone = '0901111001' AND su.phone = '0909000002'),
    (SELECT id FROM users WHERE phone = '0909000002'),
    'Chào anh Long! Đơn hàng của anh đang trong giai đoạn sản xuất, dự kiến hoàn thành sau 7 ngày nữa ạ.',
    TRUE;

INSERT INTO chat_messages (room_id, sender_id, content, is_read)
SELECT
    (SELECT cr.id FROM chat_rooms cr
     JOIN users cu ON cu.id = cr.customer_id
     JOIN users su ON su.id = cr.staff_id
     WHERE cu.phone = '0901111001' AND su.phone = '0909000002'),
    (SELECT id FROM users WHERE phone = '0901111001'),
    'Cảm ơn anh! Cho tôi hỏi thêm là thùng đã lắp foam chưa ạ?',
    TRUE;

INSERT INTO chat_messages (room_id, sender_id, content, is_read)
SELECT
    (SELECT cr.id FROM chat_rooms cr
     JOIN users cu ON cu.id = cr.customer_id
     JOIN users su ON su.id = cr.staff_id
     WHERE cu.phone = '0901111001' AND su.phone = '0909000002'),
    (SELECT id FROM users WHERE phone = '0909000002'),
    'Rồi anh ơi, foam PU 75mm đã lắp xong, đang tiến hành gắn inox bên trong và hệ thống làm lạnh.',
    FALSE;

-- Room 2: Khoa (0901111002) có room đang CHỜ (staff_id = NULL) — test "Tiếp nhận"
INSERT INTO chat_rooms (customer_id, staff_id, order_code)
SELECT
    (SELECT id FROM users WHERE phone = '0901111002'),
    NULL,
    'QA-2025-003';

INSERT INTO chat_messages (room_id, sender_id, content, is_read)
SELECT
    (SELECT cr.id FROM chat_rooms cr
     WHERE cr.customer_id = (SELECT id FROM users WHERE phone = '0901111002')
       AND cr.staff_id IS NULL
     LIMIT 1),
    (SELECT id FROM users WHERE phone = '0901111002'),
    'Xin chào! Tôi muốn hỏi về thông tin bảo hành cho xe đông lạnh đã mua.',
    FALSE;

-- Room 3: Hoa (0901111003) chat với staff Lan (0909000003)
INSERT INTO chat_rooms (customer_id, staff_id)
SELECT
    (SELECT id FROM users WHERE phone = '0901111003'),
    (SELECT id FROM users WHERE phone = '0909000003');

INSERT INTO chat_messages (room_id, sender_id, content, is_read)
SELECT
    (SELECT cr.id FROM chat_rooms cr
     JOIN users cu ON cu.id = cr.customer_id
     JOIN users su ON su.id = cr.staff_id
     WHERE cu.phone = '0901111003' AND su.phone = '0909000003'),
    (SELECT id FROM users WHERE phone = '0901111003'),
    'Chị ơi, cho tôi hỏi về giá thùng composite 1.5 tấn cho xe Kia K200 ạ.',
    TRUE;

INSERT INTO chat_messages (room_id, sender_id, content, is_read)
SELECT
    (SELECT cr.id FROM chat_rooms cr
     JOIN users cu ON cu.id = cr.customer_id
     JOIN users su ON su.id = cr.staff_id
     WHERE cu.phone = '0901111003' AND su.phone = '0909000003'),
    (SELECT id FROM users WHERE phone = '0909000003'),
    'Chào chị! Thùng composite 1.5 tấn hiện tại giá từ 55 triệu, bao gồm lắp đặt và bảo hành 1 năm. Chị muốn tư vấn thêm không ạ?',
    FALSE;

-- ─── 6. Notifications bổ sung ─────────────────────────────────────────

-- Thông báo bảo hành sắp hết hạn cho Long
INSERT INTO notifications (user_id, title, body, type, ref_id, is_read)
SELECT
    (SELECT id FROM users WHERE phone = '0901111001'),
    'Bảo hành sắp hết hạn',
    'Xe 51H-789.00 (HD-2024-0055) sẽ hết hạn bảo hành sau 25 ngày. Liên hệ Quyen Auto để gia hạn.',
    'WARRANTY_EXPIRY',
    (SELECT id FROM vehicles WHERE chassis_number = 'VIN2024HINO003'),
    FALSE;

-- Thông báo chat mới cho staff
INSERT INTO notifications (user_id, title, body, type, is_read)
SELECT
    (SELECT id FROM users WHERE phone = '0909000002'),
    'Tin nhắn mới từ khách hàng',
    'Nguyễn Thành Long hỏi về tiến độ đơn QA-2025-002.',
    'CHAT_MESSAGE',
    FALSE;

INSERT INTO notifications (user_id, title, body, type, is_read)
SELECT
    (SELECT id FROM users WHERE phone = '0909000001'),
    'Có khách hàng đang chờ tư vấn',
    'Trần Minh Khoa vừa gửi tin nhắn và đang chờ staff tiếp nhận.',
    'CHAT_WAITING',
    FALSE;

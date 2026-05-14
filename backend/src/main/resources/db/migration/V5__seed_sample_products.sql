-- ─── V5: Seed Sample Product Categories & Products ──────────────────────────

INSERT INTO product_categories (name, description, sort_order, is_active) VALUES
  ('Tải lạnh',  'Xe tải thùng đông lạnh, bảo quản thực phẩm tươi sống', 1, TRUE),
  ('Bảo ôn',    'Xe tải thùng bảo ôn, giữ nhiệt độ ổn định',             2, TRUE),
  ('Tải kín',   'Xe tải thùng kín bảo vệ hàng hóa khỏi thời tiết',       3, TRUE),
  ('Thiết kế',  'Xe tải thùng thiết kế theo yêu cầu khách hàng',          4, TRUE);

INSERT INTO products (category_id, name, description, specifications, base_price, is_active) VALUES
  (1, 'Xe tải lạnh Hyundai HD65',
   'Xe tải thùng đông lạnh Hyundai HD65 2.5 tấn, phù hợp vận chuyển thực phẩm, hải sản',
   JSON_OBJECT(
     'weightCapacity', '2.5 tấn',
     'enginePower', '130 HP',
     'fuelType', 'Diesel',
     'dimensions', '6.0m x 2.2m x 2.3m',
     'refrigerationRange', '-20°C đến +5°C'
   ),
   450000000, TRUE),

  (1, 'Xe tải lạnh Isuzu NMR 85H',
   'Xe tải thùng đông lạnh Isuzu NMR 85H 1.9 tấn, tiết kiệm nhiên liệu, vận hành linh hoạt',
   JSON_OBJECT(
     'weightCapacity', '1.9 tấn',
     'enginePower', '110 HP',
     'fuelType', 'Diesel',
     'dimensions', '5.2m x 2.0m x 2.1m',
     'refrigerationRange', '-18°C đến +5°C'
   ),
   380000000, TRUE),

  (2, 'Xe tải bảo ôn Thaco Ollin 500',
   'Xe tải thùng bảo ôn Thaco Ollin 500 5 tấn, cách nhiệt tốt, phù hợp vận chuyển hàng đông lạnh',
   JSON_OBJECT(
     'weightCapacity', '5 tấn',
     'enginePower', '150 HP',
     'fuelType', 'Diesel',
     'dimensions', '7.4m x 2.3m x 2.5m',
     'insulationThickness', '75mm'
   ),
   620000000, TRUE),

  (3, 'Xe tải kín Mitsubishi Fuso Canter',
   'Xe tải thùng kín Mitsubishi Fuso Canter 3.5 tấn, bền bỉ, đa dụng',
   JSON_OBJECT(
     'weightCapacity', '3.5 tấn',
     'enginePower', '136 HP',
     'fuelType', 'Diesel',
     'dimensions', '6.8m x 2.2m x 2.4m',
     'bodyMaterial', 'Inox + nhôm cao cấp'
   ),
   520000000, TRUE),

  (4, 'Xe tải thùng thiết kế theo yêu cầu',
   'Thiết kế và lắp ráp thùng xe theo yêu cầu riêng của khách hàng, đảm bảo tiêu chuẩn kỹ thuật',
   JSON_OBJECT(
     'weightCapacity', 'Theo yêu cầu',
     'leadTime', '30-45 ngày',
     'warranty', '24 tháng'
   ),
   0, TRUE);

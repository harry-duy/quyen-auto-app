-- =====================================================================
-- Quyen Auto — Real product data from quyenauto.com
-- =====================================================================

-- ─── New categories (supplement existing ones) ────────────────────────
INSERT INTO product_categories (name, description, sort_order) VALUES
    ('Thùng Tải Lạnh',    'Thùng xe lắp máy lạnh chuyên chở hàng đông lạnh, thực phẩm tươi sống', 10),
    ('Thùng Tải Kín',     'Thùng xe tải kín bảo mật hàng hoá, giảm trọng lượng bằng vật liệu nhôm', 20),
    ('Thùng Chuyên Dùng', 'Thùng xe thiết kế đặc biệt theo yêu cầu: xe chở gà con, xe chuyên dùng', 30);

-- ─── Thùng Tải Lạnh Trên 6 Tấn ───────────────────────────────────────
INSERT INTO products (category_id, name, description, base_price)
VALUES (
    (SELECT id FROM product_categories WHERE name = 'Thùng Tải Lạnh'),
    'Thùng Tải Lạnh Trên 6 Tấn',
    'Thùng tải lạnh từ 6 tấn trở lên, đáp ứng vận chuyển nội ngoại thành toàn quốc. Kết cấu vững chắc, an toàn cao, nguyên liệu nhập khẩu từ nhà cung cấp hàng đầu thế giới. Công nghệ Sandwich Panel giữ lạnh tối ưu, đảm bảo an toàn vệ sinh thực phẩm. Phù hợp chở thuỷ sản, rau củ quả, kem, sữa, dược phẩm, thiết bị điện tử chuyên dụng.',
    0
);
INSERT INTO product_images (product_id, image_url, sort_order)
VALUES
    ((SELECT id FROM products WHERE name = 'Thùng Tải Lạnh Trên 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2021/05/F1L.2020-Isuzu-700x700.png', 0),
    ((SELECT id FROM products WHERE name = 'Thùng Tải Lạnh Trên 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2022/04/Banner-F1N.jpg', 1),
    ((SELECT id FROM products WHERE name = 'Thùng Tải Lạnh Trên 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2020/01/1920-1080.jpg', 2);

-- ─── Thùng Tải Lạnh Dưới 6 Tấn ───────────────────────────────────────
INSERT INTO products (category_id, name, description, base_price)
VALUES (
    (SELECT id FROM product_categories WHERE name = 'Thùng Tải Lạnh'),
    'Thùng Tải Lạnh Dưới 6 Tấn',
    'Thùng tải lạnh dưới 6 tấn, linh hoạt cho giao hàng nội thành và các tuyến ngắn. Thiết kế thùng hàng vững chắc, an toàn cao, nguyên liệu chất lượng đảm bảo vệ sinh thực phẩm. Phù hợp với xe ISUZU QMR, NPR, HINO 300 series. Chở được: thuỷ hải sản, rau củ, sữa, dược phẩm, thực phẩm đông lạnh.',
    0
);
INSERT INTO product_images (product_id, image_url, sort_order)
VALUES
    ((SELECT id FROM products WHERE name = 'Thùng Tải Lạnh Dưới 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2018/11/DONG-LANH-DUOI-6-TAN-VIEW-1.png', 0),
    ((SELECT id FROM products WHERE name = 'Thùng Tải Lạnh Dưới 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2018/11/DONG-LANH-DUOI-6-TAN-VIEW-2.png', 1),
    ((SELECT id FROM products WHERE name = 'Thùng Tải Lạnh Dưới 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2018/11/DONG-LANH-DUOI-6-TAN-VIEW-3.png', 2);

-- ─── Thùng Bảo Ôn Trên 6 Tấn ─────────────────────────────────────────
INSERT INTO products (category_id, name, description, base_price)
VALUES (
    (SELECT id FROM product_categories WHERE name = 'Thùng Bảo Ôn'),
    'Thùng Bảo Ôn Trên 6 Tấn',
    'Thùng bảo ôn cách nhiệt từ 6 tấn trở lên, không cần hệ thống làm lạnh, tiết kiệm chi phí vận hành. Phù hợp chở hàng Oxy, cá muối đá, hàng cần giữ nhiệt. Lớp foam cách nhiệt dày, inox 304 bên trong, độ bền cao. Đáp ứng nhu cầu vận chuyển tuyến nội ngoại thành và liên tỉnh.',
    0
);
INSERT INTO product_images (product_id, image_url, sort_order)
VALUES
    ((SELECT id FROM products WHERE name = 'Thùng Bảo Ôn Trên 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2018/12/BAO-ON-TREN-6-TAN-VIEW-1.png', 0),
    ((SELECT id FROM products WHERE name = 'Thùng Bảo Ôn Trên 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2018/12/KHUNG-750-X-450-DTSP-SAU.png', 1),
    ((SELECT id FROM products WHERE name = 'Thùng Bảo Ôn Trên 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2018/08/BAO-ON-TREN-6-TAN-VIEW-2.png', 2);

-- ─── Thùng Bảo Ôn Dưới 6 Tấn ─────────────────────────────────────────
INSERT INTO products (category_id, name, description, base_price)
VALUES (
    (SELECT id FROM product_categories WHERE name = 'Thùng Bảo Ôn'),
    'Thùng Bảo Ôn Dưới 6 Tấn',
    'Thùng bảo ôn cách nhiệt dưới 6 tấn, nhẹ và linh hoạt, phù hợp giao hàng nội thành. Thiết kế tối ưu giữ nhiệt độ ổn định trong suốt hành trình. Phù hợp xe ISUZU QMR, NPR, HINO 300 series, Hyundai HD65.',
    0
);
INSERT INTO product_images (product_id, image_url, sort_order)
VALUES
    ((SELECT id FROM products WHERE name = 'Thùng Bảo Ôn Dưới 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2022/11/BAO-ON-DUOI-6-TAN-VIEW-1.png', 0),
    ((SELECT id FROM products WHERE name = 'Thùng Bảo Ôn Dưới 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2018/11/DONG-LANH-DUOI-6-TAN-VIEW-2.png', 1),
    ((SELECT id FROM products WHERE name = 'Thùng Bảo Ôn Dưới 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2022/11/BAO-ON-DUOI-6-TAN-VIEW-3.png', 2);

-- ─── Thùng Tải Kín Trên 6 Tấn ────────────────────────────────────────
INSERT INTO products (category_id, name, description, base_price)
VALUES (
    (SELECT id FROM product_categories WHERE name = 'Thùng Tải Kín'),
    'Thùng Tải Kín Trên 6 Tấn',
    'Thùng tải kín từ 6 tấn trở lên, sử dụng kết hợp vật liệu nhôm giúp giảm khối lượng bản thân, tăng khối lượng hàng hoá chuyên chở. An toàn, bảo mật hàng hoá trên mọi địa hình. Đèn LED bên trong, sàn nhôm song chống trượt. Phù hợp hàng điện tử, hàng tiêu dùng, hàng giá trị cao.',
    0
);
INSERT INTO product_images (product_id, image_url, sort_order)
VALUES
    ((SELECT id FROM products WHERE name = 'Thùng Tải Kín Trên 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2018/08/TAI-KIN-TREN-6T-VIEW1.png', 0),
    ((SELECT id FROM products WHERE name = 'Thùng Tải Kín Trên 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2018/08/TAI-KIN-TREN-6T-VIEW2.png', 1),
    ((SELECT id FROM products WHERE name = 'Thùng Tải Kín Trên 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2018/08/TAI-KIN-TREN-6T-VIEW3.png', 2);

-- ─── Thùng Tải Kín Dưới 6 Tấn ────────────────────────────────────────
INSERT INTO products (category_id, name, description, base_price)
VALUES (
    (SELECT id FROM product_categories WHERE name = 'Thùng Tải Kín'),
    'Thùng Tải Kín Dưới 6 Tấn',
    'Thùng tải kín dưới 6 tấn, vật liệu nhôm siêu nhẹ, kết cấu vững chắc. An toàn bảo mật hàng hoá, phù hợp giao hàng nội thành và liên tỉnh. Thiết kế thẩm mỹ, đèn trần LED tiết kiệm điện. Phù hợp xe ISUZU NPR, QMR, HINO 300 series.',
    0
);
INSERT INTO product_images (product_id, image_url, sort_order)
VALUES
    ((SELECT id FROM products WHERE name = 'Thùng Tải Kín Dưới 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2022/12/TAI-KIN-DUOI-6T-VIEW1.png', 0),
    ((SELECT id FROM products WHERE name = 'Thùng Tải Kín Dưới 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2022/12/TAI-KIN-DUOI-6T-VIEW2.png', 1),
    ((SELECT id FROM products WHERE name = 'Thùng Tải Kín Dưới 6 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2022/12/TAI-KIN-DUOI-6T-VIEW3.png', 2);

-- ─── Xe Chở Gà Con Trên 8 Tấn ────────────────────────────────────────
INSERT INTO products (category_id, name, description, base_price)
VALUES (
    (SELECT id FROM product_categories WHERE name = 'Thùng Chuyên Dùng'),
    'Xe Chở Gà Con Trên 8 Tấn',
    'Xe chở gà con chuyên dụng từ 8 tấn trở lên, hệ thống thông gió chuyên biệt đảm bảo tỷ lệ sống sót cao. Ứng dụng công nghệ tiên tiến trong ngành chăn nuôi gia cầm. Phù hợp các trang trại lớn, công ty gia cầm công nghiệp. Thiết kế theo yêu cầu khách hàng, đảm bảo phúc lợi động vật trong vận chuyển.',
    0
);
INSERT INTO product_images (product_id, image_url, sort_order)
VALUES
    ((SELECT id FROM products WHERE name = 'Xe Chở Gà Con Trên 8 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2021/01/Last-cover-HINO-1920x1080.jpg', 0),
    ((SELECT id FROM products WHERE name = 'Xe Chở Gà Con Trên 8 Tấn'),
     'https://quyenauto.com/wp-content/uploads/2021/01/Xe-g%C3%A0-last-cover-HINO-1903x563.jpg', 1);

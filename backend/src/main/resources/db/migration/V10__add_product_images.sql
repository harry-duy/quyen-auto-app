-- =====================================================================
-- Add real product images from quyenauto.com to V4 seed products
-- (Only inserts if the product exists and has no images yet)
-- =====================================================================

-- ─── Thùng Bảo Ôn 3.5 Tấn ───────────────────────────────────────────
INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2022/11/BAO-ON-DUOI-6-TAN-VIEW-1.png', 0
FROM products WHERE name = 'Thùng Bảo Ôn 3.5 Tấn'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id);

INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2021/03/F1S-new-tach-nen700x700.png', 1
FROM products WHERE name = 'Thùng Bảo Ôn 3.5 Tấn'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id AND pi.sort_order = 1);

INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2022/11/BAO-ON-DUOI-6-TAN-VIEW-3.png', 2
FROM products WHERE name = 'Thùng Bảo Ôn 3.5 Tấn'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id AND pi.sort_order = 2);

-- ─── Thùng Bảo Ôn 5 Tấn ─────────────────────────────────────────────
INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2020/12/F1-HINO-432-tach-nen700x700.png', 0
FROM products WHERE name = 'Thùng Bảo Ôn 5 Tấn'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id);

INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2021/01/HINO-BO-TREN-6-TAN.png', 1
FROM products WHERE name = 'Thùng Bảo Ôn 5 Tấn'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id AND pi.sort_order = 1);

INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2018/12/BAO-ON-TREN-6-TAN-VIEW-1.png', 2
FROM products WHERE name = 'Thùng Bảo Ôn 5 Tấn'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id AND pi.sort_order = 2);

-- ─── Thùng Đông Lạnh 2.5 Tấn + Máy Lạnh Carrier ────────────────────
INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2018/11/DONG-LANH-DUOI-6-TAN-VIEW-1.png', 0
FROM products WHERE name = 'Thùng Đông Lạnh 2.5 Tấn + Máy Lạnh Carrier'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id);

INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2018/11/DONG-LANH-DUOI-6-TAN-VIEW-2.png', 1
FROM products WHERE name = 'Thùng Đông Lạnh 2.5 Tấn + Máy Lạnh Carrier'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id AND pi.sort_order = 1);

INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2018/11/DONG-LANH-DUOI-6-TAN-VIEW-3.png', 2
FROM products WHERE name = 'Thùng Đông Lạnh 2.5 Tấn + Máy Lạnh Carrier'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id AND pi.sort_order = 2);

-- ─── Thùng Đông Lạnh 3.5 Tấn + Máy Lạnh Thermo King ────────────────
INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2021/05/F1L.2020-Isuzu-700x700.png', 0
FROM products WHERE name = 'Thùng Đông Lạnh 3.5 Tấn + Máy Lạnh Thermo King'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id);

INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2022/04/Banner-F1N.jpg', 1
FROM products WHERE name = 'Thùng Đông Lạnh 3.5 Tấn + Máy Lạnh Thermo King'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id AND pi.sort_order = 1);

INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2020/01/1920-1080.jpg', 2
FROM products WHERE name = 'Thùng Đông Lạnh 3.5 Tấn + Máy Lạnh Thermo King'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id AND pi.sort_order = 2);

-- ─── Thùng Composite 1.5 Tấn ─────────────────────────────────────────
INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2022/12/TAI-KIN-DUOI-6T-VIEW1.png', 0
FROM products WHERE name = 'Thùng Composite 1.5 Tấn'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id);

INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2018/11/TK-HINO-FG.png', 1
FROM products WHERE name = 'Thùng Composite 1.5 Tấn'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id AND pi.sort_order = 1);

INSERT INTO product_images (product_id, image_url, sort_order)
SELECT id, 'https://quyenauto.com/wp-content/uploads/2023/06/Combo-4-xe-thiet-ke-Quyen-Auto.png', 2
FROM products WHERE name = 'Thùng Composite 1.5 Tấn'
AND NOT EXISTS (SELECT 1 FROM product_images pi WHERE pi.product_id = products.id AND pi.sort_order = 2);

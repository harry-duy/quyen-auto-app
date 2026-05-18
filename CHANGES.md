# Lịch sử thay đổi — Quyen Auto App

## [Unreleased] — Tạo báo giá nâng cao

Thiết kế lại toàn bộ form tạo báo giá theo mẫu Excel thực tế của công ty (file `Tạo báo giá.xlsx`).

### Thay đổi Backend

#### Migration
- **`V2__quotation_extended.sql`** — Thêm 9 cột mới vào bảng `quotations`:
  - `vehicle_model` VARCHAR(100) — Kiểu loại xe
  - `quantity` INT DEFAULT 1 — Số lượng
  - `chassis_width` INT — Rộng chassis (mm)
  - `box_code` VARCHAR(20) — Mã thùng
  - `box_type` VARCHAR(30) — Loại (F2LB, L, S...)
  - `ac_type` VARCHAR(20) — Loại máy lạnh (TN, KL...)
  - `ac_model` VARCHAR(100) — Model máy lạnh
  - `inner_wall_insulated` BOOLEAN — Vách trong tải kín
  - `specifications` JSON — Toàn bộ thông số kỹ thuật (phụ kiện, foam, option)

#### Entity
- **`Quotation.java`** — Thêm các field tương ứng với cột mới

#### DTO
- **`CreateQuotationRequest.java`** — Thêm các field mới; giữ `weightRange`, `cargoType`, `note` để tương thích ngược
- **`QuotationResponse.java`** — Expose đầy đủ các field mới trong response

#### Service
- **`QuotationService.java`** — Cập nhật `create()` để populate các field mới khi lưu Quotation

---

### Thay đổi Frontend (Flutter)

#### Data Layer
- **`quotation_request.dart`** — Viết lại thành plain Dart class (bỏ `@JsonSerializable`); thêm các field mới; `toJson()` viết tay
- **`quotation_request.g.dart`** — Vô hiệu hóa (không còn dùng code generation)
- **`order_repository.dart`** — Đơn giản hóa interface: `createQuotation(QuotationRequest)` thay vì 5 named params
- **`order_repository_impl.dart`** — Cập nhật theo interface mới
- **`order_providers.dart`** — `QuotationNotifier.submit()` nhận `QuotationRequest` trực tiếp

#### UI
- **`quotation_form_screen.dart`** — Thiết kế lại hoàn toàn:
  - **Bước 1 — Thông tin cơ bản**: Sản phẩm, kiểu loại xe, số lượng, rộng chassis, kích thước thùng (phủ bì + lọt lòng), mã thùng, loại, máy lạnh, vách trong tải kín
  - **Bước 2 — Phụ kiện & trang bị**: Loại sàn, yêu cầu sàn, khung trụ, cửa hông phụ/tài (có nhập kích thước), đèn hông, baga cabin, thang leo, ống OXY đầu/hông, thiết bị 1-2-3 (autocomplete)
  - **Bước 3 — Thông số kỹ thuật**: Foam (mm) theo từng vị trí: sàn/đầu/hông/nóc/cửa — có giá trị mặc định tiêu chuẩn
  - **Bước 4 — Tùy chọn & ghi chú**: Lòn hơi, part bảo vệ, nắp bầu hơi, nắp bình, thùng vết; ghi chú thêm
  - Dùng `Stepper` widget để điều hướng 4 bước
  - Tất cả specifications được đóng gói thành JSON object khi gửi lên server

---

### Cấu trúc `specifications` JSON

```json
{
  "dimensions": {
    "outer": { "length": 4450, "width": 1950, "height": 1950 },
    "inner": { "length": 4270, "width": 1810, "height": 1780 }
  },
  "floor": { "type": "C", "requirement": "Nhôm chống trượt" },
  "pillarFrame": "INOX",
  "sideDoorPassenger": { "enabled": true, "width": 750, "height": 1550 },
  "sideDoorDriver": true,
  "sideLight": { "enabled": false, "qty": 0 },
  "cabinRack": { "enabled": true, "qty": 1 },
  "ladder": { "enabled": true, "qty": 1 },
  "oxyPipeFront": true,
  "oxyPipeSide": true,
  "equipments": ["Máy Oxy: RT90-M + ZLE-50LA", "Bửng nâng hạ DLC3"],
  "foam": { "floor": 60, "front": 60, "side": 60, "roof": 75, "door": 60 },
  "options": {
    "airTubeStandard": { "enabled": false, "qty": 0 },
    "airTubeHorizontal": { "enabled": false, "qty": 0 },
    "protectionPart": { "enabled": false, "qty": 0 },
    "airChamberCap": { "enabled": false, "qty": 0 },
    "tankCap": { "enabled": false, "qty": 0 },
    "traceCargo": { "enabled": false, "qty": 0 }
  }
}
```

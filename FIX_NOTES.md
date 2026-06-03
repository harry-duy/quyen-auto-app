# Fix Notes - Quyen Auto App

File này ghi lại các thay đổi chính đã làm để người khác hoặc AI tiếp tục project không bị lạc hướng.

## Nhánh làm việc

- Branch local: `fix/develop`
- Commit hiện tại: `317a3b8 Fix quotation and order workflows`
- Chưa push được vì GitHub trả lỗi quyền `403` với account `EricNMQ`.
- Không push trực tiếp lên `develop`.

## Những phần đã fix

### 1. Build Flutter và asset

- Sửa lỗi Flutter build do `pubspec.yaml` khai báo folder không tồn tại.
- Đã bỏ khai báo `assets/icons/` và `assets/fonts/` vì folder không có.
- Giữ `.env` trong assets vì app đang cần đọc config.

### 2. Database/API

- Backend dùng MySQL qua Spring Boot.
- DB dev hiện trỏ mặc định về:
  - Host: `127.0.0.1`
  - Database: `quyen_auto`
  - User: `quyen_user`
  - Password: `QuyenAuto123`
- Đã từng clear dữ liệu test trong DB local:
  - `orders`
  - `order_status_logs`
  - `quotations`
  - `leads`
  - `vehicles`
  - `warranty_requests`
  - `warranty_logs`
  - `warranty_request_image_urls`
  - `chat_rooms`
  - `chat_messages`

### 3. Quy trình báo giá và đơn hàng

- Customer gửi yêu cầu báo giá thì không chuyển qua màn xem đơn ngay.
- Staff liên hệ khách, nhập giá chốt thủ công, rồi xác nhận để tạo đơn.
- Khi staff xác nhận báo giá thành đơn:
  - Tạo `Order`.
  - Gán staff phụ trách.
  - Đưa trạng thái đơn sang luồng xử lý mới.
- Thêm DTO backend:
  - `ConfirmQuotationOrderRequest`
- Thêm endpoint staff xác nhận báo giá thành đơn:
  - `PATCH /staff/quotations/{id}/confirm-order`

### 4. Luồng trạng thái đơn hàng

Không dùng giao hàng vì khách tới công ty nhận xe.

Các bước chi tiết dùng trong `productionStatus`:

- `RECEIVED` - Tiếp nhận yêu cầu
- `INFO_CONFIRMED` - Xác nhận thông tin
- `QUOTED_DEPOSITED` - Báo giá & đặt cọc
- `ORDER_CONFIRMED` - Xác nhận đơn hàng
- `PRODUCTION_STARTED` - Bắt đầu sản xuất
- `QUALITY_CHECKING` - Kiểm tra chất lượng
- `COMPLETED` - Hoàn thành
- `CANCELLED` - Đã hủy

Backend vẫn giữ trạng thái tổng quát của order:

- `PENDING`
- `CONFIRMED`
- `IN_PRODUCTION`
- `COMPLETED`
- `CANCELLED`

Backend có normalize trạng thái cũ `DELIVERING` sang `QUALITY_CHECKING`.

### 5. Staff app

- Màn quản lý báo giá: staff nhận xử lý, liên hệ, báo giá, xác nhận chốt đơn.
- Khi một staff đã nhận báo giá thì staff khác không còn thấy báo giá đó như việc chung nữa.
- Staff order detail được chỉnh giống logic customer hơn.
- Staff cập nhật trạng thái đơn theo timeline mới, có `QUALITY_CHECKING`, không còn `DELIVERING`.

### 6. Customer app

- Sửa màn danh sách đơn hàng.
- Sửa màn chi tiết đơn hàng.
- Timeline đơn hàng bên customer bỏ bước giao hàng.
- Customer hiển thị trạng thái theo `productionStatus`.
- Customer form báo giá bỏ `Stepper` vì bị đơ/trống khi chuyển qua bước 3 trên simulator.
- Form báo giá hiện là một trang cuộn thẳng gồm 4 khối:
  - Thông tin cơ bản
  - Phụ kiện & trang bị
  - Thông số kỹ thuật
  - Tùy chọn & ghi chú

### 7. Lỗi chữ tiếng Việt

- Lỗi không phải font, mà là encoding trong source bị hỏng.
- Đã sửa các file customer chính:
  - Login/register/profile/chat
  - Home
  - Product detail
  - Quotation form
  - Order list/detail
  - Warranty
  - `AppStrings`
  - message lỗi API
- Lưu ý: một số màn staff vẫn có thể còn chữ lỗi nếu chưa được dọn hết.

### 8. Logo/app icon

- Đã chỉnh nhiều phần logo app/login/home trước đó.
- Nếu sửa tiếp logo, kiểm tra asset gốc trong `assets/images/` và các icon launcher Android trước khi resize để tránh bị cắt ảnh.

## Lệnh kiểm tra đã chạy

Customer build đã chạy thành công:

```powershell
& C:\Users\admin\Downloads\flutter\bin\flutter.bat build apk --debug --flavor customer -t lib\main.dart
```

APK output:

```text
build\app\outputs\flutter-apk\app-customer-debug.apk
```

`flutter analyze` còn warning/info cũ, không chặn build.

## Việc cần kiểm tra tiếp

- Test lại customer gửi báo giá sau khi bỏ Stepper.
- Test staff nhận báo giá, liên hệ, nhập giá chốt, xác nhận tạo đơn.
- Test customer thấy đơn mới sau khi staff chốt.
- Test staff cập nhật trạng thái:
  - Xác nhận thông tin
  - Báo giá & đặt cọc
  - Xác nhận đơn hàng
  - Bắt đầu sản xuất
  - Kiểm tra chất lượng
  - Hoàn thành
- Test chat giữa customer/staff sau khi clear DB.
- Nếu dùng staff app nhiều, dọn tiếp lỗi encoding ở các file `lib/presentation/staff/...`.

## Lưu ý cho người tiếp tục

- Không push trực tiếp lên `develop`.
- Dùng branch riêng, ví dụ `fix/develop` hoặc tên khác nếu Git không cho tạo `develop/fix`.
- Git không cho tạo `develop/fix` khi đã có branch `develop` local, vì vậy nhánh hiện tại là `fix/develop`.
- Trước khi sửa tiếp, đọc file này và kiểm tra `git status`.
## Workflow update - quotation templates and shared options

- Quotation templates now represent the size/spec baseline: vehicle/body dimensions, panel/foam, standard materials and base price.
- Shared quotation options are stored separately from templates. Options are grouped by position:
  - `FLOOR`
  - `DOOR`
  - `WALL`
  - `AC`
  - `LIGHT`
  - `ACCESSORY`
  - `OTHER`
- Staff creates a quotation by selecting a customer, selecting a template, then adding options by position.
- If the customer asks for something outside the shared option catalog, staff can add it as a custom option. Manager prices it during approval.
- The backend snapshots selected option name, position, unit, unit price and quantity into the quotation. Later changes in the shared option catalog do not mutate old quotations.
- Quotation price fields added:
  - `base_price`
  - `option_total`
  - `estimated_total`
  - `adjustment_fee`
  - `discount_amount`
  - `approved_total`
- Manager fallback states added:
  - `NEED_REVISION`: return to staff for missing/unclear info.
  - `WAITING_TECHNICAL_REVIEW`: internal hold while manager/staff asks technical team outside the app.
- Customer still should not see internal quotation pricing. Staff contacts the customer outside the app after manager approval.

# Changelog

## [Unreleased] — Sprint 2026-05-21 (Hotfix & UX)

### Backend

#### Bug Fixes
- **technicianName null**: `WarrantyResponse.from()` giờ fallback sang `w.getTechnician().getFullName()` nếu cột `technician_name` bị null (data cũ từ seed V4 không điền cột này)

### Flutter

#### Bug Fixes
- **Notification refId type**: đổi kiểu `int?` → `String?` — backend lưu `ref_id` dạng `VARCHAR(50)`, cast sang `num?` gây crash khi polling thông báo
- **Warranty logs null crash**: `warranty_response.g.dart` — dùng nullable cast `List<dynamic>?` + fallback `?? []` tránh crash khi `logs` là null
- **Order statusLogs null crash**: `order_response.g.dart` — nullable cast tương tự cho `statusLogs`
- **Warranty FAB bị che**: bọc FAB trong `Padding(bottom: kBottomNavigationBarHeight)` — FAB không còn bị `BottomNavigationBar` của HomeScreen che
- **Vehicle card không bấm được**: thêm `InkWell.onTap` + `_showDetail()` bottom sheet hiển thị đầy đủ thông tin xe
- **Staff warranty — date picker**: thay trường nhập tay ngày hẹn bằng `showDatePicker`, clear button xóa ngày, format đúng `yyyy-MM-dd` khi submit

#### UX / Pricing
- **Xóa giá khỏi sản phẩm**: `product_card.dart`, `home_screen.dart`, `product_detail_screen.dart` — không hiển thị giá tham khảo, thay bằng "Liên hệ báo giá"
- **Báo giá không yêu cầu đăng nhập**: xóa `/quotation` khỏi `needsAuth` trong router — khách có thể để lại số điện thoại mà không cần tài khoản

### Database
- **V12 migration**: seed dữ liệu mẫu để test Chat & Warranty
  - Cập nhật xe VIN2024ISUZU002 (hết hạn 15 ngày trước), VIN2025HINO001 (còn 6 tháng)
  - Thêm 4 xe mới với trạng thái bảo hành đa dạng (sắp hết/không có/còn nhiều/hết đúng hôm nay)
  - Thêm 2 yêu cầu bảo hành (IN_PROGRESS, RESOLVED) + warranty logs
  - Thêm 3 phòng chat với tin nhắn mẫu (1 đang chat, 1 chờ tiếp nhận, 1 tư vấn)
  - Thêm notification bảo hành sắp hết hạn và chat mới cho staff

---

## Sprint 2026-05-20

### Backend

#### Bug Fixes
- **DB kết nối**: Thêm `DotEnvPostProcessor` + `META-INF/spring.factories` để Spring Boot tự động nạp `backend/.env` trước khi khởi tạo context — không cần chạy script riêng nữa
- **Warranty API**: Sửa lỗi `staffWarrantyUpdate` → `staffWarrantyResult` (PATCH `/staff/warranty/{id}/result`)
- **DTO deserialization**: Thêm `@NoArgsConstructor` vào `ChatRoomResponse`, `ChatMessageResponse`, `VehicleResponse`, `WarrantyResponse`, `WarrantyResponse.LogItem` để Jackson hoạt động với `@Builder`

#### Tính năng mới — Chat (kiểu Shopee)
- `POST /chat/rooms/start` — khách hàng bắt đầu chat, tạo room với `staff = null`, broadcast `/topic/chat.new-room` đến tất cả staff
- `PATCH /chat/rooms/{roomId}/claim` — staff tiếp nhận phòng chat đang chờ, broadcast `/topic/chat.claimed.{roomId}`
- `POST /chat/rooms/{roomId}/messages` — gửi tin nhắn, broadcast `/topic/chat.room.{roomId}`
- `ChatRoom` entity: thêm field `orderCode` (mã hợp đồng đính kèm khi chat từ đơn hàng)
- `ChatRoomResponse` mở rộng: `isWaiting`, `orderCode`, `customerName`, `customerAvatar`, `lastMessage` (String), `lastMessageAt`
- Migration V11: `ALTER TABLE chat_rooms ADD COLUMN order_code`

#### Tính năng mới — Bảo hành (Warranty)
- `POST /staff/warranty/vehicles` — staff đăng ký xe cho khách hàng kèm `contractCode` và `warrantyExpiryDate`
- `GET /warranty/vehicles` — khách hàng xem danh sách xe của mình với trạng thái bảo hành
- `WarrantyExpiryScheduler` — chạy hàng ngày lúc 8:00 sáng, gửi thông báo FCM cho chủ xe tại các mốc 30/7/1 ngày trước khi hết hạn và đúng ngày hết hạn
- `WarrantyResponse` chuyển sang dạng flat (bỏ nested `vehicle` object), thêm `logs` với `performedBy`
- `Vehicle` entity: thêm `contractCode`, `warrantyExpiryDate`
- Migration V11: `ALTER TABLE vehicles ADD COLUMN contract_code, warranty_expiry_date`

#### Infrastructure
- `docker-compose.prod.yml`: thêm resource limits, Redis AOF persistence, giới hạn log
- `nginx/nginx.conf`: tắt `server_tokens`, thêm security headers, proxy timeout
- `.github/workflows/ci.yml`: thêm bước Trivy vulnerability scan
- `scripts/backup-mysql.sh`: script backup MySQL tự động với retention 7 ngày

---

### Flutter

#### Bug Fixes
- **WebSocket chat path**: sửa `/topic/room/$roomId` → `/topic/chat.room.$roomId`
- **Type mismatch**: `senderId.toString() == currentUser?.id` (senderId là `int`, user.id là `String`)
- **Warranty screen**: sửa `.vehicle.plateNumber` → `.plateNumber` (flat model), xóa `DateFormat` trên `scheduledDate` (đã là String)
- **Staff assignment**: chuyển từ nhập tên tự do sang dropdown chọn từ `staffMemberListProvider`, gửi `{technicianId: int}` đúng kiểu backend

#### Tính năng mới — Chat
- `chat_providers.dart`: `chatRoomsProvider`, `activeChatProvider` (family, real-time WS + auto-dispose), `chatActionsProvider`
- `chat_screen.dart`: UI chat đầy đủ với message bubble (cam = tôi, trắng = đối phương), input bar, cuộn tự động
- `staff_chat_list_screen.dart`: danh sách phòng chat cho staff, nút "Tiếp nhận" cho phòng `isWaiting`, badge chỉ thị chờ
- `order_detail_screen.dart`: thêm nút "Liên hệ" — gọi `startChat(orderCode:)` rồi điều hướng vào chat

#### Tính năng mới — Bảo hành
- `warranty_providers.dart`: `myVehiclesProvider`, `myWarrantiesProvider`, `warrantyActionsProvider`
- `warranty_screen.dart`: 2 tab (xe + yêu cầu bảo hành), chip màu trạng thái hết hạn (xanh/vàng/đỏ), thẻ yêu cầu có thể mở rộng xem lịch sử log, bottom sheet tạo yêu cầu mới
- `warranty_response.dart` + `.g.dart`: `VehicleResponse` flat, `WarrantyRequestResponse` flat với `logs`, `WarrantyLogResponse` thêm `performedBy`
- `warranty.dart` entity: `Vehicle.id` đổi thành `int`, thêm `isWarrantyActive`, `isWarrantyExpiringSoon` getters
- `warranty_management_screen.dart` (staff): sửa toàn bộ field references, dialog assign dùng dropdown staff, dialog result có trường `status` + `result` + `note` riêng biệt

#### Cải tiến API
- `api_constants.dart`: thêm `chatStart`, `chatClaim`, `chatMarkRead`, `staffWarrantyVehicles`; đổi tên `staffWarrantyUpdate` → `staffWarrantyResult`
- `websocket_service.dart`: thêm `subscribeNewRooms`, `subscribeRoomClaimed`, `unsubscribeChat`

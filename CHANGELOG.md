# Changelog

## [Unreleased] — Sprint 2026-05-20

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

# Changelog

## [Unreleased] — Sprint 2026-05-21 (Chat Shopee-style + Warranty Honda-style)

### Backend

#### Tính năng mới — Chat Typing & Read Receipt
- `ChatWebSocketController` — thêm `@MessageMapping("/chat.typing")`: nhận typing event từ client, broadcast `{"userId", "typing"}` đến `/topic/chat.typing.{roomId}`
- `ChatWebSocketController` — `markRead` giờ broadcast READ event lên `/topic/chat.room.{roomId}` để cập nhật read receipt real-time
- `TypingMessage.java` — DTO mới: `roomId` + `typing` boolean

#### Tính năng mới — Warranty Image Upload
- `CreateWarrantyRequest` — thêm `scheduledDate` (LocalDate) và `imageUrls` (List\<String\>)
- `WarrantyRequest` entity — thêm `imageUrls` dạng `@ElementCollection(fetch = EAGER)` lưu vào bảng `warranty_request_image_urls`
- `WarrantyResponse.from()` — thêm `imageUrls` vào response
- `WarrantyService.create()` — map `scheduledDate` và `imageUrls` từ request vào entity
- **V13 migration** — tạo bảng `warranty_request_image_urls(warranty_request_id, image_url)`

#### Bug Fixes
- **LazyInitializationException** — `WarrantyRequest.imageUrls` chuyển sang `FetchType.EAGER` — tránh crash khi `WarrantyResponse.from()` truy cập collection ngoài Hibernate session

### Flutter

#### Tính năng mới — Chat kiểu Shopee (rewrite hoàn toàn)
- **Avatar + initials** trong AppBar lấy từ tên staff/khách hàng
- **Typing indicator** — `TypingNotifier` subscribe `/topic/chat.typing.{roomId}`, hiển thị subtitle "Đang nhập..." + animated dots bubble `_TypingBubble`; debounce 2s khi gõ, tắt sau 3s nếu không có event mới
- **Read receipts** — icon ✓ (đã gửi) / ✓✓ xanh (đã đọc) trên mỗi tin nhắn của mình
- **Gửi ảnh** — `ImagePicker.pickImage` → upload lên `/api/v1/upload?folder=chat` → `sendImageViaWs` với type `IMAGE`; `CachedNetworkImage` hiển thị ảnh trong bubble
- **Date dividers** — gom nhóm tin nhắn theo ngày (Hôm nay / dd/MM/yyyy)
- **Input bar** — nút picker ảnh bên trái, field "Nhập tin nhắn...", nút gửi cam bên phải
- `WebSocketService` — thêm `subscribeTyping`, `unsubscribeTyping`, `sendTyping`
- `ChatRepositoryImpl` — thêm `sendImageViaWs`, `sendTyping`
- `ActiveChatNotifier` — thêm `sendImage(imageUrl)`

#### Tính năng mới — Bảo hành kiểu Honda (rewrite hoàn toàn)
- **Thẻ bảo hành số** — bottom sheet dark navy gradient, QR code (`qr_flutter: ^4.1.0`) mã hóa `vehicleId|plateNumber|VIN|expiryDate`, badge "Còn bảo hành / Hết hạn"
- **Timeline lịch sử dịch vụ** — mỗi yêu cầu bảo hành có `ExpansionTile`, dòng thời gian dọc với dot màu theo trạng thái và label action
- **Scroll ảnh bằng chứng** — `horizontal ListView` hiển thị ảnh đính kèm trong mỗi yêu cầu bảo hành
- **Tạo yêu cầu bảo hành** — bottom sheet với dropdown xe, text field mô tả sự cố, date picker ngày hẹn (tuỳ chọn), upload tối đa 5 ảnh bằng chứng qua `ImagePicker.pickMultiImage`
- `pubspec.yaml` — thêm dependency `qr_flutter: ^4.1.0`

#### Bug Fixes
- **GoException `/home/warranty`** — `profile_screen.dart`: "Bảo hành xe" đổi từ `context.go(AppRoutes.warranty)` sang `homeTabIndexProvider.state = 3; context.go(AppRoutes.home)` — tránh crash khi route không tồn tại
- **Warranty list luôn rỗng** — `warranty_repository_impl.dart`: `fromData` đọc sai key — backend trả `PageResponse {"content": [...]}` trực tiếp trong `data`, nhưng code cố đọc `json['data']` (null) thay vì `json['content']`; sửa bằng `containsKey('content')` check
- **Typing indicator echo** — `chat_providers.dart`: `TypingNotifier` so sánh `map['userId']` với `currentUserId` từ `authProvider`, bỏ qua event của chính mình — tránh "Đang nhập..." hiện giả khi khách đang gõ
- **Date picker crash** — `warranty_screen.dart`: xóa `locale: const Locale('vi','VN')` khỏi `showDatePicker` — không có `flutter_localizations` gây `MaterialLocalizations not found`

#### Order Detail
- **Chat từ đơn hàng** — `order_detail_screen.dart`: nút "Liên hệ" gửi tóm tắt đơn hàng làm tin nhắn đầu tiên (`orderCode`, `productName`, tổng tiền, trạng thái) trước khi mở màn hình chat

### Database
- **V13 migration**: tạo bảng `warranty_request_image_urls` lưu URL ảnh bằng chứng bảo hành

---

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
